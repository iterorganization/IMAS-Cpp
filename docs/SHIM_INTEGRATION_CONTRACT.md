# What an HLI should expect from the shim: read, write, delete under a DD version mismatch

Audience: someone writing HLI-side integration tests against this shim (including
round-trip tests) who needs to know precisely what varies by scenario, what is
guaranteed, and what a round trip cannot prove. This is a synthesis of
`docs/adr/0002`, `0005`, `0007`, `0008`, `0009`, `0012`, `0016`–`0021`, `0023`,
`0024` and the
current `src/conversion/seam_policy.rs` / `src/lib.rs`. Where this document and
an ADR disagree, the ADR (or the code) is authoritative — this file only
collects and orders what they already say, with one exception: **§8 is a
frozen surface, not a summary.** The refusal reason strings listed there are
what downstream tests are invited to assert on, so a change to one of those
strings in `src/` is a change to this document's contract and must land in
the same commit.

## 1. Vocabulary you need before reading the matrices

- **HLI DD version**: the version latched process-wide via
  `imas_mvdd_set_hli_dd_version` (first-use-wins) or `IMAS_MVDD_HLI_DD_VERSION`.
  One process gets exactly one value for its whole life; a later conflicting
  report is refused, an identical repeat is accepted (ADR 0005). If neither is
  ever set, the shim does zero version discovery on any seam and is pure
  passthrough — this is the "unset" row in every matrix below.
- **Stamp**: `ids_properties/version_put/data_dictionary` on an IDS occurrence.
  Read once, at occurrence-open time, to discover the *stored* DD version.
- **Artifact**: one hand-authored conversion map. Exactly one exists today —
  equilibrium, 3.39.0 ⇄ 4.1.1 (`docs/3.39.0--4.1.1.xml`). Its rule mix: 4
  `identical`, 23 `left_only`, 13 `right_only`, 5 `renamed`, 3 `moved`, 13
  `merged`, 1 `split`, 1 `retyped`.
- **A registered conversion context** ("root record") exists only when the
  stamp names a stored version that (a) differs from the HLI version and (b)
  has an embedded artifact for that (IDS, stored, HLI) triple. This is the
  only condition under which reads/writes/deletes on that occurrence are
  translated or logged at all.
- **Fidelity**: `Exact`, `PotentiallyLossy`, `Lossy`, `Unmappable` (ADR 0008).
  Never surfaced through `al_status_t` on a successful call — only through the
  loss log (§7).
- **Candidate plan**: where one HLI-side path can mean several stored paths
  (a `merged` or `split` rule), each stored path is a candidate with a
  declared precedence. Read tries them in order; write touches only
  precedence 1; delete fans out over all of them. This asymmetry is
  deliberate (ADR 0017) — see §6.

## 2. Preconditions your test harness must set up deliberately

1. **Pick the HLI DD version once per process**, before any open. You cannot
   test "what happens on a version conflict" and "what happens on a clean
   mismatch" in the same process — the second `imas_mvdd_set_hli_dd_version`
   call with a *different* value is refused, not applied (ADR 0005). Two
   scenarios need two processes.
2. **To exercise real conversion, use IDS `equilibrium` with stored/HLI
   versions `3.39.0` and `4.1.1` (either direction).** Any other IDS, or any
   other version pair, has no embedded artifact: the stamp is read, a
   mismatch is *detected*, but `known_artifacts::lookup` returns `None`, no
   root context is registered, and every subsequent read/write/delete on that
   occurrence forwards completely unconverted — indistinguishable at the ABI
   from a matching-version occurrence. **A version mismatch alone does not
   imply conversion.** Don't write a test that asserts conversion happened
   just because the stamps differ; assert it only for the one covered pair.
3. **The stamp is read once, at occurrence-open time** (`al_begin_global_action`,
   `al_begin_slice_action`, `al_begin_timerange_action`), not per-field. A test
   that wants a mismatched-occurrence scenario must have written that stamp
   before the open your test measures — which in practice means either a
   fixture file with the stamp pre-set, or a prior process run under the
   *other* DD version that performed an ordinary `put`.
4. **`al_begin_global_action`'s `datapath` translates only on the occurrence's
   second-or-later open in the same process.** The first open of any given
   occurrence forwards `datapath` unchanged, because discovery (which needs
   the open to have already happened) hasn't cached anything for it yet
   (ADR 0002). If your test cares about `datapath` translation specifically,
   open, close, and reopen the same occurrence.
5. **A write/delete-mode open still discovers the stamp correctly** as of
   ADR 0020: for any `rwmode != READ_OP`, the shim opens its own throwaway
   `READ_OP` probe context first to read the stamp, then proceeds with your
   open. You do not need to open `READ_OP` yourself to get correct
   registration on a `WRITE_OP` open — but know this costs one extra
   open/read/close per occurrence-open, invisible to you except as latency,
   and it requires opening a second context on the same pulse (proven on
   HDF5; unproven on the other five backends).

## 3. Occurrence-open outcomes, by stamp state

This happens before any `al_read_data`/`al_write_data`/`al_delete_data` call —
get this table wrong in your fixture and every downstream expectation is
wrong too.

| Stamp as read at open | Registration | What happens to the open call itself |
|---|---|---|
| Absent (no `version_put/data_dictionary` at all) | Nothing registered; occurrence presumed to match HLI (ADR 0007) | Open succeeds, forwarded exactly as issued |
| Present, valid, equal to HLI version | Nothing registered | Open succeeds, forwarded exactly as issued |
| Present, valid, differs from HLI version, **no embedded artifact** for that (IDS, stored, HLI) triple | Nothing registered, but the occurrence-cache remembers the mismatch (affects only a later `datapath` translation, §2.4) | Open succeeds; every later data seam on this occurrence forwards unconverted |
| Present, valid, differs from HLI version, **artifact exists** | Root conversion context registered | Open succeeds; later data seams on this occurrence convert |
| Present but **malformed** (fails the grammar in ADR 0009: not a bare `MAJOR.MINOR.PATCH` from the known chain, and not exactly `MAJOR.MINOR.PATCH-N-gHASH`) | Nothing registered | **The open itself refuses**, and the context IMAS-Core just opened is closed again by the shim before returning to you. You get a refusal from the *open* seam, not from a later read/write. Test this by opening, not by reading. |

A malformed stamp is not treated as absent — absence means "no stamp field";
a present-but-invalid value is treated as unsafe metadata and refused loudly
(ADR 0009). Don't conflate these two in a fixture.

## 4. Read (`al_read_data` / `al_plugin_read_data`)

Applies only when a root context is registered (§3, last two rows). Otherwise
every read is a plain forward: `field`/`timebase` unchanged, no value
transformation, `code == 0` and null data mean not-found exactly as IMAS-Core
reports it, and nothing is logged.

When a root *is* registered:

- `field` and `timebase` are each resolved independently against the
  artifact. Either one resolving to a refusal (e.g. the one `retyped` rule —
  always refused, unconditionally, even where the artifact marks it `exact`,
  because the shim cannot reshape an int array into an identifier struct) or
  to "no source" (a `left_only`/`right_only` case with nothing on the other
  side) ends the call immediately: the *other* argument is reported at
  `Fidelity::Exact` regardless of its own resolution, because the loop never
  gets far enough to evaluate it.
- Otherwise, every combination of a field candidate × a timebase candidate is
  tried in declared precedence order until one field candidate returns data.
  A `renamed`/`moved`/identity resolution is a one-candidate list; a `merged`
  or `split` resolution is an ordered multi-candidate list. **The first
  candidate that returns data wins**, and that candidate's own declared
  fidelity (which may be `PotentiallyLossy`, e.g. for a `merged` field) is
  what gets logged — not automatically `Lossy` just because it wasn't the
  first candidate tried.
- A value transformation (today: only a COCOS sign flip, only on
  `DOUBLE_DATA`, rank `0..=MAXDIM`) is validated against the buffer's declared
  shape *before* any candidate is tried, and applied *in place* on the buffer
  IMAS-Core wrote, only after data is actually found. An unsupported shape
  (wrong datatype, or rank outside `0..=MAXDIM`) refuses before the reader is
  ever called, at `Fidelity::Unmappable`.
- The three-way outcome IMAS-Core actually reports — failure (`code != 0`),
  not-found (`code == 0`, null data), success — is what drives whether the
  loop tries the next candidate (only on not-found) or returns immediately
  (on failure or on data). A backend failure on one candidate is *not*
  swallowed to try the next candidate; only "not found" continues the loop.
- If every candidate reports not-found, the overall result is not-found
  (`code == 0`, no data), and the reported fidelity is the resolution's own
  translated fidelity even though nothing was read.

**What to assert in a read test:** the returned value and `al_status_t.code`;
the fidelity and DD path recorded in the loss log for that read (§7) — never
assume anything about fidelity from `al_status_t` alone, since a lossy read
still returns `code == 0`.

## 5. Write (`al_write_data` / `al_plugin_write_data`)

Same gate: only a registered root context converts anything; otherwise plain
forward. When registered, `field` and `timebase` resolve **independently**,
and either one failing to produce a safe stored spelling refuses the *entire*
write before IMAS-Core is ever called (`field`'s refusal is reported ahead of
`timebase`'s, if both would refuse). The refusal is always reported before
any data reaches Core — the shim's own rule is "never return `code == 0` for
data it did not store", with exactly one exception (the sentinel case
below).

| Situation | Outcome |
|---|---|
| `field` resolves through a non-primary source (`precedence != 1` in a `merged`/`split` rule) | **Refused**, before Core is called. Only the precedence-1 HLI-side spelling may write. |
| `field` resolves to a stored slot that doesn't exist (a `right_only` rule — in this artifact, 13 paths all under `time_slice`) | **Refused**, before Core is called. This is the one case reachable through ordinary `put_slice` use, not just a full `put` — see the torn-write note below. |
| `field` resolves via `merged`/`split` to several stored candidates, one at precedence 1 | Only the precedence-1 candidate is written. Every other candidate's **complete stored-DD path** (not the caller's own path) is appended to the loss log as `PotentiallyLossy`, and **only after** Core accepts the precedence-1 write. `Lossy` never appears as a write-path verdict in this artifact — it is asserted unreachable, not merely unused. |
| The value transformation for `field` cannot be inverted (would need `ValueTransformation::inverse()` to succeed; today every COCOS flip in this artifact does invert) | **Refused**, before Core is called. |
| The buffer's declared shape can't carry the transformation (wrong datatype, or rank outside `0..=MAXDIM`) | **Refused**, before Core is called, before the source buffer is even copied. |
| The source is a **rank-0 scalar exactly equal to IMAS-Core's own sentinel** (`EMPTY_DOUBLE = -9.0E40` for `DOUBLE_DATA`) | Forwarded **unchanged**, no transformation applied, **no loss log entry**, `code == 0`. This is not a refusal and not a lossy write — IMAS-Core itself would have skipped storing it regardless (`data_has_non_zero_shape` gate), so nothing was lost. A sentinel-valued *element inside a non-scalar array* is **not** caught by this — it is transformed like any other value, which is a known, accepted gap (not guarded, for cost reasons). |
| A write to the DD-version stamp itself (`ids_properties/version_put/data_dictionary`), under a mismatch | **Refused** always. The shim never rewrites the stamp. In practice this only fires on a full `put` into an already-mismatched, already-stamped occurrence (a "migration" write) — `put_slice` never touches this field at all (its generated code has an empty body for it), so the ordinary append workflow never hits this refusal. |
| A delete that would remove the stamp while leaving data behind | **Refused** (see §6) — this is a delete rule, listed here only because it protects the same invariant. |
| Everything else | Written, exact, no loss entry. |

**Torn-write hazard — required reading before writing a `put_slice`
integration test.** IMAS-Fortran's generated `put`/`put_slice` routines have
no rollback. A refusal partway through a slice (most likely: one of the 13
`right_only` fields under `time_slice` that a DD4 caller fills and a DD3
occurrence has no slot for) leaves **everything already written earlier in
that same call on disk**, and the `time_slice` container one element longer
regardless (the caller's own `al_begin_arraystruct_action` widened it before
any leaf write ran, and Core commits that shape at end-action time no matter
what happens after). Against an unmodified upstream IMAS-Fortran, **do not
expect a clean all-or-nothing failure from a refused `put_slice`** — expect a
torn slice plus a refusal. Only a patched IMAS-Fortran (tracked upstream as
`yohannmarguier/IMAS-Fortran#61`, not yet merged as of this writing) tolerates
the refusal field-by-field the way the read path already does via
`al_get_policy`. This is a documented limitation of the shim, not a defect to
chase — see README.md's "Scope and limitations".

**A refusal here can also crash the process, not just fail the call**, in one
specific structural case unrelated to your own writes: IMAS-Core's own
internal plugin machinery (`AccessLayerPluginManager::write_field` and
friends) calls back into these same seams and `assert()`s `code == 0` on the
result. For the shipped equilibrium artifact this is unreachable (nothing
claims a rule under `ids_properties/plugins/**`), but it is a structural
exposure the first artifact touching that subtree must reopen.

## 6. Delete (`al_delete_data`)

Same registration gate as read/write. When registered:

| Situation | Outcome |
|---|---|
| `path` resolves through a non-primary source | **Refused**, same rule as write. |
| `path` resolves to one stored path (identity, `renamed`, `moved`) | One `al_delete_data` call to Core with that stored spelling. |
| `path` resolves to several candidates (`merged`/`split`) | **Every candidate is deleted**, unconditionally, with **no presence probe** beforehand. This is the opposite answer from write's precedence-1-only rule, and it is deliberate (ADR 0017): a write asserts a value it must not fabricate into an assumed-equivalent slot, but a delete asserts an absence, and leaving a stale candidate behind would let the read path's own fallback serve it as live data after a delete the caller was told succeeded. |
| One or more candidates fail | **All candidates are still attempted** (no early exit); the **first** nonzero status is what's returned to the caller, after every candidate has been tried. An absent candidate is indistinguishable from a genuine backend failure at the ABI (`al_delete_data` has no not-found outcome), so a missing candidate can *look like* a failure even when the delete "worked" as well as it could. |
| A delete refuses | One `UNMAPPABLE` `DELETE` loss records the caller's complete HLI-DD path before the ordinary refusal returns. |
| A candidate plan completes | One `POTENTIALLY_LOSSY` `DELETE` loss records each stored candidate after all candidates have been attempted, including when the first failure is returned. |
| `path` names a structure (not a leaf) whose subtree contains an **escaping rule** — a rule at or under `path` with at least one stored-side target outside the resolved stored subtree | **Refused**, before any candidate is touched. A leaf delete is always trivial (never refuses on this basis). On the shipped artifact this refuses `time_slice/boundary_separatrix` from a DD3 HLI and `time_slice/boundary` from a DD4 HLI, but allows `time_slice`, `time_slice/constraints`, and every leaf. |
| `path` is empty | Forwards **unchanged**, unconditionally — this is IMAS-Core's own "delete the whole DATAOBJECT" contract. It is the *only* legitimate way to migrate a mismatched occurrence: afterwards the occurrence is unstamped, so ADR 0007 makes the next open treat it as matching the HLI, and it can be written fresh. It is also the sole exception to "any delete touching the stamp refuses" — because it removes the data too, nothing is left to misread. |

**The delete seam records destructive fidelity explicitly** (ADR 0024). A
refusal names the caller's HLI-DD path as `UNMAPPABLE`; a fan-out names every
visited stored candidate as `POTENTIALLY_LOSSY`, in both the root-context log
and its append-only file. A one-path delete remains exact and records nothing.

**Real-backend caveat you must not paper over in a round trip.** Real
IMAS-Core's HDF5 `deleteData` ignores its `path` argument completely and
deletes the whole IDS pulse file plus its master-file link. So on the only
backend that actually implements delete, a candidate-plan fan-out's first
candidate destroys the entire occurrence and every later candidate in the
same fan-out simply finds nothing left. **A test cannot observe *per-path*
deletion against real HDF5** — it can only observe that the occurrence is
gone. This is tracked as a known, accepted gap (issue #139; stated in
README.md's "Scope and limitations"), not something a passing test should
paper over by asserting per-candidate effects that the backend doesn't
actually provide. Test the fan-out call sequence (e.g., via the recording
stub, which does let you observe each candidate individually) separately
from the on-disk consequence (which real HDF5 collapses to one).

## 7. Cross-cutting: how the caller learns any of this

- **`al_status_t.code == 0` always means success, full stop** — including a
  lossy or partially-served read, and including the unwritten-candidate case
  on write. Never infer fidelity from `code`.
- **A shim-originated refusal returns `code == IMAS_MVDD_CONVERSION_ERROR`
  (`-1000`)**, distinct from any IMAS-Core code (upstream only uses `-1`
  through `-4`). The message is `"IMAS-MVDD: {reason}; DD path: {path}; HLI DD
  version: {v}; stored DD version: {v}"`, built by one formatter and
  truncated (versions dropped first, then the path cut **from the left** with
  a leading `...` so the leaf name — the identifying part — survives) to fit
  the ABI's fixed 256-byte message buffer. A refusal raised before any
  context exists (bad HLI version, malformed stamp) has no path or version
  pair and uses a shorter `"IMAS-MVDD: {reason}"` form instead. **Every
  `{reason}` the shipped shim can produce is listed verbatim in §8** — that
  is the only part of the message worth asserting on, since `code` alone is
  `-1000` for all of them and the rest of the message can be truncated away.
- **Loss/fidelity never travels through `al_status_t`.** It travels through a
  per-root-context log, drained via three shim-owned exports:
  `imas_mvdd_context_loss_count(ctx, *count)`,
  `imas_mvdd_context_loss_at(ctx, index, path_buf, buf_len, *verdict)` (verdict
  is one of `IMAS_MVDD_FIDELITY_POTENTIALLY_LOSSY` / `_LOSSY` / `_UNMAPPABLE`;
  exact-fidelity entries are never logged at all), and
  `imas_mvdd_context_loss_operation_at(ctx, index, *operation)` (`
  IMAS_MVDD_LOSS_OPERATION_READ`, `_WRITE`, or `_DELETE`). Querying **any** context under
  one IDS occurrence (a root or one of its arraystruct children) returns the
  **whole root's** log — there is no per-child scoping. An untracked
  context — including any occurrence with no registered root — reports a
  count of `0`, not a refusal.
- **A refused read, write or delete is logged too, at `Unmappable`**, in addition to
  being returned through `al_status_t`. This is deliberate redundancy, not a
  bug: it means `Unmappable` in the log conflates "this was refused" with
  "this candidate genuinely doesn't exist and came back not-found" — a test
  reading the log should not assume every `Unmappable` entry corresponds to a
  visible failure at the call site.
- **The in-memory log dies with its root context at `al_end_action`.** A
  patched HLI must drain it through the exports before closing, or lose that
  view of it — but the exports are no longer the *only* channel. ADR 0023
  deliberately reverses ADR 0012 decision 7 on this point: no shipped HLI is
  patched to call the exports, so a second, file-based channel now carries
  the same entries without requiring any HLI change at all (below). An
  unmodified HLI — one that never calls the exports and only ever sees
  refusals through `al_status_t` — still gets this second channel for free.
- **The loss log file** (ADR 0023) is process-local, append-only, and
  tab-separated: `uri`, `ids`, `stored-dd`, `hli-dd`, `operation`, `fidelity`,
  `path`, preceded by a `#`-comment preamble (format version, write
  timestamp, PID, HLI DD version). The shim creates it lazily, only on the
  first loss any seam produces, named
  `imas-mvdd-loss-<UTC-timestamp>-<pid>.txt` (a `-N` suffix disambiguates a
  same-second collision) in the current working directory by default. Set
  `IMAS_MVDD_LOSS_LOG_DIR` to an existing directory to redirect it, or to an
  empty value to disable the file entirely. Every non-exact read, write and
  delete loss reaches it — not delete alone, though §6 mentions it there too
  — carrying the same three fidelity verdicts and the same READ/WRITE/DELETE
  operation tags as the exports.
- **The file survives exactly the failure the in-memory log cannot.** If a
  root context ends while an operation is still in flight, its in-memory log
  is already gone and drops the entry — but the file's own process-wide
  written-key set has no context lifetime, so the entry is retained there
  regardless. That disagreement between the two channels is deliberate, not
  a bug to reconcile in a test. Conversely, the file is exact-once, not
  cumulative: the key is the complete rendered line, so the identical loss
  encountered twice within one process is written once, while two
  occurrences of the same IDS — or two separate processes — each still get
  their own line. A filesystem write failure is reported once to stderr and
  otherwise silently disables the file for the rest of the process; it never
  changes `al_status_t`, and it never touches the in-memory log.
- **The `uri` column is the caller-supplied URI verbatim, unredacted.** A
  site whose URIs can carry credentials should set `IMAS_MVDD_LOSS_LOG_DIR`
  to an empty value, or point it at an appropriately access-controlled
  directory, before running against real data.
- Write's loss entries name the **stored**-DD spelling of each unwritten
  candidate (where else a stale value might be found); read's (and any
  refusal's) entries name the **HLI**-DD spelling of the argument in
  question (what was actually asked for). Don't expect the same kind of path
  string in both cases.

## 8. Refusal reason strings: a frozen, named surface

Everything above tells you *whether* a call refuses. This section tells you
*what it says*, verbatim, so an HLI-side test can assert on the reason rather
than on `code == -1000` alone — which every refusal in the shim shares and
which therefore proves almost nothing about *which* rule fired.

**This list is the contract.** The strings below are the ones a test may
depend on. They are literals in `src/`, but treating them as an
implementation detail is exactly the failure mode this section exists to
prevent: a reworded string turns a precise assertion into a vacuous one
without failing a single test in this repository. Anyone changing one of
these strings must update this table in the same commit, and should treat the
change as breaking for downstream HLI suites. New reasons may be *added* as
new artifacts land; existing ones do not get reworded silently.

### 8.1 The envelope around every reason

Two shapes, one formatter (`src/lib.rs`, reached through
`src/interpose/refusal.rs`):

| Raised | Message |
|---|---|
| By a seam holding a live conversion record (every read, write, delete and arraystruct refusal) | `IMAS-MVDD: {reason}; DD path: {path}; HLI DD version: {hli}; stored DD version: {stored}` |
| Before any context exists (bad HLI DD version, malformed stamp, loss-export argument errors) | `IMAS-MVDD: {reason}` |

`{path}` is the DD path *in the caller's own spelling*, anchor-joined — not
the stored spelling. Where a seam has a record but no resolved path to name
(the two arraystruct arguments), it falls back to the context's own resolved
path, and to the literal `(no path argument)` when there is no path at either
place.

**Do not assert on the whole message.** It is truncated to fit
`MAX_ERR_MSG_LEN` (256) in a fixed order: the two versions are dropped first,
then the path is cut **from the left** and marked with a leading `...`. A
deep DD path plus a long reason can therefore legitimately produce a message
with no version pair in it. Assert `code == IMAS_MVDD_CONVERSION_ERROR` plus
a **substring** match on the reason; assert the full string only where you
control the path length. (This repository's own C suite asserts exact strings
via `CHECK_REFUSAL_MESSAGE` precisely because it controls both.)

`{...}` below marks runtime substitution; everything outside braces is
literal, including punctuation. Note the em-dash (`—`, U+2014) in the
version-conflict message.

### 8.2 Path-resolution reasons

Raised by the artifact's own rules, shared across seams. These are the ones a
conversion test most wants to name.

| Reason string | Raised by |
|---|---|
| `this path's container changed shape and cannot be served` | any seam, on the `retyped` rule — unconditional, even where the rule declares itself `exact` |
| `this path's unit was redefined and cannot be converted` | any seam, on a unit-redefinition rule |
| `this path has no safe conversion between DD versions` | any seam, on a declared-`unmappable` rule. **Unreachable from the shipped artifact** (ADR 0011) and asserted to be so — a test that hits it means a new artifact made it reachable |
| `this path is unclaimed by the conversion map` | write, delete |
| `this path has no stored source` | write, delete |
| `this path is a non-primary source and cannot write a shared stored slot` | write |
| `this path is a non-primary source and cannot delete a shared stored slot` | delete |
| `this candidate plan has no precedence-1 source for a write` | write, where a `merged`/`split` plan has no precedence-1 slot at all |
| `the DD-version stamp is immutable under a version mismatch` | write, on `ids_properties/version_put/data_dictionary` (§5) |
| `this delete would remove the DD-version stamp while stored data remains` | delete, on the stamp or any ancestor of it |
| `this timebase needs a value transformation, which al_write_data cannot apply` | write, `timebase` argument only |
| `this path needs a value transformation that cannot be inverted for a write` | write, `field` argument |
| `this subtree delete would leave data at a stored path outside the requested subtree` | delete, on an escaping-rule subtree (§6) |

### 8.3 Context-open and arraystruct reasons

Raised by `al_begin_arraystruct_action` / its plugin twin, and by the shared
anchor resolution beneath every relative path argument.

| Reason string | Raised when |
|---|---|
| `this path needs a value transformation, which only a data read can apply` | a context open resolves to a rule carrying a value transformation — an open has no buffer to transform |
| `this path is served by several stored candidates, and only a data read can try them in turn` | a context open resolves to a `merged`/`split` candidate plan |
| `arraystruct path has no stored source` | the AOS `path` argument resolves to nothing on the stored side |
| `arraystruct timebase has no stored source` | same, for `timebase` |
| `arraystruct path is unclaimed by the conversion map` | the AOS `path` argument is claimed by no rule |
| `arraystruct timebase is unclaimed by the conversion map` | same, for `timebase` |
| `translated path does not lie beneath this context's stored anchor` | a relative argument translated to a path outside its own context |
| `translated field contains an interior NUL byte` | the translated spelling cannot be formed as a C string |
| `context anchor has no stored-DD conversion rule` | the enclosing context's own anchor is unclaimed |
| `context anchor has no stored source` | the enclosing context's anchor has nothing on the stored side |

The two `arraystruct ...` families are built from a `{label}` substitution
over `path` and `timebase`; those four are the only spellings the shipped
seams produce.

### 8.4 Value-transform execution reasons

Raised when a buffer's declared shape cannot carry the transformation the
rule asks for. Read and write share the first three; the last two are
write-only.

| Reason string | Raised when |
|---|---|
| `value-transform execution requires DOUBLE_DATA and a rank no greater than MAXDIM` | the datatype is not `DOUBLE_DATA`, or `dim` is outside `0..=7` |
| `value-transform execution needs array dimensions` | `dim > 0` with a null `size` |
| `value-transform execution received an invalid array shape` | a negative extent, or extents whose product overflows |
| `value-transform execution needs a data buffer` | write: a non-scalar write with a null `data` |
| `this value transformation was not inverted for the write direction` | write: a defensive assertion that a read-direction transformation never reaches the write path. Not reachable through the shipped resolver; a test hitting it has found a real bug |

### 8.5 Version-latch and stamp reasons (pre-context, short envelope)

| Reason string | Raised by |
|---|---|
| `HLI DD version must not be null` | `imas_mvdd_set_hli_dd_version(NULL)` |
| `HLI DD version must be valid UTF-8` | a non-UTF-8 version string |
| `conflicting HLI DD version: this process already latched to '{existing}' and cannot also serve '{parsed}' — one process cannot host two HLIs built against different DD versions` | a second setter call with a different version (§2.1) |
| `cannot set HLI DD version to '{parsed}': this process already latched to unset, after an earlier open found no setter call and no valid IMAS_MVDD_HLI_DD_VERSION` | a setter call after an open already latched the process to "no conversion" |
| `cannot set HLI DD version to '{parsed}': this process already latched to an invalid IMAS_MVDD_HLI_DD_VERSION value at an earlier open ({reason})` | a setter call after an open latched an invalid environment value; `{reason}` is one of §8.6 |
| `malformed DD-version stamp at 'ids_properties/version_put/data_dictionary'` | the occurrence-open refusal of §3's last row |

### 8.6 DD version grammar reasons

Produced by version parsing (ADR 0009) and delivered through the short
envelope, either from `imas_mvdd_set_hli_dd_version` or nested inside the
last message of §8.5. `{input}`/`{raw}`/`{whole}` is the offending string.

| Reason string |
|---|
| `DD version '{input}' must not contain whitespace` |
| `'{input}' is not a known DD release` |
| `'{input}' is not MAJOR.MINOR.PATCH` |
| `'{input}' has extra '.'-separated components` |
| `'{whole}' has a non-canonical version component '{component}'` |
| `'{whole}' has an out-of-range version component '{component}'` |
| `'{raw}' has an unknown base release '{base}'` |
| `'{raw}' is missing the '-N-gHASH' development suffix` |
| `'{raw}' has a non-canonical development commit distance` |
| `'{raw}' has a zero commit distance, which is not a development build` |
| `'{raw}' is missing the 'g' hash prefix` |
| `'{raw}' hash must be 7 to 64 characters, got {n}` |
| `'{raw}' hash must be lowercase hexadecimal` |

### 8.7 Loss-export argument reasons

Argument errors from the three `imas_mvdd_context_loss_*` exports (§7). These
are programming errors in the caller, not conversion outcomes — an untracked
context is *not* one of them (it reports a count of `0`).

| Reason string |
|---|
| `imas_mvdd_context_loss_count requires a non-null count output` |
| `imas_mvdd_context_loss_at requires a non-null verdict output` |
| `imas_mvdd_context_loss_at requires a non-null path buffer` |
| `imas_mvdd_context_loss_at index must not be negative` |
| `imas_mvdd_context_loss_at buffer length must not be negative` |
| `imas_mvdd_context_loss_at index is out of range for this context` |
| `imas_mvdd_context_loss_at buffer is too small for this path` |
| `imas_mvdd_context_loss_operation_at requires a non-null operation output` |
| `imas_mvdd_context_loss_operation_at index must not be negative` |
| `imas_mvdd_context_loss_operation_at index is out of range for this context` |

### 8.8 One status the shim emits that is *not* a refusal

If IMAS-Core itself cannot be resolved at runtime — `libal` not found, or an
ABI major-version mismatch — every mirrored seam returns `code == -1` (not
`-1000`) with a message shaped `override with $IMAS_CORE_LIBRARY if this is
wrong; {detail}`, where `{detail}` is the platform's own `dlerror()` text or
the version comparison. It carries **no** `IMAS-MVDD:` prefix and predates
the reserved `-1000..=-1099` block. A test that sees `-1` has a broken
environment, not a conversion outcome; don't fold it into refusal handling.

## 9. What a round trip can prove, and what it structurally cannot

A write-then-read round trip through the shim is a **consistency check**, not
a correctness proof, for exactly one class of case: any value transformation
(today, COCOS sign flips). Write flips HLI→stored and read flips
stored→HLI, so **the caller's own value comes back whether or not the shim's
sign convention is actually right, and whether or not the value on disk is
even in the stored convention at all**. A round trip that only asserts "I
read back what I wrote" gives zero evidence about:

- whether the value was actually stored under the *stored* DD path (as
  opposed to the caller's own path, forwarded by accident),
- whether the sign on disk matches the *stored* COCOS convention rather than
  the HLI's,
- whether the DD-version stamp still reads the *stored* version after a
  `put_slice` (nothing round-trippable touches this),
- whether a precedence-2 candidate was correctly left alone rather than also
  written.

Proving any of those requires reading the on-disk file **natively** (outside
the shim) and checking the stored path, the raw sign, and the stamp directly
— what this project calls its "native/on-disk oracle" (see
`tests/real_core/write_delete_oracle_test.c`). Keep native-oracle assertions
and shim-round-trip assertions in separate tests, and don't delete the native
ones as "redundant" with a passing round trip — they are proving different
things.

Other things a round trip (or any black-box HLI test) cannot observe, listed
so you don't chase a false negative:

- **Per-candidate delete effects against real HDF5** (§6) — the backend
  collapses a fan-out to one whole-occurrence deletion regardless of how many
  candidates the shim submits.
- **A clean failure from a refused `put_slice`** against an unmodified HLI
  (§5) — expect a torn slice, not an atomic rollback.
- **Any conversion effect on an occurrence whose (IDS, stored, HLI) triple has
  no embedded artifact** — a genuine version mismatch with no artifact is
  byte-for-byte indistinguishable from no mismatch at all, at every seam.
- **`datapath` translation on a fresh occurrence's first open** (§2.4) — it
  only ever fires from the second open onward.
- **Anything about `timebase` conversion beyond identity** — in the shipped
  artifact `time` is untouched by any rule, so `timebase` resolution is
  exercised only at `Fidelity::Exact`, identity-forward, in every scenario
  above. The write path explicitly documents this as unproven territory for a
  future artifact, not a guarantee that a non-identity `timebase` write is
  safe.
- **Merged-rule loss beyond what's logged.** The shim never performs an
  auxiliary read to check whether a `merged` field's untried candidates
  *actually* held different data — `PotentiallyLossy` is a statement about
  ambiguity in the rule, never a verified fact about the specific occurrence.

## 10. A minimal scenario checklist

For each operation (read, write, delete), a reasonably complete integration
suite exercises, at minimum:

1. HLI version unset → pure passthrough, no seam does version discovery at all.
2. Occurrence stamp absent → forwards, presumed match, nothing logged.
3. Occurrence stamp present and equal to HLI version → forwards, nothing logged.
4. Occurrence stamp present, differs from HLI version, **no artifact for that
   pair** → forwards unconverted, nothing logged (must not be conflated with
   case 3, even though the observable behavior is identical).
5. Occurrence stamp present, differs, **artifact present** (equilibrium
   3.39.0⇄4.1.1) → per §4/§5/§6 above, per rule kind actually exercised
   (`identical`, `renamed`, `moved`, `merged`, `split`, `retyped`,
   `left_only`, `right_only`).
6. Occurrence stamp present but malformed → the **open** call refuses; no
   data seam is ever reached.
7. For write specifically: a non-primary-source write, a no-stored-slot
   write, a `merged`-rule write with an unwritten candidate (check the loss
   log's stored-path entry), an unset-sentinel scalar write (check *no* loss
   entry and unchanged forwarding), and a stamp-write attempt (must refuse).
8. For delete specifically: a single-candidate delete, a multi-candidate
   delete with an injected mid-fan-out failure (check every candidate was
   still attempted), a trivial subtree delete, an escaping-rule subtree
   delete (must refuse), and the empty-path whole-DATAOBJECT delete.
9. Loss-log lifecycle: query counts/entries before `al_end_action`, confirm
   the log is unreachable (reports `0`) once queried through a context ID
   that no longer exists.
10. Loss log file: trigger a non-exact operation, confirm a
    `imas-mvdd-loss-*.txt` file appears under `IMAS_MVDD_LOSS_LOG_DIR` (or the
    working directory) with a matching line, and confirm an empty
    `IMAS_MVDD_LOSS_LOG_DIR` suppresses it.
