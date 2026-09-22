// Family 4.4 (docs/SHIM_SUITE_CONVENTION.md S5.4): a correctly refused path
// must be reported on all three channels -- value, refused-path record, and
// status -- not merely survived. `grids_ggd/grid/space/coordinates_type` is
// the map's one `retyped` rule (int array in DD 3.39.0, array of identifier
// structures in DD 4.1.1); no transformation reshapes one into the other, so
// the shim refuses it and the traversal must tolerate that refusal rather
// than abort.
//
// The two reads run as separate calls, converted before oracle, on two
// independent IdsNs::IDS objects (as F4.1's test_shim_structural_rules.cpp
// does), so the oracle read cannot reach convertedIds' own record. This
// program still copies the converted read's record out before running the
// oracle read, matching docs/SHIM_SUITE_CONVENTION.md S5.4's stated ordering:
// the record resets at the start of each root operation, so the same
// ordering keeps this assertion correct if a future revision reads both
// pulses through one shared object instead of two.
#include "ALClasses.h"
#include "shim_fixture_uri.h"
#include "shim_refusal_match.h"
#include "shim_rule_table.h"
#include "shim_run_guard.h"

#include <array>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

namespace {

constexpr const char* kFailureMarker = "REFUSAL-CHANNELS-FAILURE";
constexpr int kExpectedAssertions = 15;
using Equilibrium = IdsNs::IDS::equilibrium;

using RedefinedValue = double (*)(const Equilibrium& equilibrium);

struct RedefinedCheck {
  const char* id;
  RedefinedValue value;
};

double xPointChiSquaredR(const Equilibrium& equilibrium) {
  return equilibrium.time_slice(0).constraints.x_point(0).chi_squared_r;
}

double xPointChiSquaredZ(const Equilibrium& equilibrium) {
  return equilibrium.time_slice(0).constraints.x_point(0).chi_squared_z;
}

double strikePointChiSquaredR(const Equilibrium& equilibrium) {
  return equilibrium.time_slice(0).constraints.strike_point(0).chi_squared_r;
}

double strikePointChiSquaredZ(const Equilibrium& equilibrium) {
  return equilibrium.time_slice(0).constraints.strike_point(0).chi_squared_z;
}

constexpr std::array<RedefinedCheck, 4> kRedefinedChecks{{
    {"redefine-x-point-chi-sq-r", xPointChiSquaredR},
    {"redefine-x-point-chi-sq-z", xPointChiSquaredZ},
    {"redefine-strike-pt-chi-sq-r", strikePointChiSquaredR},
    {"redefine-strike-pt-chi-sq-z", strikePointChiSquaredZ},
}};

const ShimRuleTable::Rule* findRule(const char* id) {
  for (const ShimRuleTable::Rule& rule : ShimRuleTable::refusalRules()) {
    if (std::strcmp(rule.id, id) == 0) return &rule;
  }
  return nullptr;
}

bool hasSpaceContainer(const Equilibrium& equilibrium) {
  return equilibrium.grids_ggd.extent(0) > 0 && equilibrium.grids_ggd(0).grid.extent(0) > 0 &&
         equilibrium.grids_ggd(0).grid(0).space.extent(0) > 0;
}

bool hasRedefinedContainers(const Equilibrium& equilibrium) {
  return equilibrium.time_slice.extent(0) > 0 && equilibrium.time_slice(0).constraints.x_point.extent(0) > 0 &&
         equilibrium.time_slice(0).constraints.strike_point.extent(0) > 0;
}

std::vector<ShimRuleTable::Rule> redefinedRules() {
  std::vector<ShimRuleTable::Rule> rules;
  for (const ShimRuleTable::Rule& rule : ShimRuleTable::refusalRules()) {
    if (rule.kind == ShimRuleTable::Kind::Redefined) rules.push_back(rule);
  }
  return rules;
}

const ShimRuleTable::Rule* findRule(const std::vector<ShimRuleTable::Rule>& rules, const char* id) {
  for (const ShimRuleTable::Rule& rule : rules) {
    if (std::strcmp(rule.id, id) == 0) return &rule;
  }
  return nullptr;
}

const RedefinedCheck* findRedefinedCheck(const char* id) {
  for (const RedefinedCheck& check : kRedefinedChecks) {
    if (std::strcmp(check.id, id) == 0) return &check;
  }
  return nullptr;
}

ShimTest::Verdict scalarVerdict(double oracle, double converted) {
  const std::vector<double> oracleReading = oracle == EMPTY_DOUBLE ? std::vector<double>{}
                                                                    : std::vector<double>{oracle};
  const std::vector<double> convertedReading =
      converted == EMPTY_DOUBLE ? std::vector<double>{} : std::vector<double>{converted};
  return ShimTest::Compare(/*oracle=*/ ShimTest::OracleReading(oracleReading),
                           /*converted=*/ ShimTest::ConvertedReading(convertedReading));
}

void expect(bool condition, const char* detail, int& assertions, int& failures) {
  ++assertions;
  if (!condition) {
    ++failures;
    std::printf("%s: %s\n", kFailureMarker, detail);
  }
}

void expectRule(bool condition, const ShimRuleTable::Rule& rule, const char* detail, int& assertions,
                int& failures) {
  ++assertions;
  if (!condition) {
    ++failures;
    std::printf("%s: rule %s (%s) citation=%s: %s\n", kFailureMarker, rule.id,
                ShimRuleTable::kindName(rule.kind), rule.citation, detail);
  }
}

}  // namespace

int main(int argc, char* argv[]) {
  if (argc != 2) {
    std::printf("%s: usage: <fixture-root>\n", kFailureMarker);
    return 1;
  }

  const ShimRuleTable::Rule* rule = findRule("retype-coordinates-type");
  if (rule == nullptr) {
    std::printf("%s: retype-coordinates-type is not present in the refusal-rule table\n",
                kFailureMarker);
    return 1;
  }

  int assertions = 0;
  int failures = 0;

  IdsNs::IDS convertedIds;
  const int convertedOpen = convertedIds.open(ShimTest::hdf5Uri(argv[1], "dd-3.39.0"), OPEN_PULSE);
  const int convertedStatus = convertedOpen == 0 ? convertedIds._equilibrium.get() : convertedOpen;
  const std::vector<IdsNs::SkippedPath> convertedSkippedPaths =
      convertedIds._equilibrium.getSkippedPaths();
  const Equilibrium& converted = convertedIds._equilibrium;

  IdsNs::IDS oracleIds;
  const int oracleOpen = oracleIds.open(ShimTest::hdf5Uri(argv[1], "dd-4.1.1"), OPEN_PULSE);
  const int oracleStatus = oracleOpen == 0 ? oracleIds._equilibrium.get() : oracleOpen;
  const Equilibrium& oracle = oracleIds._equilibrium;

  const bool oracleUsable = oracleOpen == 0 && oracleStatus == 0;
  const bool convertedUsable =
      convertedOpen == 0 && (convertedStatus == 0 || convertedStatus == IdsNs::PARTIAL_READ);
  expect(oracleUsable, "the same-version oracle read did not succeed cleanly", assertions, failures);
  expect(convertedUsable, "the cross-version read did not succeed or report a partial read", assertions,
         failures);
  expect(oracleUsable && convertedUsable && hasSpaceContainer(oracle) && hasSpaceContainer(converted),
         "a read did not reach the grids_ggd/grid/space container the refusal indexes into", assertions,
         failures);

  // Channel 3: status.
  expectRule(convertedStatus == IdsNs::PARTIAL_READ, *rule,
             "the cross-version read of the retyped path did not report a partial outcome",
             assertions, failures);

  // Channel 1: value. Left absent, not converted and not defaulted.
  expectRule(converted.grids_ggd(0).grid(0).space(0).coordinates_type.extent(0) == 0, *rule,
             "the retyped path was not left absent in the returned IDS", assertions, failures);

  // Channel 2: refused-path record. Match the operation, the full DD path
  // (on its tail, docs/SHIM_INTEGRATION_CONTRACT.md S8.1), the reason, and
  // the status band -- three things and no fewer.
  const IdsNs::SkippedPath* refusal = ShimTest::findRefusalByPath(
      convertedSkippedPaths, IdsNs::SkippedPath::Operation::Read, rule->hliPath);
  expectRule(refusal != nullptr, *rule,
             "the retyped path's refusal is not present in the skipped-path record", assertions,
             failures);
  expectRule(refusal != nullptr && ShimTest::refusalNamesReason(*refusal, ShimRuleTable::kRetypedRefusalReason),
             *rule, "the refusal record's message does not name the retyped-container reason",
             assertions, failures);
  expectRule(refusal != nullptr && ShimTest::refusalInBand(*refusal), *rule,
             "the refusal record's status is not in the refusal band", assertions, failures);

  // The refusal is absorbed at the field, not by truncating the traversal
  // around it: the containers directly enclosing it survived, a field read
  // after it within the same "space" structure arrived, and a field read
  // later still (equilibrium's root "time", after the whole grids_ggd and
  // time_slice traversal) still agrees with the oracle.
  expectRule(hasSpaceContainer(converted), *rule,
             "the containers around the refused path did not survive", assertions, failures);
  expectRule(converted.grids_ggd(0).grid(0).space(0).objects_per_dimension.extent(0) > 0, *rule,
             "a field read after the refusal within the same structure did not arrive", assertions,
             failures);

  const std::vector<double> oracleTime(oracle.time.data(), oracle.time.data() + oracle.time.numElements());
  const std::vector<double> convertedTime(converted.time.data(),
                                           converted.time.data() + converted.time.numElements());
  const ShimTest::Verdict laterFieldVerdict =
      ShimTest::Compare(/*oracle=*/ ShimTest::OracleReading(oracleTime),
                        /*converted=*/ ShimTest::ConvertedReading(convertedTime));
  expectRule(laterFieldVerdict == ShimTest::Verdict::Same, *rule,
             "a served field from later in the traversal no longer agrees with the oracle",
             assertions, failures);

  // A unit redefinition changes a label, not the number in either fixture.
  // The value comparison alone would therefore also pass if the shim silently
  // forwarded an older value with the wrong unit. Reject every skipped-path
  // record for the full DD path, including one with a malformed reason or
  // status; also use the shared path/reason/band matcher, so this check has
  // the same three-part definition as the correctly refused retyped rule.
  const std::vector<ShimRuleTable::Rule> rules = redefinedRules();
  int redefinedAssertions = 0;
  const bool redefinedContainersUsable =
      oracleUsable && convertedUsable && hasRedefinedContainers(oracle) && hasRedefinedContainers(converted);
  for (const ShimRuleTable::Rule& rule : rules) {
    expectRule(redefinedContainersUsable, rule,
               "a read did not reach the x_point and strike_point containers this rule indexes into", assertions,
               failures);
  }
  if (redefinedContainersUsable) {
    for (const ShimRuleTable::Rule& rule : rules) {
      const RedefinedCheck* check = findRedefinedCheck(rule.id);
      if (check == nullptr) {
        std::printf("%s: rule %s (%s) citation=%s: has no value reader\n", kFailureMarker, rule.id,
                    ShimRuleTable::kindName(rule.kind), rule.citation);
        ++failures;
        continue;
      }
      const ShimTest::Verdict verdict = scalarVerdict(check->value(oracle), check->value(converted));
      expectRule(verdict == ShimRuleTable::expectedVerdict(rule.kind), rule,
                 "the unit-redefined value did not agree with the oracle", redefinedAssertions, failures);
      const IdsNs::SkippedPath* pathRecord = ShimTest::findRefusalByPath(
          convertedSkippedPaths, IdsNs::SkippedPath::Operation::Read, rule.hliPath);
      const IdsNs::SkippedPath* matchingRefusal = ShimTest::findRefusalByPathReasonAndBand(
          convertedSkippedPaths, IdsNs::SkippedPath::Operation::Read, rule.hliPath,
          ShimRuleTable::kRedefinedRefusalReason);
      expectRule(pathRecord == nullptr && matchingRefusal == nullptr,
                 rule, "a skipped-path record names this unit-redefined path", redefinedAssertions, failures);
    }
  }
  const int expectedRedefinedAssertions = static_cast<int>(rules.size() * 2);
  if (redefinedAssertions != expectedRedefinedAssertions) {
    for (const ShimRuleTable::Rule& rule : rules) {
      std::printf("%s: rule %s (%s) citation=%s: unit-redefinition assertion count was %d, expected %d\n",
                  kFailureMarker, rule.id, ShimRuleTable::kindName(rule.kind), rule.citation, redefinedAssertions,
                  expectedRedefinedAssertions);
    }
  }
  ShimTest::assertRanCount(kFailureMarker, "unit-redefinition assertions", redefinedAssertions,
                           expectedRedefinedAssertions, failures);

  convertedIds.close();
  oracleIds.close();

  ShimTest::assertRanCount(kFailureMarker, "F4.4 refusal-channel assertions", assertions,
                           kExpectedAssertions, failures);
  if (failures != 0) {
    std::printf("%s: rule %s (%s) citation=%s: %d assertion(s) failed\n", kFailureMarker, rule->id,
                ShimRuleTable::kindName(rule->kind), rule->citation, failures);
    return 1;
  }
  return 0;
}
