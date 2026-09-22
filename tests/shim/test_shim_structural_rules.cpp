// Family 4.1 (docs/SHIM_SUITE_CONVENTION.md S5.4): structural conversion
// rules read exclusively through the public C++ HLI.  The DD 4.1.1 fixture
// is the same-version oracle; DD 3.39.0 is read through the shim.
#include "ALClasses.h"
#include "shim_paired_read.h"
#include "shim_rule_check.h"
#include "shim_rule_table.h"

#include <array>
#include <cstdio>
#include <vector>

namespace {

constexpr const char* kFailureMarker = "STRUCTURAL-FAILURE";
constexpr int kExpectedPreconditions = 3;
using Equilibrium = IdsNs::IDS::equilibrium;

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

#define STRUCTURAL_RULE_SIDES \
  const Equilibrium& oracle = namedOracle.value; \
  const Equilibrium& converted = namedConverted.value

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

template <int Rank>
std::vector<double> arrayReading(const IMASArray<double, Rank>& values) {
  const std::size_t count = static_cast<std::size_t>(values.numElements());
  return count == 0 ? std::vector<double>{} : std::vector<double>(values.data(), values.data() + count);
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

template <int Rank>
ShimTest::Verdict arrayVerdict(OracleValue<IMASArray<double, Rank>> oracle,
                               ConvertedValue<IMASArray<double, Rank>> converted) {
  return compareReadings(/*oracle=*/ oracleValue(arrayReading(oracle.value)),
                         /*converted=*/ convertedValue(arrayReading(converted.value)));
}

ShimTest::Verdict firstNonAgreeing(const ShimRuleTable::Rule& rule, ShimTest::Verdict first,
                                   ShimTest::Verdict second) {
  return first == ShimRuleTable::expectedVerdict(rule.kind) ? second : first;
}

bool hasRequiredContainers(const Equilibrium& equilibrium) {
  if (equilibrium.time.extent(0) == 0 || equilibrium.time_slice.extent(0) == 0) return false;
  const auto& slice = equilibrium.time_slice(0);
  return slice.constraints.b_field_pol_probe.extent(0) > 0 &&
         slice.constraints.mse_polarization_angle.extent(0) > 0 &&
         slice.constraints.iron_core_segment.extent(0) > 0 && slice.boundary.gap.extent(0) > 0 &&
         slice.profiles_2d.extent(0) > 0 && slice.constraints.j_phi.extent(0) > 0 &&
         slice.ggd.extent(0) > 0 && slice.ggd(0).j_phi.extent(0) > 0 &&
         slice.ggd(0).b_field_phi.extent(0) > 0;
}

using RuleEvaluator = ShimTest::Verdict (*)(const ShimRuleTable::Rule&, OracleEquilibrium,
                                             ConvertedEquilibrium);

struct StructuralCheck {
  const char* id;
  RuleEvaluator evaluate;
};

ShimTest::Verdict evaluateVacuumR0(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                   ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(oracle.vacuum_toroidal_field.r0),
                       /*converted=*/ convertedValue(converted.vacuum_toroidal_field.r0));
}

ShimTest::Verdict evaluateTime(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                               ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return arrayVerdict(/*oracle=*/ oracleValue(oracle.time),
                      /*converted=*/ convertedValue(converted.time));
}

ShimTest::Verdict evaluateBetaPol(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                  ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).global_quantities.beta_pol),
                       /*converted=*/ convertedValue(converted.time_slice(0).global_quantities.beta_pol));
}

ShimTest::Verdict evaluateBetaTorNorm(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                      ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).global_quantities.beta_tor_norm),
                       /*converted=*/ convertedValue(converted.time_slice(0).global_quantities.beta_tor_norm));
}

ShimTest::Verdict evaluateBpolProbe(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                    ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).constraints.b_field_pol_probe(0).measured),
                       /*converted=*/ convertedValue(converted.time_slice(0).constraints.b_field_pol_probe(0).measured));
}

ShimTest::Verdict evaluateMsePolarization(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                          ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).constraints.mse_polarization_angle(0).measured),
                       /*converted=*/ convertedValue(converted.time_slice(0).constraints.mse_polarization_angle(0).measured));
}

ShimTest::Verdict evaluateMagnetizationR(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                         ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(
      oracle.time_slice(0).constraints.iron_core_segment(0).magnetization_r.measured),
      /*converted=*/ convertedValue(
          converted.time_slice(0).constraints.iron_core_segment(0).magnetization_r.measured));
}

ShimTest::Verdict evaluateMagnetizationZ(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                         ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(
      oracle.time_slice(0).constraints.iron_core_segment(0).magnetization_z.measured),
      /*converted=*/ convertedValue(
          converted.time_slice(0).constraints.iron_core_segment(0).magnetization_z.measured));
}

ShimTest::Verdict evaluateClosestWallPoint(const ShimRuleTable::Rule& rule, OracleEquilibrium namedOracle,
                                           ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return firstNonAgreeing(rule,
      scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).boundary.closest_wall_point.r),
                    /*converted=*/ convertedValue(converted.time_slice(0).boundary.closest_wall_point.r)),
      scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).boundary.closest_wall_point.z),
                    /*converted=*/ convertedValue(converted.time_slice(0).boundary.closest_wall_point.z)));
}

ShimTest::Verdict evaluateDrDzZeroPoint(const ShimRuleTable::Rule& rule, OracleEquilibrium namedOracle,
                                        ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return firstNonAgreeing(rule,
      scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).boundary.dr_dz_zero_point.r),
                    /*converted=*/ convertedValue(converted.time_slice(0).boundary.dr_dz_zero_point.r)),
      scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).boundary.dr_dz_zero_point.z),
                    /*converted=*/ convertedValue(converted.time_slice(0).boundary.dr_dz_zero_point.z)));
}

ShimTest::Verdict evaluateGap(const ShimRuleTable::Rule& rule, OracleEquilibrium namedOracle,
                              ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return firstNonAgreeing(rule,
      scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).boundary.gap(0).r),
                    /*converted=*/ convertedValue(converted.time_slice(0).boundary.gap(0).r)),
      scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).boundary.gap(0).z),
                    /*converted=*/ convertedValue(converted.time_slice(0).boundary.gap(0).z)));
}

ShimTest::Verdict evaluateP2dBFieldR(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                     ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return arrayVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).profiles_2d(0).b_field_r),
                      /*converted=*/ convertedValue(converted.time_slice(0).profiles_2d(0).b_field_r));
}

ShimTest::Verdict evaluateP2dBFieldZ(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                     ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return arrayVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).profiles_2d(0).b_field_z),
                      /*converted=*/ convertedValue(converted.time_slice(0).profiles_2d(0).b_field_z));
}

ShimTest::Verdict evaluateP2dBFieldPhi(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                       ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return arrayVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).profiles_2d(0).b_field_phi),
                      /*converted=*/ convertedValue(converted.time_slice(0).profiles_2d(0).b_field_phi));
}

ShimTest::Verdict evaluateAxisBFieldPhi(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                        ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).global_quantities.magnetic_axis.b_field_phi),
                       /*converted=*/ convertedValue(converted.time_slice(0).global_quantities.magnetic_axis.b_field_phi));
}

ShimTest::Verdict evaluateP1dBFieldAverage(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                           ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return arrayVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).profiles_1d.b_field_average),
                      /*converted=*/ convertedValue(converted.time_slice(0).profiles_1d.b_field_average));
}

ShimTest::Verdict evaluateP1dBFieldMax(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                       ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return arrayVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).profiles_1d.b_field_max),
                      /*converted=*/ convertedValue(converted.time_slice(0).profiles_1d.b_field_max));
}

ShimTest::Verdict evaluateP1dBFieldMin(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                       ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return arrayVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).profiles_1d.b_field_min),
                      /*converted=*/ convertedValue(converted.time_slice(0).profiles_1d.b_field_min));
}

ShimTest::Verdict evaluateEnergyMhd(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                    ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).global_quantities.energy_mhd),
                       /*converted=*/ convertedValue(converted.time_slice(0).global_quantities.energy_mhd));
}

ShimTest::Verdict evaluateConstraintsJPhi(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                          ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).constraints.j_phi(0).measured),
                       /*converted=*/ convertedValue(converted.time_slice(0).constraints.j_phi(0).measured));
}

ShimTest::Verdict evaluateGgdJPhi(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                  ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return arrayVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).ggd(0).j_phi(0).values),
                      /*converted=*/ convertedValue(converted.time_slice(0).ggd(0).j_phi(0).values));
}

ShimTest::Verdict evaluateGgdBFieldPhi(const ShimRuleTable::Rule&, OracleEquilibrium namedOracle,
                                       ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return arrayVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).ggd(0).b_field_phi(0).values),
                      /*converted=*/ convertedValue(converted.time_slice(0).ggd(0).b_field_phi(0).values));
}

ShimTest::Verdict evaluateSplitPsiAxis(const ShimRuleTable::Rule& rule, OracleEquilibrium namedOracle,
                                       ConvertedEquilibrium namedConverted) {
  STRUCTURAL_RULE_SIDES;
  return firstNonAgreeing(rule,
      scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).global_quantities.psi_axis),
                    /*converted=*/ convertedValue(converted.time_slice(0).global_quantities.psi_axis)),
      scalarVerdict(/*oracle=*/ oracleValue(oracle.time_slice(0).global_quantities.psi_magnetic_axis),
                    /*converted=*/ convertedValue(converted.time_slice(0).global_quantities.psi_magnetic_axis)));
}

constexpr std::array<StructuralCheck, 23> kStructuralChecks{{
    {"identical-vacuum-r0", evaluateVacuumR0}, {"identical-time", evaluateTime},
    {"identical-beta-pol", evaluateBetaPol}, {"rename-beta-normal", evaluateBetaTorNorm},
    {"rename-bpol-probe", evaluateBpolProbe},
    {"rename-mse-polarisation-angle", evaluateMsePolarization},
    {"rename-magnetisation-r", evaluateMagnetizationR},
    {"rename-magnetisation-z", evaluateMagnetizationZ},
    {"move-closest-wall-point", evaluateClosestWallPoint},
    {"move-dr-dz-zero-point", evaluateDrDzZeroPoint}, {"move-gap", evaluateGap},
    {"fold-p2d-br", evaluateP2dBFieldR}, {"fold-p2d-bz", evaluateP2dBFieldZ},
    {"fold-p2d-bphi", evaluateP2dBFieldPhi}, {"fold-axis-bphi", evaluateAxisBFieldPhi},
    {"fold-p1d-baverage", evaluateP1dBFieldAverage},
    {"fold-p1d-bmax", evaluateP1dBFieldMax}, {"fold-p1d-bmin", evaluateP1dBFieldMin},
    {"fold-energy-mhd", evaluateEnergyMhd}, {"fold-constraints-j", evaluateConstraintsJPhi},
    {"fold-ggd-j", evaluateGgdJPhi}, {"fold-ggd-bfield", evaluateGgdBFieldPhi},
    {"split-psi-axis", evaluateSplitPsiAxis},
}};

#undef STRUCTURAL_RULE_SIDES

}  // namespace

int main(int argc, char* argv[]) {
  if (argc != 2) {
    std::printf("%s: usage: <fixture-root>\n", kFailureMarker);
    return 1;
  }

  const auto& rules = ShimRuleTable::structuralRules();
  ShimTest::RuleChecker checker(kFailureMarker, rules.data(), rules.size());
  if (kStructuralChecks.size() != rules.size()) {
    checker.fail("the structural check loop and rule table have different sizes");
  }

  IdsNs::IDS convertedIds;
  IdsNs::IDS oracleIds;
  const ShimTest::PairedRead read = ShimTest::openPairedRead(convertedIds, oracleIds, argv[1]);
  ShimTest::expectPairedReadUsable(
      checker, read,
      hasRequiredContainers(oracleIds._equilibrium) &&
          hasRequiredContainers(convertedIds._equilibrium),
      "a read did not reach every container the structural rules index into");

  if (checker.failures() == 0) {
    // A structural evaluator is handed its Rule, so look it up through the
    // checker rather than rescanning the table here -- and report an id the
    // table does not hold instead of falling through and skipping the check.
    for (const StructuralCheck& check : kStructuralChecks) {
      const ShimRuleTable::Rule* rule = checker.find(check.id);
      if (rule == nullptr) {
        checker.failUnknownRule(check.id);
        continue;
      }
      checker.check(check.id, check.evaluate(*rule,
                                             /*oracle=*/ oracleValue(oracleIds._equilibrium),
                                             /*converted=*/ convertedValue(convertedIds._equilibrium)));
    }
  }

  convertedIds.close();
  oracleIds.close();
  checker.assertPreconditionCount(kExpectedPreconditions);
  checker.assertEveryRuleChecked();
  if (checker.failures() != 0) {
    std::printf("%s: %d structural rule assertion(s) failed\n", kFailureMarker,
                checker.failures());
    return 1;
  }
  return 0;
}
