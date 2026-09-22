// Generated traversal contract for tolerated write and delete refusals.
//
// A normal build has neither a second-DD pulse nor a shim that can refuse a
// path, so the public put/delete operations cannot reach this branch at
// runtime. Instead, verify the generated public-operation source until the
// shim conformance suite provides equivalent executable coverage.

#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

namespace {

int failures = 0;

void expect(bool condition, const char *what)
{
    if (!condition)
    {
        std::cout << "GENERATOR-POLICY-FAILURE: " << what << '\n';
        ++failures;
    }
}

std::string readFile(const char *path)
{
    std::ifstream input(path);
    std::ostringstream contents;
    contents << input.rdbuf();
    return contents.str();
}

size_t occurrences(const std::string &contents, const std::string &needle)
{
    size_t count = 0;
    size_t position = 0;
    while ((position = contents.find(needle, position)) != std::string::npos)
    {
        ++count;
        position += needle.size();
    }
    return count;
}

} // namespace

int main(int argc, char **argv)
{
    if (argc < 3)
    {
        std::cout << "GENERATOR-POLICY-FAILURE: expected generated source paths\n";
        return 1;
    }

    std::string generated;
    for (int i = 1; i < argc; ++i)
        generated += readFile(argv[i]);
    expect(!generated.empty(), "generated source must be readable");

    // Root put, putSlice and deleteAll reset the record. The read roots already
    // contribute three instances, so six proves all three write-side roots do.
    expect(occurrences(generated, "resetSkippedPaths();") >= 6,
           "root put, putSlice, and deleteAll must reset skipped paths");

    // Generated nested traversal methods carry the root IDS record rather than
    // giving each structure a disconnected record of its own.
    expect(occurrences(generated, "std::vector<SkippedPath> &skippedPaths") >= 6,
           "nested put, slice-put, and delete declarations must carry skipped paths");
    expect(occurrences(generated, "SkippedPath::Operation::Write") >= 4,
           "write leaf and array-open seams must use the Write operation tag");
    expect(occurrences(generated, "SkippedPath::Operation::Delete") >= 1,
           "delete leaf seams must use the Delete operation tag");
    expect(occurrences(generated, "retStatus = PARTIAL_PUT;") >= 3,
           "tolerated write and delete refusals must produce PARTIAL_PUT");

    if (failures > 0)
    {
        std::cout << "GENERATOR-POLICY-FAILURE: " << failures << " expectation(s) failed\n";
        return 1;
    }
    return 0;
}
