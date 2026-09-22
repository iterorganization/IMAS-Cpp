// Family 4.2 (docs/SHIM_SUITE_CONVENTION.md S5.4): compare every map-declared
// COCOS sign flip through the public C++ HLI. The DD 4.1.1 fixture is the
// same-version oracle; the DD 3.39.0 fixture is read through the shim.
#include "ALClasses.h"
#include "shim_paired_read.h"
#include "shim_rule_check.h"
#include "shim_rule_table.h"

#include <array>
#include <cstdio>
#include <vector>

namespace {

constexpr const char* kFailureMarker = "COCOS-FAILURE";
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

bool hasRequiredContainers(const Equilibrium& equilibrium) {
  if (equilibrium.time.extent(0) == 0 || equilibrium.time_slice.extent(0) == 0) return false;
  const auto& slice = equilibrium.time_slice(0);
  const auto& constraints = slice.constraints;
  return constraints.flux_loop.extent(0) > 0 && constraints.pf_current.extent(0) > 0 &&
         constraints.j_phi.extent(0) > 0 && constraints.n_e.extent(0) > 0 &&
         constraints.pressure.extent(0) > 0 && constraints.pressure_rotational.extent(0) > 0 &&
         constraints.q.extent(0) > 0 && slice.ggd.extent(0) > 0 &&
         slice.ggd(0).psi.extent(0) > 0 && slice.profiles_2d.extent(0) > 0;
}

using RuleEvaluator = ShimTest::Verdict (*)(OracleEquilibrium, ConvertedEquilibrium);

struct CocosCheck {
  const char* id;
  RuleEvaluator evaluate;
};

#define COCOS_SCALAR_EVALUATOR(name, expression)                                           \
  ShimTest::Verdict name(OracleEquilibrium namedOracle, ConvertedEquilibrium namedConverted) { \
    const Equilibrium& oracle = namedOracle.value;                                          \
    const Equilibrium& converted = namedConverted.value;                                    \
    return scalarVerdict(/*oracle=*/ oracleValue(oracle.expression),                        \
                         /*converted=*/ convertedValue(converted.expression));              \
  }

#define COCOS_ARRAY_EVALUATOR(name, expression)                                            \
  ShimTest::Verdict name(OracleEquilibrium namedOracle, ConvertedEquilibrium namedConverted) { \
    const Equilibrium& oracle = namedOracle.value;                                          \
    const Equilibrium& converted = namedConverted.value;                                    \
    return arrayVerdict(/*oracle=*/ oracleValue(oracle.expression),                         \
                        /*converted=*/ convertedValue(converted.expression));               \
  }

COCOS_SCALAR_EVALUATOR(evaluateBoundaryPsi, time_slice(0).boundary.psi)
COCOS_SCALAR_EVALUATOR(evaluateFluxLoopMeasured, time_slice(0).constraints.flux_loop(0).measured)
COCOS_SCALAR_EVALUATOR(evaluateFluxLoopReconstructed, time_slice(0).constraints.flux_loop(0).reconstructed)
COCOS_SCALAR_EVALUATOR(evaluateIpMeasured, time_slice(0).constraints.ip.measured)
COCOS_SCALAR_EVALUATOR(evaluateIpReconstructed, time_slice(0).constraints.ip.reconstructed)
COCOS_SCALAR_EVALUATOR(evaluateJPhiPositionPsi, time_slice(0).constraints.j_phi(0).position.psi)
COCOS_SCALAR_EVALUATOR(evaluateNEPositionPsi, time_slice(0).constraints.n_e(0).position.psi)
COCOS_SCALAR_EVALUATOR(evaluatePfCurrentMeasured, time_slice(0).constraints.pf_current(0).measured)
COCOS_SCALAR_EVALUATOR(evaluatePfCurrentReconstructed, time_slice(0).constraints.pf_current(0).reconstructed)
COCOS_SCALAR_EVALUATOR(evaluatePressurePositionPsi, time_slice(0).constraints.pressure(0).position.psi)
COCOS_SCALAR_EVALUATOR(evaluatePressureRotationalPositionPsi, time_slice(0).constraints.pressure_rotational(0).position.psi)
COCOS_SCALAR_EVALUATOR(evaluateQPositionPsi, time_slice(0).constraints.q(0).position.psi)
COCOS_ARRAY_EVALUATOR(evaluateGgdPsiValues, time_slice(0).ggd(0).psi(0).values)
COCOS_SCALAR_EVALUATOR(evaluateGlobalIp, time_slice(0).global_quantities.ip)
COCOS_SCALAR_EVALUATOR(evaluatePsiAxis, time_slice(0).global_quantities.psi_axis)
COCOS_SCALAR_EVALUATOR(evaluatePsiMagneticAxis, time_slice(0).global_quantities.psi_magnetic_axis)
COCOS_SCALAR_EVALUATOR(evaluatePsiBoundary, time_slice(0).global_quantities.psi_boundary)
COCOS_SCALAR_EVALUATOR(evaluatePsiExternalAverage, time_slice(0).global_quantities.psi_external_average)
COCOS_SCALAR_EVALUATOR(evaluateVExternal, time_slice(0).global_quantities.v_external)
COCOS_ARRAY_EVALUATOR(evaluateP1dDareaDpsi, time_slice(0).profiles_1d.darea_dpsi)
COCOS_ARRAY_EVALUATOR(evaluateP1dDpressureDpsi, time_slice(0).profiles_1d.dpressure_dpsi)
COCOS_ARRAY_EVALUATOR(evaluateP1dDpsiDrhoTor, time_slice(0).profiles_1d.dpsi_drho_tor)
COCOS_ARRAY_EVALUATOR(evaluateP1dDvolumeDpsi, time_slice(0).profiles_1d.dvolume_dpsi)
COCOS_ARRAY_EVALUATOR(evaluateP1dFDfDpsi, time_slice(0).profiles_1d.f_df_dpsi)
COCOS_ARRAY_EVALUATOR(evaluateP1dJParallel, time_slice(0).profiles_1d.j_parallel)
COCOS_ARRAY_EVALUATOR(evaluateP1dJPhi, time_slice(0).profiles_1d.j_phi)
COCOS_ARRAY_EVALUATOR(evaluateP1dPsi, time_slice(0).profiles_1d.psi)
COCOS_ARRAY_EVALUATOR(evaluateP2dJParallel, time_slice(0).profiles_2d(0).j_parallel)
COCOS_ARRAY_EVALUATOR(evaluateP2dJPhi, time_slice(0).profiles_2d(0).j_phi)
COCOS_ARRAY_EVALUATOR(evaluateP2dPsi, time_slice(0).profiles_2d(0).psi)

#undef COCOS_ARRAY_EVALUATOR
#undef COCOS_SCALAR_EVALUATOR

constexpr std::array<CocosCheck, 30> kCocosChecks{{
    {"cocos-boundary-psi", evaluateBoundaryPsi},
    {"cocos-flux-loop-measured", evaluateFluxLoopMeasured},
    {"cocos-flux-loop-reconstructed", evaluateFluxLoopReconstructed},
    {"cocos-ip-measured", evaluateIpMeasured},
    {"cocos-ip-reconstructed", evaluateIpReconstructed},
    {"cocos-j-phi-position-psi", evaluateJPhiPositionPsi},
    {"cocos-n-e-position-psi", evaluateNEPositionPsi},
    {"cocos-pf-current-measured", evaluatePfCurrentMeasured},
    {"cocos-pf-current-reconstructed", evaluatePfCurrentReconstructed},
    {"cocos-pressure-position-psi", evaluatePressurePositionPsi},
    {"cocos-pressure-rot-position-psi", evaluatePressureRotationalPositionPsi},
    {"cocos-q-position-psi", evaluateQPositionPsi},
    {"cocos-ggd-psi-values", evaluateGgdPsiValues},
    {"cocos-gq-ip", evaluateGlobalIp},
    {"cocos-psi-axis", evaluatePsiAxis},
    {"cocos-psi-magnetic-axis", evaluatePsiMagneticAxis},
    {"cocos-psi-boundary", evaluatePsiBoundary},
    {"cocos-psi-external-average", evaluatePsiExternalAverage},
    {"cocos-v-external", evaluateVExternal},
    {"cocos-p1d-darea-dpsi", evaluateP1dDareaDpsi},
    {"cocos-p1d-dpressure-dpsi", evaluateP1dDpressureDpsi},
    {"cocos-p1d-dpsi-drho-tor", evaluateP1dDpsiDrhoTor},
    {"cocos-p1d-dvolume-dpsi", evaluateP1dDvolumeDpsi},
    {"cocos-p1d-f-df-dpsi", evaluateP1dFDfDpsi},
    {"cocos-p1d-j-parallel", evaluateP1dJParallel},
    {"cocos-p1d-j-phi", evaluateP1dJPhi},
    {"cocos-p1d-psi", evaluateP1dPsi},
    {"cocos-p2d-j-parallel", evaluateP2dJParallel},
    {"cocos-p2d-j-phi", evaluateP2dJPhi},
    {"cocos-p2d-psi", evaluateP2dPsi},
}};

}  // namespace

int main(int argc, char* argv[]) {
  if (argc != 2) {
    std::printf("%s: usage: <fixture-root>\n", kFailureMarker);
    return 1;
  }

  const auto& rules = ShimRuleTable::cocosRules();
  ShimTest::RuleChecker checker(kFailureMarker, rules.data(), rules.size());
  if (kCocosChecks.size() != rules.size()) {
    checker.fail("the COCOS check loop and rule table have different sizes");
  }

  IdsNs::IDS convertedIds;
  IdsNs::IDS oracleIds;
  const ShimTest::PairedRead read = ShimTest::openPairedRead(convertedIds, oracleIds, argv[1]);
  ShimTest::expectPairedReadUsable(
      checker, read,
      hasRequiredContainers(oracleIds._equilibrium) &&
          hasRequiredContainers(convertedIds._equilibrium),
      "a read did not reach every container the COCOS rules index into");

  if (checker.failures() == 0) {
    // No table lookup here: a COCOS evaluator needs only the two readings, and
    // RuleChecker::check does the lookup itself -- including reporting an id
    // that is not in the table, which a hand-rolled scan would silently skip.
    for (const CocosCheck& check : kCocosChecks) {
      checker.check(check.id, check.evaluate(/*oracle=*/ oracleValue(oracleIds._equilibrium),
                                             /*converted=*/ convertedValue(convertedIds._equilibrium)));
    }
  }

  convertedIds.close();
  oracleIds.close();
  checker.assertPreconditionCount(kExpectedPreconditions);
  checker.assertEveryRuleChecked();
  if (checker.failures() != 0) {
    std::printf("%s: %d COCOS rule assertion(s) failed\n", kFailureMarker, checker.failures());
    return 1;
  }
  return 0;
}
