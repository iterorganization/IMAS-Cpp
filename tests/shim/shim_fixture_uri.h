// The one place this suite spells a fixture URI.
//
// Every fixture-reading program in the suite opens its pulse through the
// HDF5 backend, and each had its own copy of this two-line function. They
// were identical, so a change of backend or of URI spelling -- the kind of
// change that arrives from IMAS-Core rather than from this repository --
// meant seven edits, six of which a reviewer had to notice were missing.
//
// Two overloads, because the suite has two fixture shapes: a write scenario
// is handed its own private copy of one pulse, while a paired read scenario
// is handed the root holding both dictionary versions and names the one it
// wants.
//
// Deliberately kept apart from shim_run_guard.h, whose own header records
// that it takes no dependency beyond the marker string it is handed.
#pragma once

#include <string>

namespace ShimTest {

// A private fixture copy: the directory is the pulse itself.
inline std::string hdf5Uri(const char* fixtureDirectory) {
  return std::string("imas:hdf5?path=") + fixtureDirectory;
}

// The vendored fixture root, which holds one directory per dictionary
// version (`dd-3.39.0`, `dd-4.1.1`).
inline std::string hdf5Uri(const char* fixtureRoot, const char* dictionaryDirectory) {
  return std::string("imas:hdf5?path=") + fixtureRoot + "/" + dictionaryDirectory;
}

}  // namespace ShimTest
