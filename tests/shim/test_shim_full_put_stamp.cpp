// F6.4 `full-put-stamp` (docs/SHIM_SUITE_CONVENTION.md S5.6): the stored
// DD-version stamp survives a full put issued by a mismatched HLI.
//
// Against a private copy of the older-DD (3.39.0) pulse opened by the
// newer-DD (4.1.1) HLI, this program reads the occurrence, sets a marker
// value at `vacuum_toroidal_field/r0` -- the field the generated traversal
// reaches immediately after `ids_properties` -- and issues a **full put**.
// This MUST stay a full put: `putSlice` has an empty body for
// `ids_properties/version_put/data_dictionary`, the DD-version stamp, and
// never reaches it at all, so a slice put could never exercise either seam
// this test asserts.
//
// A full put's generated `put()` opens by calling its own `deleteAll()`,
// which deletes every field of the previous occurrence -- except the stamp:
// a delete that would remove `ids_properties/version_put/data_dictionary`
// while data remains is refused. `put()` then reopens a write context and
// rewrites every field from the in-memory IDS, including the stamp itself,
// hardcoded to this HLI's own compiled DD version ("4.1.1"); under a stamp
// mismatch that write is refused too. Each refusal is tolerated
// independently and both land in the same `skippedPaths` record (full put
// retains tolerated deletes from its own `deleteAll()` before appending the
// tolerated writes that follow), so this program asserts each on its own
// counter rather than trusting the summary `PARTIAL_PUT` status to tell them
// apart: either refusal alone already makes the status partial, so the
// status alone cannot say whether both seams -- or only one -- refused.
//
// This is the scenario whose result depends on which IMAS-Core is loaded
// (docs/SHIM_SUITE_CONVENTION.md S1 D5, tests/shim/README.md): against a
// core whose HDF5 delete ignores its `path` argument, the first delete a
// full put issues destroys the whole occurrence instead of sparing the
// stamp, the refused stamp delete then protects nothing, the stamp probe
// that follows finds no occurrence, an absent stamp is presumed to match, no
// conversion is armed, and every write becomes an untranslated forward. A
// red result here implicates the loaded IMAS-Core, not this repository or
// the shim.
#include "ALClasses.h"
#include "shim_fixture_uri.h"
#include "shim_run_guard.h"

#include <cmath>
#include <cstdio>
#include <string>

namespace {

constexpr const char* kFailureMarker = "FULL-PUT-STAMP-FAILURE";
constexpr int kExpectedAssertions = 10;
constexpr double kMarkerR0 = 918273.645;
// The relative path both the refused delete and the refused write name --
// see `equilibrium_IDSBase.cpp`'s generated `ids_properties::version_put`
// `deleteAll`/`put`: `fieldPath = "ids_properties/version_put/data_dictionary"`.
constexpr const char* kStampFieldPath = "ids_properties/version_put/data_dictionary";
// The fixture's own stamp, and the only value the stamp may still read after
// this scenario -- not this HLI's compiled DD version.
constexpr const char* kStoredStampVersion = "3.39.0";

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

  IdsNs::IDS ids;
  expect(ids.open(uri, OPEN_PULSE) == 0, "could not open the private fixture", assertions,
         failures);

  const int initialGetStatus = ids._equilibrium.get();
  expect(initialGetStatus == 0 || initialGetStatus == IdsNs::PARTIAL_READ,
         "the pre-put whole-occurrence read neither succeeded nor partially succeeded",
         assertions, failures);
  expect(ids._equilibrium.ids_properties.version_put.data_dictionary == kStoredStampVersion,
         "the fixture did not begin with the older DD's own stamp", assertions, failures);

  // The marker: any field the traversal reaches after ids_properties, so its
  // readback proves the write traversal ran past the refused stamp write
  // rather than aborting there.
  ids._equilibrium.vacuum_toroidal_field.r0 = kMarkerR0;

  const int putStatus = ids._equilibrium.put();

  // Read out all three counters here, before the readback below opens a new
  // handle and issues further calls that could otherwise be mistaken for
  // having disturbed this record.
  const auto& skippedPaths = ids._equilibrium.getSkippedPaths();
  bool deleteRefused = false;
  bool writeRefused = false;
  for (const auto& skipped : skippedPaths) {
    if (skipped.path != kStampFieldPath) {
      continue;
    }
    if (skipped.operation == IdsNs::SkippedPath::Operation::Delete) {
      deleteRefused = true;
    } else if (skipped.operation == IdsNs::SkippedPath::Operation::Write) {
      writeRefused = true;
    }
  }
  // 1. The delete seam refused.
  expect(deleteRefused,
         "no recorded skipped path was the refused Delete of the DD-version stamp", assertions,
         failures);
  // 2. The write seam refused.
  expect(writeRefused, "no recorded skipped path was the refused Write of the DD-version stamp",
         assertions, failures);
  // 3. The status is the derived summary of 1 and 2, not primary evidence for
  // either.
  expect(putStatus == IdsNs::PARTIAL_PUT, "the full put did not report a partial put", assertions,
         failures);
  // `IdsNs::Ids::mustAbort` (src/IdsDef.cpp) already printed both "REFUSED
  // DELETE: ids_properties/version_put/data_dictionary" and "REFUSED WRITE:
  // ids_properties/version_put/data_dictionary" to standard output while
  // tolerating these two refusals -- the CTest wrapper matches both,
  // confirming they were named by the traversal that tolerated them.
  ids.close();

  // 4. The traversal finished and the stored stamp survived.
  IdsNs::IDS readback;
  expect(readback.open(uri, OPEN_PULSE) == 0, "could not reopen the private fixture for readback",
         assertions, failures);
  const int readbackStatus = readback._equilibrium.get();
  expect(readbackStatus == 0 || readbackStatus == IdsNs::PARTIAL_READ,
         "the post-put whole-occurrence read neither succeeded nor partially succeeded",
         assertions, failures);
  expect(std::fabs(readback._equilibrium.vacuum_toroidal_field.r0 - kMarkerR0) < 1e-9,
         "the marker field after ids_properties did not read back, so the traversal did not finish",
         assertions, failures);
  expect(readback._equilibrium.ids_properties.version_put.data_dictionary == kStoredStampVersion,
         "the stamp no longer names the stored version after the full put", assertions, failures);
  readback.close();

  ShimTest::assertRanCount(kFailureMarker, "F6.4 assertions", assertions, kExpectedAssertions,
                           failures);
  if (failures != 0) {
    std::printf("%s: %d F6.4 expectation(s) failed\n", kFailureMarker, failures);
    return 1;
  }
  return 0;
}
