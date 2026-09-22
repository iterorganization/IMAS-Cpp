// Family 6.1--6.2: append an equilibrium slice through the public HLI, then
// read the whole occurrence back.  The same executable runs against the DD
// 3.39.0 pulse (where the shim converts) and the DD 4.1.1 control (where it
// does not), so a successful round trip cannot merely mean conversion was
// avoided.
//
// This is a consistency check, not a stored-data correctness proof. The shim
// flips psi_axis while writing to the older DD and flips it again while
// reading, so this program cannot prove the stored path, the raw stored sign,
// the DD-version stamp, or that a non-primary candidate stayed untouched.
// Those require a native reader outside both the HLI and shim (C5), which is
// deliberately a different suite.
#include "ALClasses.h"
#include "shim_fixture_uri.h"
#include "shim_run_guard.h"

#include <cmath>
#include <cstdio>
#include <string>

namespace {

constexpr const char* kFailureMarker = "ROUNDTRIP-FAILURE";
constexpr int kExpectedAssertions = 13;
constexpr double kAppendedTime = 2.0;
constexpr double kCuratedPsiAxis = -7654321.0;

// The harness's one explicit argument (S5.6: `clean-read` /
// `partial-read-allowed`, no default). It governs every status the run
// checks -- both whole-occurrence reads and the append -- because "the
// control must be clean" is a statement about the control run, not about one
// of its calls.
enum class ReadPolicy { Clean, PartialAllowed };

bool parseReadPolicy(const char* text, ReadPolicy& policy) {
  const std::string value(text);
  if (value == "clean-read") {
    policy = ReadPolicy::Clean;
  } else if (value == "partial-read-allowed") {
    policy = ReadPolicy::PartialAllowed;
  } else {
    return false;
  }
  return true;
}

bool readMatchesPolicy(int status, ReadPolicy policy) {
  return policy == ReadPolicy::Clean ? status == 0
                                     : status == 0 || status == IdsNs::PARTIAL_READ;
}

// The same two-value policy governs the append. Under `clean-read` the control
// appends only paths the same-version pulse already holds, so nothing can
// legitimately be refused: tolerating PARTIAL_PUT there would let the control
// pass while silently dropping the very write it exists to compare against,
// which is what makes the cross-DD round trip meaningful. F6.3 owns the
// refused-write case on its own fixture.
bool putMatchesPolicy(int status, ReadPolicy policy) {
  return policy == ReadPolicy::Clean ? status == 0
                                     : status == 0 || status == IdsNs::PARTIAL_PUT;
}

void expect(bool condition, const char* detail, int& assertions, int& failures) {
  ++assertions;
  if (!condition) {
    ++failures;
    std::printf("%s: %s\n", kFailureMarker, detail);
  }
}

}  // namespace

int main(int argc, char* argv[]) {
  if (argc != 3) {
    std::printf("%s: usage: <fixture-directory> <clean-read|partial-read-allowed>\n",
                kFailureMarker);
    return 1;
  }

  ReadPolicy readPolicy;
  if (!parseReadPolicy(argv[2], readPolicy)) {
    std::printf("%s: unknown read policy %s\n", kFailureMarker, argv[2]);
    return 1;
  }

  int assertions = 0;
  int failures = 0;
  const std::string uri = ShimTest::hdf5Uri(argv[1]);

  IdsNs::IDS beforeAppend;
  expect(beforeAppend.open(uri, OPEN_PULSE) == 0,
         "could not open the private fixture before appending", assertions, failures);
  const int initialGetStatus = beforeAppend._equilibrium.get();
  expect(readMatchesPolicy(initialGetStatus, readPolicy),
         "the pre-append whole-occurrence read violated its explicit policy", assertions, failures);

  const int initialSliceCount = beforeAppend._equilibrium.time_slice.extent(0);
  const int initialTimeCount = beforeAppend._equilibrium.time.extent(0);
  const int initialTimeMode = beforeAppend._equilibrium.ids_properties.homogeneous_time;
  expect(initialSliceCount > 0, "the fixture had no time slices to append to", assertions, failures);
  expect(initialSliceCount == initialTimeCount,
         "the fixture began with different time-slice and time-base lengths", assertions, failures);
  beforeAppend.close();

  IdsNs::IDS append;
  expect(append.open(uri, OPEN_PULSE) == 0, "could not reopen the private fixture for append",
         assertions, failures);
  append._equilibrium.ids_properties.homogeneous_time = initialTimeMode;
  append._equilibrium.time.resize(1);
  append._equilibrium.time(0) = kAppendedTime;
  append._equilibrium.time_slice.resize(1);
  append._equilibrium.time_slice(0).time = kAppendedTime;
  // psi_axis is a COCOS sign-flip rule between DD 4.1.1 and DD 3.39.0.
  append._equilibrium.time_slice(0).global_quantities.psi_axis = kCuratedPsiAxis;

  const int putSliceStatus = append._equilibrium.putSlice();
  expect(putMatchesPolicy(putSliceStatus, readPolicy),
         "the mapped slice append violated its explicit policy", assertions, failures);
  append.close();

  IdsNs::IDS readback;
  expect(readback.open(uri, OPEN_PULSE) == 0, "could not reopen the private fixture for readback",
         assertions, failures);
  const int readbackStatus = readback._equilibrium.get();
  expect(readMatchesPolicy(readbackStatus, readPolicy),
         "the post-append whole-occurrence read violated its explicit policy", assertions, failures);
  expect(readback._equilibrium.time_slice.extent(0) == initialSliceCount + 1,
         "the time-slice container did not grow by exactly one", assertions, failures);
  expect(readback._equilibrium.time.extent(0) == initialTimeCount + 1,
         "the time base did not grow by exactly one", assertions, failures);
  expect(readback._equilibrium.ids_properties.homogeneous_time == initialTimeMode,
         "the time mode changed during the slice append", assertions, failures);

  const int appendedIndex = initialSliceCount;
  expect(std::fabs(readback._equilibrium.time_slice(appendedIndex).time - kAppendedTime) < 1e-12,
         "the appended slice time did not round trip", assertions, failures);
  expect(std::fabs(readback._equilibrium.time_slice(appendedIndex).global_quantities.psi_axis -
                   kCuratedPsiAxis) <
             1e-12,
         "the curated COCOS-mapped psi_axis value did not round trip", assertions, failures);
  readback.close();

  ShimTest::assertRanCount(kFailureMarker, "F6.1/F6.2 assertions", assertions,
                           kExpectedAssertions, failures);
  if (failures != 0) {
    std::printf("%s: %d F6.1/F6.2 expectation(s) failed\n", kFailureMarker, failures);
    return 1;
  }
  return 0;
}
