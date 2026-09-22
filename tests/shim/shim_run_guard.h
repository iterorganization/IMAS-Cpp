// The guard that stops a program which asserted nothing from passing.
//
// docs/SHIM_SUITE_CONVENTION.md D6: most of this suite passes by *not*
// printing (refusals and other error-shaped text are legitimate output), so
// a run that checked nothing at all looks exactly like a run that checked
// everything. Every program in this suite therefore states up front how
// many assertions it will run and fails if it ran a different number, so a
// check lost in a later edit fails the run instead of quietly shrinking it.
//
// Deliberately a header with no dependency beyond the marker string it is
// handed, so any program in this suite can use it without pulling in the
// comparison oracle or a rule table.
#pragma once

#include <cstdio>

namespace ShimTest {

// `what` names the thing counted, in the plural, so the message reads
// "only 3 of 5 rule table entries checked".
inline void assertRanCount(const char* marker, const char* what, int ran,
                            int expected, int& failures) {
  if (ran == expected) {
    return;
  }
  ++failures;
  std::printf("%s: only %d of %d %s\n", marker, ran, expected, what);
}

}  // namespace ShimTest
