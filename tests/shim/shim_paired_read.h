// The paired cross-version read every by-rule family opens with.
//
// F4.1 (structural), F4.2 (COCOS) and F4.3 (right-only) each begin the same
// way: open the DD 3.39.0 pulse and read it through the shim, open the
// DD 4.1.1 pulse and read it same-version, then decide whether each side is
// usable before any rule is judged. The three copies were identical, so the
// one decision that matters here -- a converted read may legitimately be
// PARTIAL_READ, while the oracle read must be clean -- was written out three
// times and could drift in one of them without a reviewer noticing.
//
// The caller still owns the two IdsNs::IDS objects. They are deliberately not
// held here: each family closes them at its own point, and two independent
// objects are what keeps the oracle read from reaching the converted read's
// own skipped-path record.
#pragma once

#include "ALClasses.h"
#include "shim_fixture_uri.h"
#include "shim_rule_check.h"

namespace ShimTest {

struct PairedRead {
  int convertedStatus = 0;
  int oracleStatus = 0;
  bool convertedUsable = false;
  bool oracleUsable = false;

  bool bothUsable() const { return convertedUsable && oracleUsable; }
};

// Converted before oracle, matching docs/SHIM_SUITE_CONVENTION.md S5.4's
// stated ordering: the refusal record resets at the start of each root
// operation, so reading the converted side first keeps a family's record
// assertions correct even if a future revision shares one object.
inline PairedRead openPairedRead(IdsNs::IDS& convertedIds, IdsNs::IDS& oracleIds,
                                 const char* fixtureRoot) {
  PairedRead read;

  const int convertedOpen = convertedIds.open(hdf5Uri(fixtureRoot, "dd-3.39.0"), OPEN_PULSE);
  read.convertedStatus = convertedOpen == 0 ? convertedIds._equilibrium.get() : convertedOpen;

  const int oracleOpen = oracleIds.open(hdf5Uri(fixtureRoot, "dd-4.1.1"), OPEN_PULSE);
  read.oracleStatus = oracleOpen == 0 ? oracleIds._equilibrium.get() : oracleOpen;

  // The complete older-dictionary fixture holds paths the shim refuses, so
  // the converted read is legitimately partial. The oracle converts nothing
  // and must therefore be clean -- otherwise it is not an oracle.
  read.oracleUsable = oracleOpen == 0 && read.oracleStatus == 0;
  read.convertedUsable = convertedOpen == 0 &&
                         (read.convertedStatus == 0 || read.convertedStatus == IdsNs::PARTIAL_READ);
  return read;
}

// The two read preconditions every by-rule family states, plus the family's
// own container precondition, in the order all three already used. Counted on
// the checker, so a family's declared precondition total is unchanged.
inline void expectPairedReadUsable(RuleChecker& checker, const PairedRead& read,
                                   bool containersReached, const char* containersDetail) {
  checker.expect(read.oracleUsable, "the same-version oracle read did not succeed cleanly");
  checker.expect(read.convertedUsable,
                 "the cross-version read did not succeed or report a partial read");
  checker.expect(read.bothUsable() && containersReached, containersDetail);
}

}  // namespace ShimTest
