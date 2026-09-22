// F5.1 / issue #20: only the public read outcome and refused-path count
// belong in this program. The surrounding harness owns loss-file assertions.
#include "ALClasses.h"
#include "shim_run_guard.h"

#include <cstdio>
#include <string>

int main(int argc, char* argv[]) {
  constexpr const char* marker = "NESTED-LOSS-FAILURE";
  constexpr int expectedAssertions = 2;
  if (argc != 2) {
    std::printf("%s: usage: <older-DD-fixture>\n", marker);
    return 1;
  }

  IdsNs::IDS ids;
  const int opened = ids.open(std::string("imas:hdf5?path=") + argv[1], OPEN_PULSE);
  if (opened != 0) {
    std::printf("%s: fixture open returned %d\n", marker, opened);
    return 1;
  }
  const int status = ids._equilibrium.get();
  int assertions = 0;
  int failures = 0;
  ++assertions;
  if (status != IdsNs::PARTIAL_READ) {
    ++failures;
    std::printf("%s: expected a partial read, got %d\n", marker, status);
  }
  ++assertions;
  if (ids._equilibrium.getSkippedPathCount() == 0) {
    ++failures;
    std::printf("%s: no path was refused\n", marker);
  }
  ids.close();
  ShimTest::assertRanCount(marker, "read outcome assertions", assertions,
                           expectedAssertions, failures);
  return failures == 0 ? 0 : 1;
}
