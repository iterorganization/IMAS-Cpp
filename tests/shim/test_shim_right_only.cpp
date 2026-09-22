// Family 4.3 (docs/SHIM_SUITE_CONVENTION.md S5.4): the 13 paths the newer
// dictionary introduced, read exclusively through the public C++ HLI. The DD
// 4.1.1 fixture is the same-version oracle; DD 3.39.0 is read through the
// shim and has nothing to build these paths from.
#include "ALClasses.h"
#include "shim_paired_read.h"
#include "shim_rule_check.h"
#include "shim_rule_table.h"

#include <array>
#include <cstdio>
#include <cstring>
#include <vector>

namespace {

constexpr const char* kFailureMarker = "RIGHT-ONLY-FAILURE";
constexpr int kExpectedPreconditions = 5;
using Equilibrium = IdsNs::IDS::equilibrium;

// The anchor rule the vacuity demonstration reuses: a plain scalar, so its
// converted reading is established served-nothing without any
// array-of-structures indexing hazard of its own.
constexpr const char* kVacuityAnchorRuleId = "new-boundary-rho-tor";
// A real structural-table entry (docs/SHIM_SUITE_CONVENTION.md F4.3): its
// oracle value is a genuine, non-empty reading the anchor's served-nothing
// reading is compared against.
constexpr const char* kVacuityStructuralRuleId = "identical-vacuum-r0";

template <typename T>
struct OracleValue {
  const T& value;
};

template <typename T>
struct ConvertedValue {
  const T& value;
};

using OracleEquilibrium = OracleValue<Equilibrium>;
using ConvertedEquilibrium = ConvertedValue<Equilibrium>;

template <typename T>
OracleValue<T> oracleValue(const T& value) {
  return {value};
}

template <typename T>
ConvertedValue<T> convertedValue(const T& value) {
  return {value};
}

std::vector<double> scalarReading(double value) {
  return value == EMPTY_DOUBLE ? std::vector<double>{} : std::vector<double>{value};
}

std::vector<double> scalarReadingInt(int value) {
  return value == EMPTY_INT ? std::vector<double>{} : std::vector<double>{static_cast<double>(value)};
}

template <int Rank>
std::vector<double> arrayReading(const IMASArray<double, Rank>& values) {
  const std::size_t count = static_cast<std::size_t>(values.numElements());
  return count == 0 ? std::vector<double>{} : std::vector<double>(values.data(), values.data() + count);
}

template <int Rank>
std::vector<double> arrayReadingInt(const IMASArray<int, Rank>& values) {
  const std::size_t count = static_cast<std::size_t>(values.numElements());
  if (count == 0) return {};
  std::vector<double> out(count);
  const int* data = values.data();
  for (std::size_t i = 0; i < count; ++i) out[i] = static_cast<double>(data[i]);
  return out;
}

ShimTest::Verdict compareReadings(OracleValue<std::vector<double>> oracle,
                                  ConvertedValue<std::vector<double>> converted) {
  return ShimTest::Compare(/*oracle=*/ ShimTest::OracleReading(oracle.value),
                           /*converted=*/ ShimTest::ConvertedReading(converted.value));
}

ShimTest::Verdict scalarVerdict(OracleValue<double> oracle, ConvertedValue<double> converted) {
  return compareReadings(/*oracle=*/ oracleValue(scalarReading(oracle.value)),
                         /*converted=*/ convertedValue(scalarReading(converted.value)));
}

ShimTest::Verdict scalarVerdictInt(OracleValue<int> oracle, ConvertedValue<int> converted) {
  return compareReadings(/*oracle=*/ oracleValue(scalarReadingInt(oracle.value)),
                         /*converted=*/ convertedValue(scalarReadingInt(converted.value)));
}

template <int Rank>
ShimTest::Verdict arrayVerdict(OracleValue<IMASArray<double, Rank>> oracle,
                               ConvertedValue<IMASArray<double, Rank>> converted) {
  return compareReadings(/*oracle=*/ oracleValue(arrayReading(oracle.value)),
                         /*converted=*/ convertedValue(arrayReading(converted.value)));
}

template <int Rank>
ShimTest::Verdict arrayVerdictInt(OracleValue<IMASArray<int, Rank>> oracle,
                                  ConvertedValue<IMASArray<int, Rank>> converted) {
  return compareReadings(/*oracle=*/ oracleValue(arrayReadingInt(oracle.value)),
                         /*converted=*/ convertedValue(arrayReadingInt(converted.value)));
}

// Basic containers a partial cross-version read must still reach, whatever
// it could not build.
bool hasBasicContainers(const Equilibrium& equilibrium) {
  return equilibrium.time.extent(0) > 0 && equilibrium.time_slice.extent(0) > 0;
}

// The one right-only path this file indexes into an array-of-structures
// element for (constraints/j_parallel): the oracle side MUST have a real
// entry to prove its rule is not vacuous. The converted side is expected to
// have none -- that emptiness is the property under test, not a precondition
// to require.
bool hasRequiredContainers(const Equilibrium& equilibrium) {
  return equilibrium.time_slice(0).constraints.j_parallel.extent(0) > 0;
}

#define RIGHT_ONLY_RULE_SIDES \
  const Equilibrium& oracle = namedOracle.value; \
  const Equilibrium& converted = namedConverted.value

using RuleEvaluator = ShimTest::Verdict (*)(OracleEquilibrium, ConvertedEquilibrium);

struct RightOnlyCheck {
  const char* id;
  RuleEvaluator evaluate;
};

ShimTest::Verdict evaluateContourTree(OracleEquilibrium namedOracle, ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  // `edges` sits directly on the contour_tree struct, a sibling of the new
  // `node` array-of-structures, so reading it never indexes into an AoS
  // element that might not exist on the converted side.
  return arrayVerdictInt(/*oracle=*/ oracleValue(oracle.time_slice(0).contour_tree.edges),
                         /*converted=*/ convertedValue(converted.time_slice(0).contour_tree.edges));
}

ShimTest::Verdict evaluateConstraintsJParallel(OracleEquilibrium namedOracle,
                                               ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  const double oracleMeasured = oracle.time_slice(0).constraints.j_parallel(0).measured;
  // Guarded: unlike every shared array-of-structures this suite indexes
  // elsewhere, j_parallel has no DD 3 source, so the converted side is
  // expected to have never been resized. Indexing element 0 unconditionally
  // would read out of bounds instead of reporting the absence this rule
  // exists to check.
  const double convertedMeasured = converted.time_slice(0).constraints.j_parallel.extent(0) > 0
                                        ? converted.time_slice(0).constraints.j_parallel(0).measured
                                        : EMPTY_DOUBLE;
  return scalarVerdict(/*oracle=*/ oracleValue(oracleMeasured),
                       /*converted=*/ convertedValue(convertedMeasured));
}

ShimTest::Verdict evaluateConvergenceResult(OracleEquilibrium namedOracle,
                                            ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  return scalarVerdictInt(/*oracle=*/ oracleValue(oracle.time_slice(0).convergence.result.index),
                          /*converted=*/ convertedValue(converted.time_slice(0).convergence.result.index));
}

ShimTest::Verdict evaluateBoundaryRhoTor(OracleEquilibrium namedOracle, ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).boundary.rho_tor),
                       /*converted=*/ convertedValue(converted.time_slice(0).boundary.rho_tor));
}

ShimTest::Verdict evaluateBoundaryPhi(OracleEquilibrium namedOracle, ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).boundary.phi),
                       /*converted=*/ convertedValue(converted.time_slice(0).boundary.phi));
}

ShimTest::Verdict evaluateBoundaryPhiPoloidalCurrent(OracleEquilibrium namedOracle,
                                                     ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  return scalarVerdict(
      /*oracle=*/ oracleValue(oracle.time_slice(0).boundary.phi_poloidal_current),
      /*converted=*/ convertedValue(converted.time_slice(0).boundary.phi_poloidal_current));
}

ShimTest::Verdict evaluateQMinPsi(OracleEquilibrium namedOracle, ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).global_quantities.q_min.psi),
                       /*converted=*/ convertedValue(converted.time_slice(0).global_quantities.q_min.psi));
}

ShimTest::Verdict evaluateQMinPsiNorm(OracleEquilibrium namedOracle, ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  return scalarVerdict(
      /*oracle=*/ oracleValue(oracle.time_slice(0).global_quantities.q_min.psi_norm),
      /*converted=*/ convertedValue(converted.time_slice(0).global_quantities.q_min.psi_norm));
}

ShimTest::Verdict evaluateRhoTorBoundary(OracleEquilibrium namedOracle, ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  return scalarVerdict(
      /*oracle=*/ oracleValue(oracle.time_slice(0).global_quantities.rho_tor_boundary),
      /*converted=*/ convertedValue(converted.time_slice(0).global_quantities.rho_tor_boundary));
}

ShimTest::Verdict evaluateChiSquaredReduced(OracleEquilibrium namedOracle,
                                            ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).constraints.chi_squared_reduced),
                       /*converted=*/ convertedValue(converted.time_slice(0).constraints.chi_squared_reduced));
}

ShimTest::Verdict evaluateFreedomDegreesN(OracleEquilibrium namedOracle, ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  return scalarVerdictInt(
      /*oracle=*/ oracleValue(oracle.time_slice(0).constraints.freedom_degrees_n),
      /*converted=*/ convertedValue(converted.time_slice(0).constraints.freedom_degrees_n));
}

ShimTest::Verdict evaluateConstraintsN(OracleEquilibrium namedOracle, ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  return scalarVerdictInt(/*oracle=*/ oracleValue(oracle.time_slice(0).constraints.constraints_n),
                          /*converted=*/ convertedValue(converted.time_slice(0).constraints.constraints_n));
}

ShimTest::Verdict evaluateProfiles1dPsiNorm(OracleEquilibrium namedOracle,
                                            ConvertedEquilibrium namedConverted) {
  RIGHT_ONLY_RULE_SIDES;
  return arrayVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).profiles_1d.psi_norm),
                      /*converted=*/ convertedValue(converted.time_slice(0).profiles_1d.psi_norm));
}

constexpr std::array<RightOnlyCheck, 13> kRightOnlyChecks{{
    {"new-contour-tree", evaluateContourTree},
    {"new-constraints-j-parallel", evaluateConstraintsJParallel},
    {"new-convergence-result", evaluateConvergenceResult},
    {"new-boundary-rho-tor", evaluateBoundaryRhoTor},
    {"new-boundary-phi", evaluateBoundaryPhi},
    {"new-boundary-phi-poloidal-current", evaluateBoundaryPhiPoloidalCurrent},
    {"new-q-min-psi", evaluateQMinPsi},
    {"new-q-min-psi-norm", evaluateQMinPsiNorm},
    {"new-global-quantities-rho-tor-boundary", evaluateRhoTorBoundary},
    {"new-constraints-chi-squared-reduced", evaluateChiSquaredReduced},
    {"new-constraints-freedom-degrees-n", evaluateFreedomDegreesN},
    {"new-constraints-constraints-n", evaluateConstraintsN},
    {"new-profiles-1d-psi-norm", evaluateProfiles1dPsiNorm},
}};

#undef RIGHT_ONLY_RULE_SIDES

const ShimRuleTable::Rule* findStructuralRule(const char* id) {
  for (const ShimRuleTable::Rule& rule : ShimRuleTable::structuralRules()) {
    if (std::strcmp(rule.id, id) == 0) return &rule;
  }
  return nullptr;
}

}  // namespace

int main(int argc, char* argv[]) {
  if (argc != 2) {
    std::printf("%s: usage: <fixture-root>\n", kFailureMarker);
    return 1;
  }

  const auto& rules = ShimRuleTable::rightOnlyRules();
  ShimTest::RuleChecker checker(kFailureMarker, rules.data(), rules.size());
  if (kRightOnlyChecks.size() != rules.size()) {
    checker.fail("the right-only check loop and rule table have different sizes");
  }

  IdsNs::IDS convertedIds;
  IdsNs::IDS oracleIds;
  const ShimTest::PairedRead read = ShimTest::openPairedRead(convertedIds, oracleIds, argv[1]);
  ShimTest::expectPairedReadUsable(
      checker, read,
      hasBasicContainers(oracleIds._equilibrium) &&
          hasBasicContainers(convertedIds._equilibrium) &&
          hasRequiredContainers(oracleIds._equilibrium),
      "a read did not reach every container the right-only rules index into");

  if (checker.failures() == 0) {
    // Looked up through the checker rather than rescanned here: the named
    // finding below needs the Rule's own id and citation, and an id the table
    // does not hold must be reported, not skipped.
    for (const RightOnlyCheck& check : kRightOnlyChecks) {
      const ShimRuleTable::Rule* found = checker.find(check.id);
      if (found == nullptr) {
        checker.failUnknownRule(check.id);
        continue;
      }
      const ShimRuleTable::Rule& rule = *found;
      const ShimTest::Verdict verdict = check.evaluate(oracleValue(oracleIds._equilibrium),
                                                       convertedValue(convertedIds._equilibrium));
      // docs/SHIM_SUITE_CONVENTION.md S2.1 (C1): a field the shim served
      // nothing for must read back as absent, never as a plausible
      // number. Every verdict except Absent and the expected OnlyOracle
      // means the converted side held *some* value -- a mismatch this
      // suite must never fold silently into an ordinary rule failure,
      // because IMAS-Fortran found exactly this shape of bug (uninitialised
      // memory landing on a never-served field) and it reads, to a
      // caller doing `!= invalid`, as a served field. Named here as its
      // own finding, not routed around.
      if (verdict != ShimTest::Verdict::OnlyOracle && verdict != ShimTest::Verdict::Absent) {
        std::printf(
            "%s: finding: %s (%s) served a value for a path the newer dictionary "
            "introduced (verdict=%s) -- see docs/SHIM_SUITE_CONVENTION.md S2.1\n",
            kFailureMarker, rule.id, rule.citation, ShimTest::verdictName(verdict));
      }
      checker.check(check.id, verdict);
    }

    // Vacuity demonstration (docs/SHIM_SUITE_CONVENTION.md D6, F4.3): a shim
    // that served nothing at all would pass every right-only rule above for
    // the wrong reason, because absence is exactly what those rules expect.
    // Take the anchor rule's converted reading -- the ordinary check above
    // has just established it is genuinely served-nothing -- and run it
    // through the same Compare() predicate every rule check uses, paired
    // against a real oracle value from an unrelated structural rule. A
    // silently-broken shim's absence must fail that rule's own agreement
    // expectation; if it did not, this family's checks would be vacuous.
    const bool anchorRuleFound = checker.find(kVacuityAnchorRuleId) != nullptr;
    const ShimTest::ConvertedReading anchorReading(
        scalarReading(convertedIds._equilibrium.time_slice(0).boundary.rho_tor));
    checker.expect(anchorRuleFound && !anchorReading.present(),
                   "the vacuity anchor's converted reading was not genuinely served-nothing, "
                   "or the cited anchor rule id is missing from the right-only table");

    const ShimRuleTable::Rule* vacuityRule = findStructuralRule(kVacuityStructuralRuleId);
    const ShimTest::OracleReading vacuityOracle(
        scalarReading(oracleIds._equilibrium.vacuum_toroidal_field.r0));
    const bool vacuityDemonstrated =
        vacuityRule != nullptr &&
        ShimTest::Compare(/*oracle=*/ vacuityOracle, /*converted=*/ anchorReading) !=
            ShimRuleTable::expectedVerdict(vacuityRule->kind);
    checker.expect(vacuityDemonstrated,
                   "a served-nothing reading satisfied a real structural rule's agreement "
                   "expectation, or the cited structural rule id is missing");
  }

  convertedIds.close();
  oracleIds.close();
  checker.assertPreconditionCount(kExpectedPreconditions);
  checker.assertEveryRuleChecked();
  if (checker.failures() != 0) {
    std::printf("%s: %d right-only rule assertion(s) failed\n", kFailureMarker, checker.failures());
    return 1;
  }
  return 0;
}
