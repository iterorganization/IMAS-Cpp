// The suite's one shared comparator (docs/SHIM_SUITE_CONVENTION.md S4).
//
// Every value comparison the suite makes goes through Compare() below, so
// that the verdict a failure message names and a README transcribes comes
// from one place, not from a comparison re-written per rule program.
//
// Header-only and dependency-free (beyond <vector>/<cmath>) on purpose: it
// carries no rule table, no fixture and no pulse, so its own test
// (test_shim_comparator.cpp) can drive it from literals alone -- a pulse can
// never prove its own oracle right.
#pragma once

#include <cmath>
#include <cstddef>
#include <vector>

namespace ShimTest {

// A closed, named verdict set (docs/SHIM_SUITE_CONVENTION.md S4.1). Closed
// so a misspelt or new verdict fails to build rather than falling through
// to a default; named by role (oracle/converted), not by dictionary
// version, so the set stays correct if the suite ever gains the reverse
// direction.
//
// NoFlip carries mismatch severity, never warning severity: a required
// COCOS sign flip that did not happen is a failed contract assertion, and
// nothing in this enum lets a caller downgrade it -- there is no separate
// "warning" verdict to reach for instead.
enum class Verdict {
  Absent,         // neither side has a value
  OnlyOracle,     // the oracle has a value; the converted reading has none
  OnlyConverted,  // the converted reading has a value; the oracle has none
  Same,           // both present and equal within tolerance
  NoFlip,         // both present, equal only after negating one side
  Diff,           // both present, neither equal nor sign-flipped
  Shape,          // both present, different element counts
};

namespace detail {

// The two readings share every operation but are deliberately not the same
// type: OracleReading and ConvertedReading below are distinct
// instantiations of this template, so a call that hands Compare() the two
// arguments in the wrong positions is a compile error, not a convention a
// reviewer has to notice broken (docs/SHIM_SUITE_CONVENTION.md S4.3).
//
// Presence is derived from the reading itself -- non-empty means present --
// never asserted by a caller. A caller-supplied "trust me, it's there" is
// exactly what let two empty readings compare as agreement in
// IMAS-Fortran's first comparator.
template <typename Tag>
class TaggedReading {
 public:
  TaggedReading() = default;
  explicit TaggedReading(std::vector<double> values) : values_(std::move(values)) {}

  bool present() const { return !values_.empty(); }
  std::size_t size() const { return values_.size(); }
  const std::vector<double>& values() const { return values_; }

 private:
  std::vector<double> values_;
};

struct OracleTag {};
struct ConvertedTag {};

}  // namespace detail

// The same-version oracle reading and the cross-version converted reading.
// Both wrap a plain vector<double> (a scalar is a one-element reading), and
// neither converts to the other -- see detail::TaggedReading above.
using OracleReading = detail::TaggedReading<detail::OracleTag>;
using ConvertedReading = detail::TaggedReading<detail::ConvertedTag>;

// Compares one oracle reading against one converted reading and returns the
// single verdict that describes their relationship.
//
// Presence is judged before value, always (docs/SHIM_SUITE_CONVENTION.md
// S4.2): both-absent, then either-absent, and only once both are known
// present does any element get compared. `tolerance` bounds both the
// equality check and the sign-flip check.
//
// Every call site names both arguments with an adjacent oracle= / converted=
// comment, in the exact style the two ExpectVerdict examples in
// test_shim_comparator.cpp use (enforced by the source check
// cpp-test-shim-verdict-orientation, check_verdict_orientation.cmake): the
// type system already refuses a positionally-swapped call, but it cannot
// catch a reading wrapped in the wrong type at its construction site, and
// the named comment is what makes that residual mistake grep-able.
inline Verdict Compare(const OracleReading& oracle, const ConvertedReading& converted,
                       double tolerance = 1e-9) {
  const bool oracle_present = oracle.present();
  const bool converted_present = converted.present();

  if (!oracle_present && !converted_present) {
    return Verdict::Absent;
  }
  if (oracle_present && !converted_present) {
    return Verdict::OnlyOracle;
  }
  if (!oracle_present && converted_present) {
    return Verdict::OnlyConverted;
  }

  if (oracle.size() != converted.size()) {
    return Verdict::Shape;
  }

  bool same = true;
  bool flipped = true;
  for (std::size_t i = 0; i < oracle.size(); ++i) {
    const double o = oracle.values()[i];
    const double c = converted.values()[i];
    // A NaN element must fail both checks below, not pass them: `>`
    // against a NaN is always false, so without this guard a NaN would
    // silently satisfy `!(fabs(...) > tolerance)` and report Same.
    if (std::isnan(o) || std::isnan(c) || std::fabs(o - c) > tolerance) {
      same = false;
    }
    if (std::isnan(o) || std::isnan(c) || std::fabs(o + c) > tolerance) {
      flipped = false;
    }
  }

  if (same) {
    // Checked before `flipped`: for all-zero readings both conditions hold,
    // and an exact match must never be reported as an unflipped mismatch.
    return Verdict::Same;
  }
  if (flipped) {
    return Verdict::NoFlip;
  }
  return Verdict::Diff;
}

}  // namespace ShimTest
