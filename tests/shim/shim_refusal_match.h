// The shared record-matching predicate for a SkippedPath refusal
// (docs/SHIM_SUITE_CONVENTION.md S5.4 F4.4): match the operation, the full DD
// path, the reason, and the status band -- and no fewer.
//
// `SkippedPath::path` may hold only a leaf name; the full DD path lives in
// `SkippedPath::message` (docs/SHIM_INTEGRATION_CONTRACT.md S8.1). That
// message is truncated by cutting the path from the left when it does not
// fit, so this header never requires an exact match against the whole
// message: the path is matched against the tail of the message's own
// "DD path: ..." field, which survives truncation and tolerates a future
// generator prefixing that field with more context (an IDS name, an
// occurrence index) without breaking a test written against today's spelling.
#pragma once

#include "ALClasses.h"

#include <cstddef>
#include <string>
#include <vector>

namespace ShimTest {

// The literal field label the shim's message envelope uses
// (docs/SHIM_INTEGRATION_CONTRACT.md S8.1); the label itself is never cut by
// truncation, only the path value that follows it.
inline std::string extractDictionaryPath(const std::string& message) {
  static const std::string kLabel = "DD path: ";
  const std::size_t labelAt = message.find(kLabel);
  if (labelAt == std::string::npos) return {};
  const std::size_t valueAt = labelAt + kLabel.size();
  const std::size_t end = message.find(';', valueAt);
  return end == std::string::npos ? message.substr(valueAt) : message.substr(valueAt, end - valueAt);
}

inline bool endsWith(const std::string& value, const std::string& suffix) {
  return value.size() >= suffix.size() &&
         value.compare(value.size() - suffix.size(), suffix.size(), suffix) == 0;
}

// Channel 2's three required checks, each independently named so a failure
// says which of the three broke rather than only that "the record didn't
// match".
inline bool refusalNamesPath(const IdsNs::SkippedPath& record, const std::string& fullDictionaryPath) {
  return endsWith(extractDictionaryPath(record.message), fullDictionaryPath);
}

inline bool refusalNamesReason(const IdsNs::SkippedPath& record, const std::string& reasonSubstring) {
  return record.message.find(reasonSubstring) != std::string::npos;
}

inline bool refusalInBand(const IdsNs::SkippedPath& record) {
  return record.code >= IdsNs::AL_REFUSAL_BAND_MIN && record.code <= IdsNs::AL_REFUSAL_BAND_MAX;
}

// Finds the one record naming `fullDictionaryPath` for `operation`, or
// nullptr when the record isn't present at all -- distinct from finding it
// and having its reason or band checks fail, which callers assert on
// separately once a record is found.
inline const IdsNs::SkippedPath* findRefusalByPath(const std::vector<IdsNs::SkippedPath>& records,
                                                    IdsNs::SkippedPath::Operation operation,
                                                    const std::string& fullDictionaryPath) {
  for (const auto& record : records) {
    if (record.operation == operation && refusalNamesPath(record, fullDictionaryPath)) {
      return &record;
    }
  }
  return nullptr;
}

// The complete record predicate for a rule that expects a particular refusal.
// Callers which expect no record can combine this with findRefusalByPath():
// the former proves a refusal has all three required properties, and the
// latter still rejects a record that is malformed or names the wrong reason.
inline const IdsNs::SkippedPath* findRefusalByPathReasonAndBand(
    const std::vector<IdsNs::SkippedPath>& records, IdsNs::SkippedPath::Operation operation,
    const std::string& fullDictionaryPath, const std::string& reasonSubstring) {
  for (const auto& record : records) {
    if (record.operation == operation && refusalNamesPath(record, fullDictionaryPath) &&
        refusalNamesReason(record, reasonSubstring) && refusalInBand(record)) {
      return &record;
    }
  }
  return nullptr;
}

}  // namespace ShimTest
