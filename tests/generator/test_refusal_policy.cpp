// Truth table for the refusal-tolerance chokepoint (IdsNs::Ids::mustAbort) and
// the skipped-path record it feeds.
//
// Nothing in an ordinary build can make a shim refuse a path -- that needs a
// multiversion shim and a mismatched pulse -- so without a direct test the
// tolerant branch of mustAbort would never execute anywhere in this
// repository's own tests. This test reaches it directly with hand-made
// statuses: no shim, no pulse, no backend.
//
// It deliberately drives the fatal branch too, and the fatal branch prints
// (it falls through to the existing IdsNs::Ids::isError helper, which prints
// "ERROR while calling ..."). So unlike the generated per-IDS test suite,
// this test's pass condition cannot be "the word error is absent" -- it is
// the absence of the distinctive marker POLICY-FAILURE, plus a zero exit
// status. Prior art: IMAS-Fortran's test_get_policy and test_put_policy.
//
// mustAbort is protected, mirroring isError, because both are meant to be
// called only from the generated IDS classes (and structures nested inside
// them). This test reaches it through a minimal concrete subclass that
// exposes it, rather than by widening its access for production callers, and
// drives it against that subclass's own inherited record -- Ids::skippedPaths,
// reached through mustAbort's explicit reference parameter -- and the public
// const accessors, so the base class's storage is what gets exercised rather
// than a free-standing vector.

#include "ids/core_instant_changes_IDSBase.h"

#include <cstdio>
#include <cstring>

using IdsNs::SkippedPath;

namespace {

int failures = 0;

void expect(bool condition, const char *what)
{
    if (!condition)
    {
        printf("POLICY-FAILURE: %s\n", what);
        failures++;
    }
}

al_status_t makeStatus(int code, const char *message = "")
{
    al_status_t status;
    status.code = code;
    strncpy(status.message, message, MAX_ERR_MSG_LEN - 1);
    status.message[MAX_ERR_MSG_LEN - 1] = '\0';
    return status;
}

// Gives the test access to the protected chokepoint and record through a real
// generated IDS base, without faking the rest of the abstract IDS contract.
class PolicyUnderTest : public IdsNs::core_instant_changes_IDSBase
{
    public:
        bool critical(int code, const std::string &path, SkippedPath::Operation operation,
                      const char *message = "")
        {
            return mustAbort(makeStatus(code, message), operation, path, skippedPaths,
                             __FILE__, __LINE__, __func__);
        }

        void reset() { resetSkippedPaths(); }
};

} // namespace

int main()
{
    PolicyUnderTest ids;

    // Success is never critical, and never recorded.
    expect(!ids.critical(0, "a/b", SkippedPath::Operation::Read), "status 0 must not be critical");
    expect(ids.getSkippedPathCount() == 0, "a success must not be logged as a skip");

    // Every status IMAS-Core itself allocates stays fatal. If any of these
    // were tolerated, a backend or context failure would come back as a
    // sparse IDS instead of aborting.
    expect(ids.critical(UNKNOWN_ERR, "a/b", SkippedPath::Operation::Read), "UNKNOWN_ERR must be critical");
    expect(ids.critical(CONTEXT_ERR, "a/b", SkippedPath::Operation::Read), "CONTEXT_ERR must be critical");
    expect(ids.critical(BACKEND_ERR, "a/b", SkippedPath::Operation::Read), "BACKEND_ERR must be critical");
    expect(ids.critical(LOWLEVEL_ERR, "a/b", SkippedPath::Operation::Read), "LOWLEVEL_ERR must be critical");
    expect(ids.getSkippedPathCount() == 0, "a fatal status must not be logged as a skip");

    // A refusal is tolerated, and recorded through the base class's own
    // record, for each operation tag.
    const char *refusalMessage =
        "IMAS-MVDD: refused equilibrium/grids_ggd/grid/space/coordinates_type";
    expect(!ids.critical(IdsNs::AL_REFUSAL_BAND_MAX, "grids_ggd/grid/space/coordinates_type",
                         SkippedPath::Operation::Read, refusalMessage),
           "a conversion refusal must not be critical (read)");
    expect(ids.getSkippedPathCount() == 1, "a tolerated read refusal must be logged");
    expect(ids.getSkippedPaths().back().operation == SkippedPath::Operation::Read, "the logged operation must be Read");
    expect(ids.getSkippedPaths().back().path == "grids_ggd/grid/space/coordinates_type",
           "the logged path must be the refused one");
    expect(ids.getSkippedPaths().back().code == IdsNs::AL_REFUSAL_BAND_MAX, "the logged code must be the refusal status");
    expect(ids.getSkippedPaths().back().message == refusalMessage,
           "the logged message must preserve the shim refusal message");

    expect(!ids.critical(IdsNs::AL_REFUSAL_BAND_MAX, "x/y", SkippedPath::Operation::Write),
           "a conversion refusal must not be critical (write)");
    expect(ids.getSkippedPathCount() == 2 && ids.getSkippedPaths().back().operation == SkippedPath::Operation::Write,
           "a tolerated write refusal must be logged with the Write tag");

    expect(!ids.critical(IdsNs::AL_REFUSAL_BAND_MAX, "x/y", SkippedPath::Operation::Delete),
           "a conversion refusal must not be critical (delete)");
    expect(ids.getSkippedPathCount() == 3 && ids.getSkippedPaths().back().operation == SkippedPath::Operation::Delete,
           "a tolerated delete refusal must be logged with the Delete tag");

    // The whole reserved band is tolerated, not just the one value allocated
    // today (IMAS_MVDD_CONVERSION_ERROR == AL_REFUSAL_BAND_MAX).
    expect(!ids.critical(IdsNs::AL_REFUSAL_BAND_MIN, "x/y", SkippedPath::Operation::Read),
           "the far end of the reserved band must not be critical");
    expect(!ids.critical(-1050, "x/y", SkippedPath::Operation::Read),
           "an interior value in the reserved band must not be critical");

    // Just outside the band, both sides, is fatal again.
    expect(ids.critical(IdsNs::AL_REFUSAL_BAND_MAX + 1, "x/y", SkippedPath::Operation::Read),
           "just above the reserved band must be critical");
    expect(ids.critical(IdsNs::AL_REFUSAL_BAND_MIN - 1, "x/y", SkippedPath::Operation::Read),
           "just below the reserved band must be critical");

    // Cleared at the start of a root operation, so the record describes one
    // operation rather than accumulating across calls.
    expect(ids.getSkippedPathCount() == 5,
           "the refusal-band boundaries, one interior refusal and all operation tags must be counted");
    ids.reset();
    expect(ids.getSkippedPaths().empty(), "reset must empty the record");
    expect(ids.getSkippedPathCount() == 0, "count and entries must agree after reset");

    // PARTIAL_READ and PARTIAL_PUT must stay distinguishable from every status
    // the C ABI can produce, and from each other.
    expect(IdsNs::PARTIAL_READ > 0, "PARTIAL_READ must be positive");
    expect(IdsNs::PARTIAL_PUT > 0, "PARTIAL_PUT must be positive");
    expect(IdsNs::PARTIAL_READ != IdsNs::PARTIAL_PUT, "PARTIAL_READ and PARTIAL_PUT must be distinct");

    if (failures > 0)
    {
        printf("POLICY-FAILURE: %d expectation(s) failed\n", failures);
        return 1;
    }

    return 0;
}
