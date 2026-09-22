// A malformed DD-version stamp refuses at the first HLI call that opens an
// occurrence. IDS::open opens only the data entry, which has no stamp, so it
// must forward. equilibrium.get then reaches the occurrence open and must
// return the refusal before any data seam serves the object.
//
// The frozen refusal reason is deliberately not asserted here. The generated
// HLI reports the al_begin_global_action message on standard output but returns
// only its status. verify_fixture_unchanged.cmake reads that output after this
// program has verified the status is in the refusal band; tests/shim/README.md
// records this named exception to the suite's public-behaviour-only rule.
#include "ALClasses.h"
#include "shim_run_guard.h"

#include <cstdio>
#include <string>

namespace {

constexpr const char* kFailureMarker = "REFUSAL-FAILURE";
constexpr int kExpectedAssertions = 7;

void expect(bool condition, const char* message, int& assertions, int& failures) {
  ++assertions;
  if (!condition) {
    std::printf("%s: %s\n", kFailureMarker, message);
    ++failures;
  }
}

bool isRefusal(int status) {
  return status >= IdsNs::AL_REFUSAL_BAND_MIN && status <= IdsNs::AL_REFUSAL_BAND_MAX;
}

}  // namespace

int main(int argc, char* argv[]) {
  if (argc != 2) {
    std::printf("%s: missing stamp-malformed fixture\n", kFailureMarker);
    return 1;
  }

  int assertions = 0;
  int failures = 0;
  IdsNs::IDS ids;
  const std::string uri = std::string("imas:hdf5?path=") + argv[1];

  const int openStatus = ids.open(uri, OPEN_PULSE);
  expect(openStatus == 0, "malformed stamp refused the data-entry open", assertions, failures);
  expect(ids.isConnected(), "data-entry open did not return a usable handle", assertions, failures);

  const int getStatus = ids._equilibrium.get();
  ids.close();

  expect(isRefusal(getStatus), "malformed stamp did not refuse at occurrence open", assertions, failures);
  expect(getStatus != IdsNs::PARTIAL_READ,
         "malformed stamp was tolerated into a partial read", assertions, failures);
  expect(ids._equilibrium.getSkippedPathCount() == 0,
         "malformed stamp was recorded as a skipped path", assertions, failures);
  expect(!ids._equilibrium.isDefined(),
         "malformed stamp reached a data seam and defined the IDS", assertions, failures);
  expect(ids._equilibrium.time.size() == 0,
         "malformed stamp reached a data seam and populated the IDS time", assertions, failures);

  ShimTest::assertRanCount(kFailureMarker, "F3.1 assertions", assertions,
                           kExpectedAssertions, failures);
  if (failures != 0) {
    std::printf("%s: %d F3.1 expectation(s) failed\n", kFailureMarker, failures);
    return 1;
  }
  return 0;
}
