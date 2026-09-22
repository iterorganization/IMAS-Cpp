// F6.3 `torn-write` (docs/SHIM_SUITE_CONVENTION.md S5.6): pin the shape of a
// refusal that lands mid-slice.
//
// Against a private copy of the older-DD pulse, append one slice carrying
// both a mapped, COCOS-flipped field (`global_quantities/psi_axis`, as in the
// F6.1/F6.2 round trip) and a field the older DD has no slot for at all:
// `global_quantities/rho_tor_boundary`, which the shim's own conversion map
// (IMAS-Multiversion-DD-Loader's docs/3.39.0--4.1.1.xml, rule
// `new-global-quantities-rho-tor-boundary`) records as `right_only` --
// "path added in DD 3.40.0; no counterpart in 3.39.0", forward direction
// `unmappable`. The generated write traversal has no rollback: the
// array-of-structures open already widened the container before any leaf
// write ran, and the core commits that shape at end-action time regardless
// of what follows, so the refused field is simply missing from the appended
// slice while the mapped field lands.
//
// This is a pin on an *accepted limitation*, not a statement that a torn
// write is desirable -- hence the `behaviour-pin` label rather than
// `contract-assertion`. It must keep passing exactly because nothing here
// should ever grow atomic rollback.
#include "ALClasses.h"
#include "shim_fixture_uri.h"
#include "shim_run_guard.h"

#include <cmath>
#include <cstdio>
#include <string>

namespace {

constexpr const char* kFailureMarker = "TORN-WRITE-FAILURE";
constexpr int kExpectedAssertions = 16;
constexpr double kAppendedTime = 2.0;
constexpr double kCuratedPsiAxis = -7654321.0;
constexpr double kCuratedRhoTorBoundary = 0.5;
// The relative path `mustAbort` records and prints for this field -- see
// `equilibrium_IDSBase.cpp`'s generated `putSlice`: `fieldPath =
// "global_quantities/rho_tor_boundary"`. Asserted against both the public
// SkippedPath record and the program's own standard output.
constexpr const char* kRefusedFieldPath = "global_quantities/rho_tor_boundary";

void expect(bool condition, const char* detail, int& assertions, int& failures) {
  ++assertions;
  if (!condition) {
    ++failures;
    std::printf("%s: %s\n", kFailureMarker, detail);
  }
}

}  // namespace

int main(int argc, char* argv[]) {
  if (argc != 2) {
    std::printf("%s: usage: <fixture-directory>\n", kFailureMarker);
    return 1;
  }

  int assertions = 0;
  int failures = 0;
  const std::string uri = ShimTest::hdf5Uri(argv[1]);

  IdsNs::IDS beforeAppend;
  expect(beforeAppend.open(uri, OPEN_PULSE) == 0,
         "could not open the private fixture before appending", assertions, failures);
  const int initialGetStatus = beforeAppend._equilibrium.get();
  expect(initialGetStatus == 0 || initialGetStatus == IdsNs::PARTIAL_READ,
         "the pre-append whole-occurrence read neither succeeded nor partially succeeded",
         assertions, failures);

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
  // Mapped: this DD's psi_axis has a slot in the older DD, curated so an
  // untranslated forward is easy to tell from the shim's COCOS flip.
  append._equilibrium.time_slice(0).global_quantities.psi_axis = kCuratedPsiAxis;
  // Newer-DD-only (`right_only` in the shim's conversion map): the older DD
  // has no slot for this field at all, so its write must be refused rather
  // than silently dropped.
  append._equilibrium.time_slice(0).global_quantities.rho_tor_boundary = kCuratedRhoTorBoundary;

  const int putSliceStatus = append._equilibrium.putSlice();
  expect(putSliceStatus == IdsNs::PARTIAL_PUT,
         "the slice append with a newer-DD-only field did not report a partial put", assertions,
         failures);

  // A slice put writes every field of the whole appended time_slice element,
  // not only the two this test set, so other unmapped fields under it may
  // also be refused. This pin cares about one field by name, not about being
  // the only refusal (docs/SHIM_SUITE_CONVENTION.md F6.3: "a traversal
  // dropping a different field would carry the same partial status and must
  // still fail this pin").
  const auto& skippedPaths = append._equilibrium.getSkippedPaths();
  expect(!skippedPaths.empty(), "the append recorded no skipped paths at all", assertions,
         failures);
  bool foundRefusedPath = false;
  for (const auto& skipped : skippedPaths) {
    if (skipped.operation == IdsNs::SkippedPath::Operation::Write &&
        skipped.path == kRefusedFieldPath) {
      foundRefusedPath = true;
      break;
    }
  }
  expect(foundRefusedPath,
         "no recorded skipped path was the refused Write of global_quantities/rho_tor_boundary",
         assertions, failures);
  // `IdsNs::Ids::mustAbort` (src/IdsDef.cpp) already printed
  // "REFUSED WRITE: global_quantities/rho_tor_boundary" to standard output
  // when it tolerated this refusal during the traversal above -- that
  // generated diagnostic, not one this program adds, is what the CTest
  // wrapper matches to prove the refused path was named by the traversal
  // that tolerated it, not by an unrelated error.
  append.close();

  IdsNs::IDS readback;
  expect(readback.open(uri, OPEN_PULSE) == 0, "could not reopen the private fixture for readback",
         assertions, failures);
  const int readbackStatus = readback._equilibrium.get();
  expect(readbackStatus == 0 || readbackStatus == IdsNs::PARTIAL_READ,
         "the post-append whole-occurrence read neither succeeded nor partially succeeded",
         assertions, failures);
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
         "the field written before the refusal did not round trip", assertions, failures);
  expect(readback._equilibrium.time_slice(appendedIndex).global_quantities.rho_tor_boundary ==
             EMPTY_DOUBLE,
         "the refused field was written despite the refusal", assertions, failures);
  readback.close();

  ShimTest::assertRanCount(kFailureMarker, "F6.3 assertions", assertions, kExpectedAssertions,
                           failures);
  if (failures != 0) {
    std::printf("%s: %d F6.3 expectation(s) failed\n", kFailureMarker, failures);
    return 1;
  }
  return 0;
}
