// Self-test for the run guard every other program in this suite relies on
// (shim_run_guard.h). A pulse-based test can never prove its own guard
// right, so this program drives it from literals -- the same reasoning
// docs/SHIM_SUITE_CONVENTION.md S4.4 applies to the comparison oracle,
// applied here to the infrastructure D6 asks every program to carry.
//
// Each demonstration below runs on its own counter, so a mismatch it
// deliberately provokes cannot be mistaken for a shortfall in this program's
// own run guard at the bottom.
//
// The demonstrations pass a marker distinct from "RUN-GUARD-FAILURE" (the
// one this program's own failures use, and the one ctest's
// FAIL_REGULAR_EXPRESSION matches): the deliberately provoked shortfall
// below prints through the very code path being tested, and it must not be
// mistaken for a real failure of this test by a plain text search over
// ctest's combined output.
#include "shim_run_guard.h"

#include <cstdio>

int main() {
  int failures = 0;
  int demonstrations = 0;

  // A run that reports exactly what it declared must not be flagged.
  {
    int matched = 0;
    ShimTest::assertRanCount("run-guard-demonstration", "matched cases", 3, 3, matched);
    ++demonstrations;
    if (matched != 0) {
      std::printf("RUN-GUARD-FAILURE: a matching count was flagged as a shortfall\n");
      ++failures;
    }
  }

  // A run that ran fewer assertions than it declared -- the failure mode
  // this scaffold exists to catch -- must be flagged.
  {
    int shortfall = 0;
    ShimTest::assertRanCount("run-guard-demonstration", "demonstration cases", 2, 3, shortfall);
    ++demonstrations;
    if (shortfall == 0) {
      std::printf("RUN-GUARD-FAILURE: a 2-of-3 shortfall was not flagged\n");
      ++failures;
    }
  }

  ShimTest::assertRanCount("RUN-GUARD-FAILURE", "guard demonstrations ran", demonstrations, 2, failures);

  if (failures > 0) {
    std::printf("RUN-GUARD-FAILURE: %d expectation(s) failed\n", failures);
    return 1;
  }
  return 0;
}
