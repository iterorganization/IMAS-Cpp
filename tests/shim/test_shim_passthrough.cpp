// Family 2 (docs/SHIM_SUITE_CONVENTION.md S5.2): four separate processes in
// which the multiversion shim must leave an equilibrium read untouched.
//
// `stamp-mismatch-no-artifact` is deliberately indistinguishable from
// `stamp-equal` by its observable result. It remains its own scenario to make
// the no-artifact passthrough rule explicit, not because it can prove a
// difference from an equal stamp.
#include "ALClasses.h"
#include "shim_run_guard.h"

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <string>

namespace {

enum class Scenario { VersionUnset, StampEqual, StampAbsent, StampMismatchNoArtifact };

bool parseScenario(const char* text, Scenario& scenario) {
  const std::string value(text);
  if (value == "version-unset") {
    scenario = Scenario::VersionUnset;
  } else if (value == "stamp-equal") {
    scenario = Scenario::StampEqual;
  } else if (value == "stamp-absent") {
    scenario = Scenario::StampAbsent;
  } else if (value == "stamp-mismatch-no-artifact") {
    scenario = Scenario::StampMismatchNoArtifact;
  } else {
    return false;
  }
  return true;
}

void expect(bool condition, const char* detail, int& assertions, int& failures) {
  ++assertions;
  if (!condition) {
    ++failures;
    std::printf("PASSTHROUGH-FAILURE: %s\n", detail);
  }
}

}  // namespace

int main(int argc, char* argv[]) {
  if (argc != 3) {
    std::printf("PASSTHROUGH-FAILURE: usage: <scenario> <fixture-directory>\n");
    return 1;
  }

  Scenario scenario;
  if (!parseScenario(argv[1], scenario)) {
    std::printf("PASSTHROUGH-FAILURE: unknown scenario %s\n", argv[1]);
    return 1;
  }

  const bool versionUnset = scenario == Scenario::VersionUnset;
  const bool renamedFieldMustRemainAbsent =
      versionUnset || scenario == Scenario::StampMismatchNoArtifact;
  const char* hliVersion = std::getenv("IMAS_MVDD_HLI_DD_VERSION");

  int assertions = 0;
  int failures = 0;
  expect(versionUnset ? hliVersion == nullptr : hliVersion != nullptr && hliVersion[0] != '\0',
         versionUnset ? "the version-unset process inherited an HLI DD version"
                      : "the opted-in process has no HLI DD version",
         assertions, failures);

  IdsNs::IDS ids;
  const std::string uri = std::string("imas:hdf5?path=") + argv[2];
  expect(ids.open(uri, OPEN_PULSE) == 0, "data-entry open did not forward cleanly", assertions,
         failures);

  const int getStatus = ids._equilibrium.get();
  expect(getStatus == 0, "occurrence read did not return clean success", assertions, failures);
  expect(ids._equilibrium.getSkippedPathCount() == 0,
         "an untouched read recorded refused paths", assertions, failures);
  expect(ids._equilibrium.time.extent(0) == 2, "the expected two time samples did not arrive",
         assertions, failures);
  expect(ids._equilibrium.time.extent(0) == 2 &&
             std::fabs(ids._equilibrium.time(0) - 1.0) < 1e-12 &&
             std::fabs(ids._equilibrium.time(1) - 1.5) < 1e-12,
         "the received time samples differ from the fixture", assertions, failures);

  if (renamedFieldMustRemainAbsent) {
    expect(ids._equilibrium.time_slice.extent(0) > 0 &&
               ids._equilibrium.time_slice(0).global_quantities.beta_tor_norm == EMPTY_DOUBLE,
           "the newer-DD-only beta_tor_norm field was populated", assertions, failures);
  }

  ids.close();

  const int expectedAssertions = renamedFieldMustRemainAbsent ? 7 : 6;
  ShimTest::assertRanCount("PASSTHROUGH-FAILURE", "passthrough assertions run", assertions,
                           expectedAssertions, failures);
  if (failures > 0) {
    std::printf("PASSTHROUGH-FAILURE: %d expectation(s) failed\n", failures);
    return 1;
  }
  return 0;
}
