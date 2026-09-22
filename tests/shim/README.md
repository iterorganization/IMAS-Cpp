# Multiversion shim conformance suite

This directory holds the Tier-1 shim conformance suite described in
`docs/SHIM_SUITE_CONVENTION.md`. It registers only when
`AL_USE_MULTIVERSION_SHIM=ON`; with shim mode off the registered test list is
exactly what it was before this suite existed.

## Profile and direction

This HLI is **Profile A — tolerating** (`docs/SHIM_SUITE_CONVENTION.md` S2.3):
a refused read does not abort the traversal, the read reports a distinct
`PARTIAL_READ`/`PARTIAL_PUT` status, and `getSkippedPaths()` names the exact
DD path a refusal landed on. That is what makes the full F4/F5 catalogue below
implementable at all; an aborting HLI could not run most of it without either
narrowing its reads or adding tolerance first.

The suite runs **one direction** (S1 D2): this HLI, built against **DD
4.1.1**, reads and writes the checked-in **DD 3.39.0** fixture through the
shim (the *converted* reading); the same HLI reads the checked-in DD 4.1.1
fixture same-version as the *oracle* (nothing converts). It does not build a
second binary against DD 3.39.0, so the reverse direction — rules that cover a
path DD 3 had and DD 4 dropped — is never exercised here; see "Coverage
boundaries" below.

## Scenario catalogue (issue #24)

`docs/SHIM_SUITE_CONVENTION.md` S5 lists eighteen assertions in six families
and says an implementing HLI **SHOULD** implement all eighteen and **MUST**
state which it omitted and why. All eighteen are implemented; none are
omitted.

| id | scenario | label | ctest test |
|---|---|---|---|
| F1.1 | linkage | `harness` | `cpp-test-shim-linkage` |
| F1.2 | comparison | `harness` | `cpp-test-shim-comparison` |
| F1.3 | verdict-orientation | `harness` | `cpp-test-shim-verdict-orientation` |
| F1.4 | fixture-provenance | `harness` | `cpp-test-shim-fixture-provenance` |
| F2.1 | version-unset | `contract-assertion` | `cpp-test-shim-version-unset` |
| F2.2 | stamp-equal | `contract-assertion` | `cpp-test-shim-stamp-equal` |
| F2.3 | stamp-absent | `contract-assertion` | `cpp-test-shim-stamp-absent` |
| F2.4 | stamp-mismatch-no-artifact | `contract-assertion` | `cpp-test-shim-stamp-mismatch-no-artifact` |
| F3.1 | stamp-malformed | `contract-assertion` | `cpp-test-shim-stamp-malformed` |
| F4.1 | structural-rules | `contract-assertion` | `cpp-test-shim-structural-rules` |
| F4.2 | cocos-rules | `contract-assertion` | `cpp-test-shim-cocos-rules` |
| F4.3 | right-only-rules | `contract-assertion` | `cpp-test-shim-right-only-rules` |
| F4.4 | refusal-rules | `contract-assertion` | `cpp-test-shim-refusal-channels` |
| F5.1 | nested-loss | `contract-assertion` + `harness` | `cpp-test-shim-nested-loss` (asserted), `cpp-test-shim-loss-log-harness` (harness self-test) |
| F6.1 | roundtrip-cross-dd | `contract-assertion` | `cpp-test-shim-roundtrip-cross-dd` |
| F6.2 | roundtrip-same-dd | `contract-assertion` | `cpp-test-shim-roundtrip-same-dd` |
| F6.3 | torn-write | `behaviour-pin` | `cpp-test-shim-torn-write` |
| F6.4 | full-put-stamp | `contract-assertion` | `cpp-test-shim-full-put-stamp` |

`cpp-test-shim-run-guard` and `cpp-test-shim-fixture-copy`/
`cpp-test-shim-fixture-digest`/`cpp-test-shim-stamp-variants` are this suite's
own harness self-tests (D6 run guards, the private-copy and unchanged-fixture
helpers, and the derived stamp-state fixtures) rather than catalogue
scenarios; they exist to make the eighteen above trustworthy, not to add a
nineteenth.

## Scope so far (issues #10, #11, #12, #13, #14, #15, #16, #17, #18, #19, #20, #21, #22, #23)

Issue #10 registered the suite's scaffold and its first test.
Issue #11 added the shared comparison oracle every fixture-driven family
(issues #13, #14, #21) will read its verdicts from. Issue #12 vendors the
fixture pair those families read and the two isolation helpers a write and a
read scenario each need:

- `cpp-test-shim-linkage` (F1.1, `harness`): inspects the built `al-cpp`
  library's dynamic dependencies with `otool`/`objdump` and fails unless the
  multiversion shim's library name appears. Until this passes, nothing else
  this suite will ever say means anything -- every test in this repository's
  own suite passes just as well against a build that resolved its symbols
  straight to IMAS-Core and converted nothing.
- `cpp-test-shim-run-guard` (`harness`): a self-test of `shim_run_guard.h`,
  the shared assertion-count guard every later contract-assertion and
  behaviour-pin program in this suite is expected to use.
- `al_cpp_shim_private_loss_log()`, the CMake function later tickets use to
  give a test its own loss-log directory, cleaned before each run.
- `shim_comparator.h` (F1.2/F1.3): the one shared comparator every later
  contract-assertion program compares its oracle and converted readings
  through. `ShimTest::Verdict` is the closed, seven-member verdict set from
  `docs/SHIM_SUITE_CONVENTION.md` S4.1; `ShimTest::OracleReading` and
  `ShimTest::ConvertedReading` are distinct, non-interconvertible types, so a
  `Compare()` call with the two arguments swapped is a compile error, not a
  convention a reviewer has to notice broken.
- `cpp-test-shim-comparison` (F1.2, `harness`): the comparator's own
  synthetic truth table, driven from literals -- every verdict, both
  orientations of the asymmetric ones, the empty-vs-empty presence trap, and
  the shape-mismatch case. No rule table, no fixture, no pulse: a
  pulse-based test can never prove its own oracle right.
- `cpp-test-shim-verdict-orientation` (F1.3, `harness`): the source check
  covering the one mistake the type system above cannot catch -- a call that
  spells both `oracle=`/`converted=` comments correctly but wraps the wrong
  reading in each. It counts how many named sides it finds across this
  directory and fails below a floor, so it cannot pass by finding nothing;
  the floor rises as later tickets add their own `Compare()` call sites.
- **`../../imas-python-fixtures/`** (vendored verbatim from IMAS-Fortran, see
  its own README): two completely filled `equilibrium` HDF5 pulses, DD
  3.39.0 and DD 4.1.1, describing one equilibrium, generated from a single
  shared value table by two modules that decide only *where* each value
  goes. Every fixture-driven family this suite still needs (issues #13, #14,
  #21) reads its expected values out of these pulses rather than out of a
  literal (`docs/SHIM_SUITE_CONVENTION.md` D4).
- `cpp-test-shim-fixture-provenance` (F1.4, `harness`): regenerates the pair
  outside the checkout with `imas-python-fixtures/verify_fixtures.sh` and
  compares every HDF5 dataset against the checked-in oracle with `h5diff`.
  Registers only when the fixtures' own venv (`imas-python-fixtures/.venv`,
  see its README) and `h5diff` are both present; a missing prerequisite
  skips the test rather than passing it without comparing.
- `derive_stamp_variant.py` / `cpp-test-shim-stamp-variants`: three
  stamp-state fixtures -- stamp **absent** (the version dataset deleted),
  stamp **malformed** (a value that fails the version grammar), and stamp
  **mismatched with no artifact** (a grammar-valid known release neither
  this suite's HLI version nor DD 3.39.0) -- derived from the checked-in DD
  3.39.0 pulse at build time via a `cpp-test-shim-stamp-fixtures` `ALL`
  target, never committed. `cpp-test-shim-stamp-variants` (`harness`) checks
  the three keep the states F2.3 and F3.1 need distinct, rather than trusting
  the derivation script did. Registers only when the venv additionally has
  `h5py`.
- `al_cpp_shim_private_fixture_copy()` / `cpp-test-shim-fixture-copy`: the
  CMake function a write scenario (issue #21) uses to get a freshly made
  private copy of a fixture, so parallel scenarios cannot collide and a
  failed run leaves no poison. The self-test exercises it against a
  synthetic directory, not a pulse.
- `fixture_digest.cmake` / `verify_fixture_unchanged.cmake` /
  `cpp-test-shim-fixture-digest`: the content-digest helper a read scenario
  (issues #13, #14, #24) wraps its executable in to prove the checked-in
  fixture it read is unchanged afterwards -- content, not mtime, because an
  HDF5 rewrite can leave both alone. The self-test exercises it against a
  synthetic directory too.
- `cpp-test-shim-stamp-malformed` (F3.1, `contract-assertion`): opens the
  derived malformed-stamp fixture's data entry successfully, then asserts the
  first occurrence-opening HLI call (`equilibrium.get`) returns a refusal-band
  status, leaves the IDS declared-but-empty and records no skipped path. Its
  frozen reason is the suite's one named exception to public-return-value-only
  assertions: `get` prints the occurrence-open message instead of returning
  it, so the fixture wrapper reads the program's standard output only after
  the executable has validated the refusal-band status and exited cleanly. It
  also gets a fresh private loss-log directory because its refused occurrence
  open may otherwise leave a loss log in CTest's shared working directory.
- `cpp-test-shim-version-unset`, `cpp-test-shim-stamp-equal`,
  `cpp-test-shim-stamp-absent`, and
  `cpp-test-shim-stamp-mismatch-no-artifact` (F2.1--F2.4,
  `contract-assertion`): four separately launched HDF5 reads covering every
  state in which the shim must forward untouched. Each proves clean success,
  no skipped paths, fixture data, an unchanged fixture, and an empty private
  loss-log directory. The version-unset registration composes an environment
  without `IMAS_MVDD_HLI_DD_VERSION`; it does not clear an injected value. The
  mismatch-without-artifact scenario also checks that the newer-DD-only
  `beta_tor_norm` remains absent, and its source header records why its
  otherwise indistinguishable result must remain a separate scenario.

- `cpp-test-shim-structural-rules` (F4.1, `contract-assertion`, HDF5 builds): reads the
  DD 3.39.0 fixture through the shim and the DD 4.1.1 fixture same-version,
  then checks all 23 structural rules at the public C++ HLI. Its hand-authored
  table has 23 structural, 30 COCOS, 13 right-only, and 5 refusal entries;
  every entry cites the conversion map or fixture provenance. The transcription
  audit records the externally reachable map's unresolved includes (including
  common renames), its actual 30 COCOS flips, and the two fixture-only
  negations inside DD-4-only structures. It also records that four historical
  chi-squared unit redefinitions now fall through as identical in the map.
  The map wins over the stale quoted count of 32. Each rule derives its expected verdict from the shared
  kind mapping, and a multi-leaf rule reports its first non-agreeing verdict.
- `cpp-test-shim-cocos-rules` (F4.2, `contract-assertion`, HDF5 builds): reads
  the same fixture pair through the public HLI and checks every one of the
  table's 30 map-declared COCOS paths. Each expects the shared kind mapping's
  `same` verdict. A stopped sign flip therefore reports the comparator's
  `no-flip` verdict as a failed assertion, naming the rule id, kind and cited
  map/fixture source. The program counts checked entries against the table's
  own size, so it cannot report coverage for the two fixture-only negations.
- `cpp-test-shim-right-only-rules` (F4.3, `contract-assertion`, HDF5 builds): reads the
  same two fixtures as F4.1 and checks all 13 `right_only` rules in the shared
  table. Expects `ONLY_ORACLE` per rule -- the shim correctly serves nothing,
  and the oracle holds a real value proving the comparison is not vacuous.
  Carries the D6 vacuity demonstration this family requires: one right-only
  rule's converted reading, already established served-nothing by the
  ordinary check above it, is put through the same `Compare()` predicate
  against a real oracle value taken from an unrelated structural-table entry
  (`identical-vacuum-r0`), and must disagree with that entry's own agreement
  expectation. Without that demonstration, a shim serving nothing at all
  would satisfy every right-only rule for the wrong reason. The one
  right-only path this test indexes through an array-of-structures element
  (`constraints/j_parallel`) guards the converted side's element access on
  its own extent instead of assuming it was resized, since the path has no
  DD 3 source to resize it from. Per docs/SHIM_SUITE_CONVENTION.md S2.1, a
  converted reading that turns out neither absent nor `ONLY_ORACLE` is
  printed as its own named finding, separate from the ordinary rule-mismatch
  message: a field reading back as a plausible-looking value instead of the
  invalid sentinel is a worse outcome than a wrong one and this suite's job
  is to say so, not fold it into an unremarkable failure. IMAS-Fortran found
  exactly this on its own HLI (five `right_only` paths reading back as
  uninitialised memory, one as four ASCII spaces landing on an integer
  field). On this C++ HLI, on `MacBook-Pro-de-Yohann.local` (Darwin 25.6.0,
  arm64) on 2026-09-16, every one of the 13 `right_only` paths read back as
  the DD invalid sentinel (`EMPTY_DOUBLE`/`EMPTY_INT`) on the converted side
  -- no finding was printed. Re-run the test before treating that as a
  statement about another build or host.
- `cpp-test-shim-refusal-channels` (F4.4, `contract-assertion`, HDF5 builds): the same two
  reads as F4.1, asserting that the map's `retyped` rule --
  `grids_ggd/grid/space/coordinates_type` (an int array in DD 3.39.0, an array
  of identifier structures in DD 4.1.1, no transformation reshapes one into
  the other) -- is reported on all three refusal channels rather than merely
  tolerated: the value is left absent, the path is named in the skipped-path
  record, and the read reports `PARTIAL_READ`. Three structural checks show
  the refusal was absorbed at the field, not by truncating its surroundings:
  the enclosing containers survived, a field read after it within the same
  structure arrived, and a field served later in the traversal (equilibrium's
  root `time`) still agrees with the oracle. The two reads use independent
  `IdsNs::IDS` objects (as F4.1 does), so the oracle read cannot reach the
  converted read's own record; the program still copies that record out
  before the oracle read runs, matching the ordering
  `docs/SHIM_SUITE_CONVENTION.md` S5.4 states -- the record resets at the
  start of each root operation -- so the assertion stays correct if a future
  revision shares one object across both reads. `tests/shim/shim_refusal_match.h` is the shared
  record-matching predicate the next refusal-family ticket reuses: it matches
  the operation, the full DD path (on the tail of the message's `DD path: `
  field, so it tolerates truncation and a future generator prefixing that
  field with more context), the reason substring, and the refusal-status
  band. It also checks all four unit-`redefined` globs: each value agrees with
  the oracle and has no read skipped-path record. The test rejects any record
  for the full DD path, which is stricter than recognizing only a particular
  reason or refusal-band code, while still reusing the shared full
  path/reason/band matcher; each rule-level failure names its id, kind, and
  citation, and the two assertions per rule are counted from the table size.
- `cpp-test-shim-nested-loss` (F5.1, `contract-assertion`, HDF5 builds,
  issue #20): the program reads the full older-DD pulse and checks only
  `PARTIAL_READ` and a nonempty skipped-path record. Its CMake wrapper requires
  a clean program exit and an unchanged fixture, then inspects exactly one
  file in a private directory cleaned before each run. It pins the format-1
  marker and line-five header, checks seven columns on every row, and compares
  the set of operation/fidelity/path triples for equality (duplicates allowed).
  The 14 `LOSSY` and three `UNMAPPABLE` rows are explained in
  `check_nested_loss_log.cmake`: the latter reflect array-of-structures open
  refusals, including the retyped coordinates container. This pins a refusal
  decision; a change to return empty containers may turn it red on an
  improvement. Suspect that decision before a mapping regression, and check
  DD shape before interpreting sibling fidelities. Historical unit-redefinition
  refusals are removed into a separate known-defect set and each is reported
  as `LOSS-LOG-REDEFINITION-FAILURE`, consistent with issue #19's served-value
  assertions. `cpp-test-shim-loss-log-harness` (`harness`) tests the wrapper
  from a literal report, including malformed files, exact-set differences,
  known defects, fixture mutation, and nonzero program exits.
- `cpp-test-shim-roundtrip-cross-dd` and `cpp-test-shim-roundtrip-same-dd`
  (F6.1--F6.2, `contract-assertion`): two registrations of one program that
  appends a curated `psi_axis` value at a COCOS sign-flip path, then reads the
  entire occurrence back. Each setup creates a fresh private fixture copy and
  loss-log directory. The older-DD run explicitly permits a partial read; the
  same-DD control explicitly requires a clean read. Both require the slice and
  time base to grow by one, preserve time mode, and return the appended time
  and value. The source header records why this consistency check cannot prove
  the stored path, raw sign, stamp, or candidate selection. A paired CTest
  fixture owns exactly the two program runs and records both controls before
  either named case can report a round-trip result without its control.

The round-trip pair establishes this suite's **Profile A** direction: a DD
4.1.1 HLI reads and writes DD 3.39.0 pulses, tolerating per-field refusals as
partial operations. Its same-DD DD 4.1.1 control proves that a successful
round trip did not merely avoid conversion. It does not establish the broader
read-rule catalogue or native on-disk assertions; those remain separate
families under `docs/SHIM_SUITE_CONVENTION.md` S5.

- `cpp-test-shim-torn-write` (F6.3, **`behaviour-pin`**): against a fresh
  private copy of the older-DD pulse, appends one slice carrying both the
  mapped, COCOS-flipped `global_quantities/psi_axis` and
  `global_quantities/rho_tor_boundary` -- a field the shim's own conversion
  map (`IMAS-Multiversion-DD-Loader`'s `docs/3.39.0--4.1.1.xml`, rule
  `new-global-quantities-rho-tor-boundary`) records as `right_only`: "path
  added in DD 3.40.0; no counterpart in 3.39.0", forward direction
  `unmappable`. Asserts the `putSlice` reports `PARTIAL_PUT`; that
  `getSkippedPaths()` names the specific refused `Write` of
  `global_quantities/rho_tor_boundary` (a slice put writes every field of the
  whole appended element, so other unmapped fields under it may also be
  refused -- this pin cares about one field by name, not about being the
  only refusal); and, on the read-back, that the time-slice and time-base
  containers each grew by exactly one, the mapped `psi_axis` value the
  refusal ran alongside is readable, and the refused field itself stayed
  empty. `verify_torn_write.cmake` also asserts the traversal's own
  `REFUSED WRITE: global_quantities/rho_tor_boundary` diagnostic
  (`IdsNs::Ids::mustAbort`, `src/IdsDef.cpp`) reached the program's standard
  output and not its standard error. This is a pin on an accepted
  limitation, not a statement that a torn write is desirable: the generated
  write traversal has no rollback, so a refusal partway through leaves
  everything already written on disk, and the container one element longer
  regardless, because the array-of-structures open widens it before any leaf
  write runs.

- `cpp-test-shim-full-put-stamp` (F6.4, `contract-assertion`): against a
  fresh private copy of the older-DD pulse, reads the occurrence, sets a
  marker value at `vacuum_toroidal_field/r0` -- the field the generated
  traversal reaches immediately after `ids_properties` -- and issues a
  **full put** (`put()`, not `putSlice()`; a slice put has an empty body for
  `ids_properties/version_put/data_dictionary`, the DD-version stamp, and
  never reaches it at all). A full put's `put()` opens by calling its own
  `deleteAll()`, which deletes every other field of the previous occurrence
  but refuses the delete that would remove the stamp while data remains;
  `put()` then rewrites every field, including the stamp itself hardcoded to
  this HLI's own compiled DD version, whose write is refused too under the
  mismatch. Asserts the refused delete and the refused write each on their
  own counter -- either refusal alone already makes the summary status
  partial, so the status cannot say whether both seams, or only one,
  refused -- then asserts the status as the derived `PARTIAL_PUT` outcome
  it is, and, on the read-back, that the marker field reads back (proving
  the traversal finished) and the stamp still names the fixture's own
  `3.39.0`, never this HLI's `4.1.1`. `verify_full_put_stamp.cmake`
  additionally asserts both `REFUSED DELETE:
  ids_properties/version_put/data_dictionary` and `REFUSED WRITE:
  ids_properties/version_put/data_dictionary` (`IdsNs::Ids::mustAbort`,
  `src/IdsDef.cpp`) reached the program's standard output and not its
  standard error. Unlike F6.3, this pins a **requirement** of the shim, not
  an accepted limitation.

IMAS-Core is pinned to a fork commit carrying the path-aware HDF5 delete fix
(IMAS-Core #63/#64) whenever `AL_USE_MULTIVERSION_SHIM=ON` -- see the comment
at the top of the repository's `CMakeLists.txt`. Without it, `F6.4
full-put-stamp` would be red for a reason in neither this repository nor the
shim: the first delete a full put issues would destroy the whole occurrence
instead of sparing the stamp, the refused stamp delete would then protect
nothing, the stamp probe that follows would find no occurrence, an absent
stamp is presumed to match, no conversion is armed, and every write becomes
an untranslated forward.

## Running the labels

From a configured shim build directory:

```sh
ctest --test-dir <shim-build> -L shim --output-on-failure
ctest --test-dir <shim-build> -L harness --output-on-failure
```

Every `contract-assertion` test (F2.1-F2.4, F3.1, F4.1-F4.4, F5.1, F6.1-F6.2,
F6.4 — see "Scenario catalogue" above) follows `docs/SHIM_SUITE_CONVENTION.md`
S1 D5 and stays red while the shim disagrees, never inverted, quarantined, or
softened to match observed behaviour.
`cpp-test-shim-torn-write` (F6.3) is this suite's one `behaviour-pin`: it
preserves an accepted limitation (no rollback on a refused write) rather than
asserting a requirement of the shim, so nothing here should ever change to
give it atomic rollback.

## Red list

There are no `contract-assertion` tests currently red.

This is what a full run of `ctest -L shim` printed on **2026-09-17** on
`MacBook-Pro-de-Yohann.local` (Darwin 25.6.0, arm64): 42 shim-labelled tests
(13 `contract-assertion` — exactly the catalogue rows F2.1-F2.4, F3.1,
F4.1-F4.4, F5.1, F6.1-F6.2, F6.4 — 1 `behaviour-pin`, and 28 `harness`:
9 harness scenarios, the round-trip pair runner, and the 18 fixture-copy and
loss-log-clean setup registrations, which carry `harness` because the
convention admits no unlabelled test), **all passed**. The build loaded:

- **Shim**: IMAS-Multiversion-DD-Loader `v0.2.0-58-g51e64b0`
  (`51e64b05a34e7fb1ebf495885eaae8085903d2b7`),
  `libimas_mvdd_loader.0.1.0.dylib`.
- **IMAS-Core**: commit `dae4abdd9428bd28f47063f8f575bdc8abd915f2`,
  `libal.5.7.2.86.dylib` — the fork commit carrying the path-aware HDF5 delete
  fix (IMAS-Core #63/#64) that F6.4 depends on (see below).

The same suite was then observed on Linux (ubuntu-24.04, x86-64) by
IMAS-Multiversion-DD-Loader run `35238451263` on **2026-09-17**, against the
same IMAS-Core and shim `d07b34c`: 41 of the 42 registered there — F1.4
fixture-provenance needs an `h5diff` that job does not install, see "CI" below
— and all 41 passed. Nothing was red on either machine.

Per `docs/SHIM_SUITE_CONVENTION.md` S1 D5, three rules govern this list, each
learned the hard way by IMAS-Fortran:

1. **Observed, not inferred.** This entry is what the run above printed, not a
   reconstruction from tickets or commit messages — reds that emerge only from
   a particular combination of shim and core appear in no ticket.
2. **The IMAS-Core matters.** F6.4 (`full-put-stamp`) is red against a
   plain upstream IMAS-Core whose HDF5 delete ignores its `path` argument (see
   the note under F6.4's description above), and green against the fork commit
   named here, for a reason living in neither this repository nor the shim. A
   count of reds without the core named describes a different system than the
   reader's.
3. **Corrected entries are kept, not deleted.** If a future run finds this list
   wrong — the wrong owner, the wrong seam, a scenario that turns out red for a
   reason nobody looked for — the correction is recorded here in place, and the
   superseded belief stays visible rather than being erased. There is nothing
   to correct yet.

**An empty red list is a weaker statement than it looks** (D6). It says
nothing was red in *this* run, on *this* machine, against *this* shim and
*this* core — not that the suite was sensitive enough to notice a real
regression. That is exactly what the linkage check (F1.1), the run guards on
every program, and the vacuity demonstration in F4.3 are for: most of these
tests pass by *not printing*, so a build that converted nothing would pass
exactly like a build that converted everything, if nothing else here caught
that. Re-run the shim-labelled suite (and `cpp-test-shim-linkage` first)
before treating this observation as a statement about another machine, shim,
or IMAS-Core build.

## Coverage boundaries

These are boundaries, not disclaimers (`docs/SHIM_SUITE_CONVENTION.md` S8),
restated for this HLI:

1. **One direction.** This suite is a DD 4.1.1 HLI reading and writing a DD
   3.39.0 pulse, in that direction only (see "Profile and direction" above).
   The reverse needs a second from-scratch build of `al-cpp` against DD
   3.39.0, which this repository does not produce. In the shipped
   `imas-python-fixtures/` artifact that leaves the **23 `left_only` rules**
   (paths DD 3.39.0 had and DD 4.1.1 dropped) permanently unreachable here.
2. **A rule, not every leaf, is the unit of assertion** (D3). F4.1's
   `structural-rules` samples multi-leaf rules (see `shim_rule_table.h`); a
   shim serving only part of a subtree a rule governs escapes detection.
3. **No C-ABI tests** (D1). Nothing here binds an `imas_mvdd_*` symbol; the
   shim repository owns seam-level coverage (a mid-fan-out delete failure, a
   null buffer, a bad loss-export index) that no HLI call can reach.
4. **One named exception reaches below the public return value.**
   `cpp-test-shim-stamp-malformed` (F3.1) reads its frozen refusal *reason*
   from generated `get`'s standard output, because that message is printed at
   the occurrence-open seam but not returned to the caller. It is guarded by
   first asserting the refusal-band status through the public API. This is the
   suite's only assertion that looks past what a caller of the public HLI can
   observe.
5. **Per-candidate delete effects are not observable.** The HDF5 backend's
   delete ignores its `path` argument and removes the whole occurrence, so a
   candidate fan-out (as F6.4's full `put()` exercises) collapses to one
   whole-occurrence deletion from this suite's vantage point. The call
   sequence would need a recording stub in the shim repository to test
   separately from the on-disk consequence.
6. **Timebase conversion beyond identity is untested.** `time` is untouched by
   any rule in the shipped conversion map, so F6.1/F6.2's round trip and every
   other scenario here exercise timebase resolution at exact fidelity only.
7. **`datapath` translation on a first open is untested.** It only fires from
   an occurrence's second open onward, and no scenario here reopens an
   occurrence a second time.
8. **Merged-rule loss is ambiguity, not a measurement.** The shim never reads
   a merged field's untried candidates to check whether they held different
   data; the `PotentiallyLossy`/`LOSSY` fidelity F5.1 pins for those rows is a
   statement about the *rule*, never a verified fact about the occurrence.

## Asks of the shim, carried forward

Three surfaces this convention — and therefore this suite — depends on
(`docs/SHIM_SUITE_CONVENTION.md` S10), reproduced here so a second HLI adopting
the convention makes the same asks rather than working around them silently:

1. **Keep the loss file's format marker, preamble, column order, filename
   pattern and `IMAS_MVDD_LOSS_LOG_DIR` semantics as a versioned contract.**
   It is the only loss channel this Tier-1 suite has (F5.1,
   `cpp-test-shim-loss-log-harness`).
2. **Publish a flattened, machine-readable rule manifest.** The externally
   reachable conversion map has unresolved `<include>`s (S4.5), which is why
   `shim_rule_table.h` is hand-authored rather than generated. A manifest
   would let that table be generated and checked instead of merely trusted.
3. **Provide a preflight check for dynamic loading and ABI compatibility.**
   Today a missing or incompatible IMAS-Core surfaces as a generic failure a
   contributor can mistake for a conversion-contract violation (S2.2).

## CI

This suite now runs in CI — not from this repository, which registers no
workflow, but from the shim's: IMAS-Multiversion-DD-Loader's
`.github/workflows/hli-validation.yml` pins this fork by commit and builds it
with `AL_USE_MULTIVERSION_SHIM=ON`.

That is the decision this section used to say had to be taken explicitly, and
the condition it set was met before it was taken: the red list above was
already empty. What the decision buys is the thing no run on one developer's
machine can give — a second machine, a second operating system, and a build
nobody configured by hand.

**CI registers 41 of the 42 below, not all of them.** The job provisions
`imas-python-fixtures/.venv` with h5py alone, which is what the five
stamp-state scenarios (F2.1–F2.4, F3.1) need to have their fixtures derived,
and it does not install `h5diff` — so F1.4 fixture-provenance does not register
there. That is deliberate: regenerating the pair needs imas-python, and the job
would then be comparing the checked-in fixtures against whatever Data
Dictionary `pip` resolved that morning, which can go red for a reason living in
neither this HLI nor the shim. Fixture provenance stays a check you run here,
against the venv described in `imas-python-fixtures/README.md`. The workflow
asserts the number 41 rather than assuming it, so if either prerequisite
appears in that image the count changes and the job says so by name.

First observed on Linux on **2026-09-17**, IMAS-Multiversion-DD-Loader run
`35238451263`: **65 registered tests, all passed**, 41 of them this suite's,
against shim `d07b34c` and the same IMAS-Core `dae4abd` named in the red list
above. Per D5 rule 1 that remains an observation of one machine, one shim and
one core rather than a general statement — but it is now two machines and two
operating systems making the same one.
