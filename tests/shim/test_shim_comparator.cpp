// The comparator's own unit test (F1.2, docs/SHIM_SUITE_CONVENTION.md
// S4.4): a synthetic truth table driven from literals, self-contained -- no
// rule table, no fixture, no pulse. A pulse-based test can never prove its
// own oracle right, so every case below states its expected verdict
// independently, from values written in this file.
//
// Every call to Compare() below names both arguments with an adjacent
// oracle= / converted= comment. The source check
// cpp-test-shim-verdict-orientation (check_verdict_orientation.cmake)
// counts these comments across tests/shim/ and fails below a floor, so this
// file is also this ticket's first contribution to that count.
#include "shim_comparator.h"
#include "shim_run_guard.h"

#include <cmath>
#include <cstdio>

namespace {

void ExpectVerdict(const char* case_name, ShimTest::Verdict expected, ShimTest::Verdict actual,
                    int& failures) {
  if (expected == actual) {
    return;
  }
  ++failures;
  std::printf("COMPARATOR-FAILURE: %s: expected verdict %d, got %d\n", case_name,
              static_cast<int>(expected), static_cast<int>(actual));
}

}  // namespace

int main() {
  using ShimTest::Compare;
  using ShimTest::ConvertedReading;
  using ShimTest::OracleReading;
  using ShimTest::Verdict;

  int failures = 0;
  int cases = 0;

  // The empty-vs-empty trap (S4.2): two readings with nothing in them must
  // not compare as agreement. If presence were asserted by the caller
  // instead of derived from the reading, this would silently become SAME.
  {
    ExpectVerdict("absent-both-empty", Verdict::Absent,
                  Compare(/*oracle=*/OracleReading{}, /*converted=*/ConvertedReading{}), failures);
    ++cases;
  }

  // Absence, both orientations: only the oracle has a value, and only the
  // converted reading has a value. Distinct verdicts so a failure names
  // which side went missing.
  {
    ExpectVerdict(
        "only-oracle",
        Verdict::OnlyOracle,
        Compare(/*oracle=*/OracleReading{{1.0}}, /*converted=*/ConvertedReading{}),
        failures);
    ++cases;
  }
  {
    ExpectVerdict(
        "only-converted",
        Verdict::OnlyConverted,
        Compare(/*oracle=*/OracleReading{}, /*converted=*/ConvertedReading{{2.0}}),
        failures);
    ++cases;
  }

  // Agreement: a scalar and a multi-element reading, both equal.
  {
    ExpectVerdict(
        "same-scalar",
        Verdict::Same,
        Compare(/*oracle=*/OracleReading{{3.5}}, /*converted=*/ConvertedReading{{3.5}}),
        failures);
    ++cases;
  }
  {
    ExpectVerdict(
        "same-array",
        Verdict::Same,
        Compare(/*oracle=*/OracleReading{{1.0, 2.0, 3.0}},
                /*converted=*/ConvertedReading{{1.0, 2.0, 3.0}}),
        failures);
    ++cases;
  }

  // A required sign flip that did not happen, both orientations of which
  // side carries the positive value. NoFlip carries mismatch severity: it
  // is never treated as a pass by any caller of this comparator.
  {
    ExpectVerdict(
        "noflip-oracle-positive",
        Verdict::NoFlip,
        Compare(/*oracle=*/OracleReading{{4.0}}, /*converted=*/ConvertedReading{{-4.0}}),
        failures);
    ++cases;
  }
  {
    ExpectVerdict(
        "noflip-oracle-negative",
        Verdict::NoFlip,
        Compare(/*oracle=*/OracleReading{{-4.0}}, /*converted=*/ConvertedReading{{4.0}}),
        failures);
    ++cases;
  }

  // A genuine mismatch: neither equal nor uniformly sign-flipped. The array
  // case has one element that looks flipped and one that does not, so a
  // comparator that checked only the first element would wrongly call this
  // NoFlip.
  {
    ExpectVerdict(
        "diff-scalar",
        Verdict::Diff,
        Compare(/*oracle=*/OracleReading{{1.0}}, /*converted=*/ConvertedReading{{2.0}}),
        failures);
    ++cases;
  }
  {
    ExpectVerdict(
        "diff-partial-flip",
        Verdict::Diff,
        Compare(/*oracle=*/OracleReading{{1.0, 2.0}}, /*converted=*/ConvertedReading{{-1.0, 3.0}}),
        failures);
    ++cases;
  }

  // Different element counts: the shape/flatten behaviour of S4.4. Both
  // orientations, because a comparator deriving the shape verdict from one
  // side's extent alone -- rather than from the two disagreeing -- would pass
  // whichever single case happened to be written.
  {
    ExpectVerdict(
        "shape-converted-longer",
        Verdict::Shape,
        Compare(/*oracle=*/OracleReading{{1.0, 2.0}}, /*converted=*/ConvertedReading{{1.0, 2.0, 3.0}}),
        failures);
    ++cases;
  }
  {
    ExpectVerdict(
        "shape-oracle-longer",
        Verdict::Shape,
        Compare(/*oracle=*/OracleReading{{1.0, 2.0, 3.0}}, /*converted=*/ConvertedReading{{1.0, 2.0}}),
        failures);
    ++cases;
  }

  // A NaN element must never satisfy either the equality or the sign-flip
  // check: comparing a NaN with `>` is always false, so a same/flipped
  // accumulator that only ever clears on a `>` hit would wrongly leave both
  // true and report Same.
  {
    ExpectVerdict(
        "diff-nan",
        Verdict::Diff,
        Compare(/*oracle=*/OracleReading{{std::nan("")}}, /*converted=*/ConvertedReading{{1.0}}),
        failures);
    ++cases;
  }

  ShimTest::assertRanCount("COMPARATOR-FAILURE", "truth-table cases run", cases, 12, failures);

  if (failures > 0) {
    std::printf("COMPARATOR-FAILURE: %d expectation(s) failed\n", failures);
    return 1;
  }
  return 0;
}
