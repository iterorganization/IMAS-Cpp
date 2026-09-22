# How an HLI proves the shim contract from an end user's seat

Audience: someone adding a multiversion-shim conformance suite to an HLI that
does not have one yet (IMAS-Cpp, IMAS-MATLAB, IMAS-Java). Read
`docs/SHIM_INTEGRATION_CONTRACT.md` first — it is the agreement. This document
is not a second agreement. It is the **convention** for turning that agreement
into a suite: which scenarios to write, what each one is allowed to conclude,
which channel it must conclude it from, and how the harness must be built so
that a green run means something.

IMAS-Fortran already did this interpretation once. Its suite lives in
`tests/shim/` and registers **30 CTest tests — 18 assertions and 12
setup/fixture tests**. Everything below is that suite's reasoning, restated
language-neutrally, with the parts that were accidents of Fortran separated
from the parts that are the convention. Where this document and the contract
disagree, the contract wins.

Normative words: **MUST**, **SHOULD**, **MAY**.

---

## 1. Six decisions that define the suite's shape

These are scope decisions, not test details. An HLI that changes one of them is
building a different suite, and its results are not comparable with another
HLI's. IMAS-Fortran records them in `docs/adr/0002-shim-integration-test-suite.md`.

### D1 — Tier 1 only: the HLI's public API, never the shim's C ABI

Every test **MUST** drive the shim through the calls an ordinary user of the
HLI writes — `get`, `put`, `put_slice`, `delete`, and the data-entry open/close
around them. No test **MAY** bind an `imas_mvdd_*` symbol, and no `imas_mvdd_*`
binding **MAY** be added to the HLI's own wrapper layer to make a test possible.

Why this is a decision and not laziness: the shim repository owns seam-level
tests, and it can inject failures at the C ABI that an HLI call cannot reach
(a mid-fan-out delete failure, a null buffer, a bad index into the loss
exports). Duplicating those here buys nothing and couples the HLI's suite to a
surface its users never touch. What only this suite can prove is that the
contract survives the HLI's own generated traversal — its ordering, its
error handling, its type mapping. That is the whole of its job.

The consequence to accept up front: **the per-context loss exports
(`imas_mvdd_context_loss_*`) are unreachable from Tier 1.** The HLI's `get`
owns the root action context and ends it before returning, so there is no live
context left to query. Loss is therefore observed through the shim's
process-local **loss-log file** (§3.4), never through the exports. Contract §7
lists both; a Tier-1 suite uses only the file.

### D2 — One direction per suite build

IMAS-Fortran's suite is a **DD 4.1.1 HLI reading and writing a DD 3.39.0
pulse**, in that direction only, because the repository has one build of the
library and it is built against one DD.

An HLI **MUST** state its direction in its own README, and **MUST NOT** claim
coverage of rules that direction cannot reach. In the shipped equilibrium
artifact the unreachable set is the **23 `left_only` rules** — paths DD 3 had
and DD 4 dropped. They become reachable only when the same library is built
against both dictionaries and two binaries exist. If your HLI can build both
cheaply (a dynamically-typed or reflection-based HLI often can), covering both
directions is a genuine improvement over the Fortran suite — say so, and add
the `left_only` rules as a fourth rule table.

### D3 — The unit of assertion is a conversion *rule*, not a leaf

A test **MUST** be organised around the rules in the conversion map, and a
failure **MUST** name the rule — its id, its kind, and the citation that says
where the rule comes from — not merely the field that mismatched. "Rule
`fold-axis-bphi` (merged) at `time_slice/global_quantities/magnetic_axis/b_field_phi`
verdict=only-oracle expected=same" is actionable. "b_field_phi differed" is not.

A rule governing a subtree **MAY** be asserted on a sample of its leaves. A
`right_only` rule is served or it is not, and a handful of leaves say which.
IMAS-Fortran samples 4 of `new-contour-tree`'s 10 paths and 3 of
`new-constraints-j-parallel`'s 13. This is the intended consequence of
organising by rule — and it is a real hole: a shim serving *part* of a subtree
escapes detection. State that in your README rather than pretending otherwise.

### D4 — The oracle is a second fixture, never a transcribed literal

Expected values **MUST NOT** be written into test source as numbers. The suite
reads **two pulses of the same equilibrium**, one per DD version, and compares
them:

- the **converted** reading: the older-DD pulse opened by the newer-DD HLI, so
  the shim converts;
- the **oracle** reading: the newer-DD pulse opened same-version, so nothing
  converts and the HLI passes through.

The oracle pulse is the hand-authored expected result of converting the other,
generated from one shared table of physical values by two small modules that
decide only *where* each value goes (`imas-python-fixtures/`). That is what
makes "the two fixtures agree" a property of the generator rather than a
promise, and it is why a comparison needs no literals.

A literal in a test asserts what somebody typed. A fixture-pair comparison
asserts what the map says the conversion is.

Exception, narrowly: a **write** test **MUST** use a curated value it chose
itself (IMAS-Fortran writes `ip = -7654321.0`), because there is nothing on
disk yet to compare against. Such a value **SHOULD** be distinctive enough that
finding it in a dump is unambiguous.

### D5 — A contract assertion stays red while the shim disagrees

Two labels, and every test **MUST** carry exactly one:

- **`contract-assertion`** — states what `SHIM_INTEGRATION_CONTRACT.md`
  requires. When the shim disagrees, this test is **red**, and it stays red.
  It **MUST NOT** be inverted (an "expected failure" marker), moved out of the
  default run, quarantined, or softened to match observed behaviour. All three
  make a green run prove less, and all three require a human to remember to
  come back and flip it. Written as the contract states it, the test turns
  green by itself the day the shim is fixed, with nobody touching the suite.
- **`behaviour-pin`** — preserves an *accepted limitation* whose shape must not
  drift silently. It is expected to pass. It is not a statement that the
  behaviour is desirable. IMAS-Fortran has exactly one (the torn write, §5.6.3).

The suite's README **MUST** carry a **red list**: every `contract-assertion`
currently failing, with a reviewed cause and an owner. Three rules about it,
each learned the hard way in IMAS-Fortran:

1. **Observed, not inferred.** The red list is what a run printed, with the
   date and the machine. Do not reconstruct it from tickets or commit messages;
   reds that emerge from a combination appear in no ticket at all.
2. **Record which IMAS-Core was loaded.** One IMAS-Fortran test is red against
   upstream IMAS-Core 5.7.2 and green against a core that honours the `path`
   argument to `al_delete_data`, for a reason living in neither this repository
   nor the shim. A count without the core named describes a different system
   than the reader's.
3. **Keep the corrected entries, do not delete them.** A red list is also a
   record of what was *believed*. Two of IMAS-Fortran's entries had the owner
   wrong and one had the failing seam wrong; the write-ups of why are the most
   useful part of that file.

An empty red list is a weaker statement than it looks. It says nothing was red
in one run — not that the suite was sensitive enough to notice. Hence D6.

### D6 — Nothing may pass by not running

Most of these tests pass by *not printing*, so a build that converted nothing
passes exactly like a build that converted everything. Every program **MUST**
therefore carry a **run guard**: it counts the assertions it actually executed
and compares that count against a number stated up front in the source. A check
lost in an edit fails the run instead of quietly shrinking it.

Three guards, all of which IMAS-Fortran arrived at after being bitten:

- **Per-program expectation count.** A named constant beside the assertions,
  raised deliberately when one is added.
- **Every rule in the table was checked.** Expected count is the table's own
  size, so a program cannot state it wrongly.
- **A vacuity demonstration.** At least one test **SHOULD** prove that its
  `same` expectations are not trivially satisfiable — i.e. that a reading the
  shim served nothing for genuinely *fails* an agreement expectation. Without
  it, a shim that served nothing at all would satisfy every structural rule,
  because two empty readings are equal. (IMAS-Fortran caught this: comparing
  two zero-length arrays returned `same`.)

---

## 2. What "from an end user's seat" rules in and out

The user of an HLI can see five things. Only four are Tier 1.

| # | Channel | What it is | Tier 1? |
|---|---|---|---|
| C1 | **Value** | The field in the returned IDS object: served, or absent | Yes — always available |
| C2 | **Status** | The code the HLI call returns / the exception it raises | Yes — always available |
| C3 | **Refused-path record** | The HLI's own record of paths a traversal skipped or refused to write | Yes, **if the HLI has one** (§2.3) |
| C4 | **Loss-log file** | The shim's process-local `imas-mvdd-loss-*.txt` | Yes — needs no HLI support |
| C5 | **Native on-disk oracle** | Reading the pulse file outside the HLI and outside the shim | **No** — out of scope here |

C5 is excluded deliberately, not forgotten. Contract §9 is explicit that a
round trip through the shim cannot prove the value was stored at the *stored*
DD path, or in the *stored* sign convention — write flips one way and read
flips back, so the caller's value returns whether or not the shim is right.
Proving that needs a native reader, which is a different kind of test with
different tooling. Keep it in a separate suite. Do **not** delete native
assertions as "redundant" with a passing round trip: they prove different things.

### 2.1 C1 — the value channel

An absent field **MUST** be distinguishable from a served one *without
ambiguity*. This is the single most important capability question for a new
HLI, and the answer differs sharply by language:

- A field the shim served nothing for **MUST** read back as the HLI's own
  "absent" representation — an unassociated pointer, a null, an empty
  collection, the DD invalid sentinel — and **MUST NOT** read back as a
  plausible number.
- If your HLI can return **uninitialised memory** for a field that was never
  served, say so in the README and treat it as a finding. IMAS-Fortran found
  exactly this: five `right_only` paths came back as `6.0135E-154`,
  `-932149305`, and `538976288` (`0x20202020` — four ASCII spaces, a
  blank-padded string buffer landing on an integer field). A caller testing
  `!= invalid` concludes the field was served. That is worse than a wrong
  value, and the suite's job is to catch it, not to work around it.

### 2.2 C2 — the status channel

Three distinct outcomes **MUST** be distinguishable by the end user:

| Outcome | Contract | What the HLI should surface |
|---|---|---|
| Success | `code == 0` | Normal return. **Never** infer fidelity from this — a lossy read returns 0 |
| Shim refusal | `code == -1000` (band `-1000..-1099`) | A refusal, distinct from any IMAS-Core code (`-1..-4`) |
| Core not resolvable | `code == -1`, message has **no** `IMAS-MVDD:` prefix | A broken environment, **not** a conversion outcome. Do not fold it into refusal handling |

A test **MUST** assert the refusal *band*, never a bare non-zero. And when it
asserts a refusal **reason**, it **MUST** use a **substring** match against the
frozen strings in contract §8 — the message is truncated to 256 bytes, versions
dropped first, then the path cut from the left with a leading `...`. Assert the
whole message only where the test controls the path length, and say so.

### 2.3 C3 — the refused-path record, and what to do without one

This is the channel that does not come for free, and the one where HLIs will
differ most.

The contract says a refused read leaves one path unserved; it says nothing
about whether the HLI's traversal then **aborts** or **continues**. That is the
HLI's own design decision, and it decides how much of this convention you can
implement. IMAS-Fortran chose to continue: a refusal is not a failure of the
read, because the path does not exist in the caller's dictionary and no retry
makes it appear, so aborting costs every other field in the IDS for nothing.
It added, in its own wrapper (no shim symbols):

- a **read-side skip log** — a fixed 64-slot record of `(path, status code,
  message)` for each path a `get` traversal left unset, reset at the start of
  each `get`, reporting a true total even past capacity;
- a **partial-read status** — a distinct, *positive* code (`PARTIAL_READ = 1`),
  positive so it cannot collide with a C-ABI status while still tripping the
  `status != 0` test callers already write;
- the write counterparts — **refused-write and refused-delete counters**, a
  printed `REFUSED WRITE: '<path>'` / `REFUSED WRITE (subtree): '<path>'` /
  `REFUSED DELETE: '<path>'` diagnostic, and a **partial-put status**
  (`PARTIAL_PUT = 2`), distinct from partial-read so a caller doing both knows
  which half was incomplete.

**Two profiles, and you MUST declare which one you are in.**

- **Profile A — tolerating HLI.** Your HLI continues past a refused path and
  can name it. Implement the whole catalogue in §5.
- **Profile B — aborting HLI.** Your HLI's `get` fails on the first refusal and
  cannot name it. You can still implement most of the catalogue, but the
  following change: every test whose set-up reads a *complete* cross-version
  pulse (§5.4, §5.5) has no complete read to work with, because the shipped
  fixture contains paths the shim refuses. Such a suite **MUST** either
  (a) narrow its reads to subtrees that contain no refused path, asserting
  fewer rules per read and saying so, or (b) add tolerance to the HLI first.
  It **MUST NOT** silently reinterpret "the read failed" as "the rule was
  correctly not served" — those are different facts.

If you are in Profile B and choose (b), note what IMAS-Fortran's read policy
gets right and copy it: tolerance is applied **per field**, at exactly two
sites (the per-field error check, and the failure arm of an array-of-structures
open). It is **not** applied at the occurrence open or the data-entry seams,
because the same refusal code arrives there for a malformed stamp or a
version-latch conflict, and tolerating one of those sails past an IDS that was
never opened. The predicate "is this status eligible to be tolerated" and the
predicate "is this *site* one where tolerating is sound" are deliberately
separate; only the first is a runtime test.

### 2.4 C4 — the loss-log file

This channel needs nothing from the HLI, so **every** HLI can use it, and in
Profile B it may be the only refusal evidence available.

A process that records a non-exact outcome writes exactly one file named
`imas-mvdd-loss-<UTC>-<pid>.txt` into `$IMAS_MVDD_LOSS_LOG_DIR` (the directory
must already exist; unset means the current working directory). Format:

```text
# imas-mvdd loss log format 1
# written <UTC>
# process <pid>
# hli-dd-version <version>
uri<TAB>ids<TAB>stored-dd<TAB>hli-dd<TAB>operation<TAB>fidelity<TAB>path
```

then one tab-separated seven-column row per entry.

Rules a consumer **MUST** follow:

- Pin the **format marker** (line 1) before reading anything else. Without it,
  a format change looks like a run with no losses.
- Skip the header **by position** (line 5), never by filtering comment-prefixed
  lines — line 5 is data-shaped, not a comment, and a comment filter feeds it
  to the row parser.
- Assert the **column count** per row (7). A row with a different count is a
  format break, not a parse nuisance.
- Read only `operation`, `fidelity`, `path` for assertions. The other four vary
  by run.

And two facts that change what you may conclude:

- **`UNMAPPABLE` is ambiguous by design.** A refused read or write is logged at
  `Unmappable` *in addition* to being returned through the status. So
  `UNMAPPABLE` conflates "this was refused" with "this candidate genuinely
  came back not-found". A log-reading test **MUST NOT** assume every
  `UNMAPPABLE` row corresponds to a visible failure at the call site.
- **The two channels are complementary, not duplicates.** C3 records refusals
  the traversal tolerated. C4 records every non-exact outcome, including lossy
  *successful* calls. Write each assertion against the channel the contract
  promises for that scenario; do not expect the two to hold the same paths.
- **Absence of a file means no loss.** That is what makes the passthrough
  scenarios (§5.2) assertable at all.

---

## 3. Fixtures

### 3.1 The oracle pair

Two complete pulses of one equilibrium, one per DD version, generated from a
single shared value table (`imas-python-fixtures/`, driven by imas-python).
Every leaf filled in both, so a `right_only` verdict proves the oracle holds a
real value that the shim did not invent — never a placeholder.

An HLI **SHOULD** reuse the existing fixture pair rather than generate its own.
Two HLIs asserting against two different pulses are not comparable, and the
generator already encodes the conversion by hand in a diffable form.

### 3.2 Provenance is a test, not a habit

The checked-in pulses **MUST** be verifiable as what their generator produces,
registered as a test in the suite. Otherwise every assertion is against numbers
nobody can re-derive. Compare **dataset by dataset** (`h5diff`), not bytewise —
HDF5 metadata is not byte-stable and a bytewise check reports drift where the
data is identical.

Register it conditionally on its tooling being present, and make a missing
toolchain **skip the check, never silently pass it**.

### 3.3 Fixtures are immutable; scenario variants are derived

- A **read** test **MUST** run against the checked-in fixture directly, and the
  harness **SHOULD** verify the fixture is unchanged afterwards — content
  digest, not mtime, for the reason in §3.2. If a converting read ever wrote
  back to the pulse it read, nothing else in the suite would notice and every
  later comparison would be against a pulse the suite itself modified.
- A **write** test **MUST** run against a private copy made fresh before each
  run, so scenarios can run in parallel and a failed run leaves no poison.
- **Stamp-state variants MUST be derived at build time, not committed.** Three
  are needed (§5.2, §5.3): stamp **absent** (delete the scalar dataset), stamp
  **malformed** (set it to something that fails the grammar, e.g.
  `not-a-dd-version`), stamp **mismatched with no artifact** (set it to a
  grammar-valid, *known* DD release that is neither the HLI's version nor the
  one the artifact covers — IMAS-Fortran uses `3.40.0`). A ~40-line script
  copying the pulse and editing one dataset is enough; committing three more
  HDF5 pulses is not.

### 3.4 Process isolation

The HLI DD version is latched **once per process** — a second, different value
is refused, not applied. Therefore:

- **Each version scenario MUST be its own process.** No in-test mechanism can
  substitute, and none is needed: a test runner already gives each test a
  process. This is why the passthrough scenarios are three separate programs
  rather than three branches of one.
- **Each test MUST get its own empty loss-log directory**, cleaned before the
  run — including tests that assert nothing about it. Leaving
  `IMAS_MVDD_LOSS_LOG_DIR` unset is *not* neutral: the shim then writes into
  the working directory, where the file waits for whichever test globs there
  next. Clean before the run, not at configure time: configure runs once, the
  suite runs many times.

---

## 4. The comparison oracle and its vocabulary

Every value comparison **MUST** go through one shared comparator with a
**closed set of verdicts**. Not because comparison is hard, but because the
verdict is what a failure message says and what a README transcribes, and a
typo'd or mis-oriented verdict corrupts both without failing anything.

### 4.1 The verdict set

| Verdict | Meaning |
|---|---|
| `ABSENT` | Neither side has a value |
| `ONLY_ORACLE` | The same-version oracle has a value; the shim served nothing |
| `ONLY_CONVERTED` | The shim served a value; the oracle has none |
| `SAME` | Both present and equal within tolerance |
| `NOFLIP` | Both present, equal after negating one — a required COCOS sign flip did not happen |
| `DIFF` | Both present, neither equal nor sign-flipped |
| `SHAPE` | Both present, different element counts |

The set **MUST** be closed and named — an enum, constants, whatever the
language offers — so a misspelling is a compile/load error rather than a value
that falls through to a default. IMAS-Fortran's comparator raises on an unknown
verdict for exactly this reason.

`NOFLIP` **MUST** have mismatch severity, not warning severity. A missing
required sign flip is a failed contract assertion.

### 4.2 Presence before value, always

Every comparison **MUST** run the presence cascade first — both absent →
`ABSENT`; one absent → `ONLY_*`; only then judge values — and that cascade
**MUST** be written once and shared.

**Presence MUST be derived from the reading, not asserted by the caller.**
IMAS-Fortran's comparator originally let a call site pass "both present" where
a value was merely *expected* to be there. That is an assumption, not an
assertion, and it disables the absence arm: two zero-length arrays have equal
size, the element loop runs zero times, and the verdict is `SAME`. A rule
neither side served would pass as agreement. A caller-stated-presence variant
**MAY** exist for callers that established presence some other way (from the
refused-path record, say), but it **MUST** be named long enough that a call site
claiming a presence it has not checked reads wrong.

### 4.3 Name the sides; never order them

`ONLY_ORACLE` and `ONLY_CONVERTED` say *which side* was absent, so the verdict
is only as trustworthy as the caller's account of which reading it handed over.
IMAS-Fortran documented that account in a comment. It did not survive: two of
its three rule programs passed the shim-served reading as the oracle for every
rule they check. Both labels differ from `SAME`, so **every pass and fail in the
suite was identical either way** and no assertion could be written that failed
on the inversion — it was detectable only by reading two programs against a
comment, and meanwhile the inverted labels were transcribed into the suite
README as the account of what the shim did.

So the convention is:

- Every comparison function's two value arguments **MUST** be named — `oracle`
  and `converted` — and **MUST** be callable only by name. Use whatever the
  language offers to make a positional call impossible: keyword-only parameters,
  a single options object/struct, named-argument enforcement. (IMAS-Fortran gave
  every public comparator a leading optional dummy of a private type nobody can
  construct, which makes a positional call a compile error and leaves keyword
  form as the only way in.)
- Internal helpers in the test programs **MUST** take the same two names and be
  called by keyword too, or they reopen the hole where the compiler cannot see.
- The half no compiler can check — a call that spells both keywords and feeds
  them the wrong readings — **MUST** be covered by a **source check registered
  as a test**: with the keyword adjacent to its value, "an `oracle=` argument
  is fed a cross-version reading" is a grep-able pattern, whereas the
  positional swap it replaced was not expressible as one. That check **MUST**
  count how many named sides it found and fail if the count falls below a floor,
  so it cannot pass by matching nothing — the failure mode of every grep-shaped
  test.

**A deliberate deviation from IMAS-Fortran, recommended for new suites.** Its
verdicts are spelled `only3` / `only4`, after the DD versions. Role names
(`ONLY_ORACLE` / `ONLY_CONVERTED`) are safer: they stay correct when the suite
gains the other direction, and they make the orientation bug above harder to
write. If you keep dictionary-version names, the mapping is
`only4 ≡ ONLY_ORACLE`, `only3 ≡ ONLY_CONVERTED` for a DD4-HLI-reads-DD3 suite.

### 4.4 The comparator gets its own unit test

The comparator is the suite's oracle, and a pulse can never prove its own
comparator right. It **MUST** have a synthetic truth table driven from
literals — every verdict, both orientations, the empty-vs-empty trap of §4.2,
and the shape/flatten behaviour — with each case's expected verdict stated
independently. It **MUST** be self-contained: no rule table, no fixture, no
pulse. IMAS-Fortran's carries 34 cases.

### 4.5 The rule table

The suite carries a **hand-authored** table of the rules it asserts, and each
entry **MUST** cite its source — a rule id in the conversion map, or a section
of the fixture generator's README — so an entry can be checked without reading
the shim's implementation.

Hand-authored, not generated, for a specific reason: the externally reachable
copy of the conversion map has **unresolved `<include>`s**, and one of them
carries the common cross-IDS renames. A generator walking only what resolves
produces a table that looks complete while missing an entire rename family. A
hand-authored table fails to compile instead of failing to notice.

Each entry: `id`, `kind`, the HLI-side path, and the citation. Kind decides the
expected verdict, stated **once**, in one table, so adding a kind cannot update
the name mapping and leave the verdict mapping stale:

| Rule kind | Expected verdict | Note |
|---|---|---|
| `identical`, `renamed`, `moved`, `merged`, `split` | `SAME` | structural |
| `cocos` | `SAME` | a correct flip leaves the two HLI-side values equal |
| `right_only` | `ONLY_ORACLE` | DD4 introduced it; there is nothing to build it from |
| `retyped` | `ONLY_ORACLE` | refusal is correct — no transformation reshapes an int array into an identifier struct array |
| `redefined` | `SAME` | **contract assertion**: both dictionaries hold the same number, so it must be delivered |

A test **MUST** look the expectation up through this mapping rather than
writing `SAME` at the call site. IMAS-Fortran had one program folding leaf
verdicts against a literal while its own checker derived the expectation from
the rule kind — correct only for as long as every kind involved expected
agreement.

**Where a count in the map and a count in a ticket disagree, the map wins.**
Two tickets say the COCOS block holds 32 paths; it holds 30, on every commit
that ever touched it. Padding the table to 32 would assert agreement on a path
no fixture and no map actually flips — reporting a coverage the suite does not
have, which is worse than either number being wrong alone.

---

## 5. The scenario catalogue

Eighteen assertions in six families. Each entry gives: **id**, **label**, what
it sets up, what it asserts and on which channel, and why it exists. An HLI
implementing this convention **SHOULD** implement all eighteen and **MUST**
state which it omitted and why.

Naming: `<hli>-test-shim-<scenario>`. Labels: every test carries `shim`, plus
exactly one of `contract-assertion` / `behaviour-pin` / `harness`, so a
reviewer can run `--label contract-assertion` and see only statements about the
agreement.

### 5.1 Family 1 — harness integrity (4 tests, `harness`)

These assert nothing about the shim. They assert that the rest of the suite is
capable of asserting anything.

**F1.1 `linkage`.** Inspect the built HLI library's dynamic dependencies
(`otool -L`, `objdump -p`) and require the shim's library name to appear.

Why: functional tests pass against a build that never loaded the shim. A build
that resolved the shim's symbols from a static archive, or whose link line was
bypassed by a compiler-specific branch in the build files, shows nothing here
and everything everywhere else. IMAS-Fortran has exactly such a branch — a NAG
workaround that hardcodes the core library name and silently defeats shim
mode with no error at build or run time. **A dependency listing is the only
honest check; a build directory's name is not evidence.**

**F1.2 `comparison`.** The comparator's synthetic truth table (§4.4).

**F1.3 `verdict-orientation`.** The source check of §4.3.

**F1.4 `fixture-provenance`.** Regenerate the fixture pair outside the checkout
and compare every dataset (§3.2). Registers only when its tooling is present;
a missing toolchain skips, never passes.

### 5.2 Family 2 — the three ways nothing is supposed to happen (4 tests, `contract-assertion`)

Contract §3's first three occurrence-open rows, plus the version-unset row.
Each is a separate process (§3.4). Each **MUST** assert an **empty loss-log
directory** — that is what turns "no file means no loss" from a convention into
something enforced, and it is the only assertion available for F2.4 at all.

**F2.1 `version-unset`.** No HLI DD version set by env or setter. Open the
**older-DD** pulse, read it.

Asserts: open forwards; read returns clean success; no refused path recorded;
data arrived (time base present, expected length); **and a field whose name
exists only in the newer DD stays absent.** That last assertion is the point.
Reading the older pulse — whose stamp names a version the artifact *would*
convert if discovery ran — makes "nothing was looked up" provable, rather than
"nothing happened to differ". IMAS-Fortran checks `beta_tor_norm` (DD4's name
for DD3's `beta_normal`) is still at its invalid default.

**F2.2 `stamp-equal`.** HLI version set; open the **same-version** pulse.

Asserts: open forwards, read clean, nothing refused, data arrived, no loss file.

**F2.3 `stamp-absent`.** HLI version set; open a derived pulse with the stamp
dataset **deleted**.

Asserts: the same as F2.2. The contract presumes an unstamped occurrence
matches the HLI, so this **MUST** be plain forwarding — and specifically
**MUST NOT** be the malformed-stamp refusal. Absence means "no stamp field"; a
present-but-invalid value is unsafe metadata. Do not conflate them in a fixture.

**F2.4 `stamp-mismatch-no-artifact`.** HLI version set; open a derived pulse
stamped with a grammar-valid known release the artifact has no rule for.

Asserts: the same as F2.2, plus the renamed-field-stays-absent check of F2.1.

**This test is, by contract, indistinguishable from F2.2 by anything it can
observe.** Contract §2.2 and §9 say so outright: a version mismatch with no
artifact forwards byte-for-byte like no mismatch at all. It exists because
"a mismatch here still forwards unconverted" is a scenario worth writing down
as its own row, not because it proves a difference. Say that in the test's own
header, or someone will later "simplify" it away or try to strengthen it into
an assertion that cannot hold.

### 5.3 Family 3 — refusal at the occurrence open (1 test, `contract-assertion`)

**F3.1 `stamp-malformed`.** HLI version set; open a derived pulse whose stamp
fails the version grammar.

Asserts, in order:

1. **The data-entry open forwards.** Asserted, not skipped: it is what locates
   the refusal at the next seam rather than this one, and a shim refusing here
   would be refusing before it read any stamp.
2. **The occurrence open refuses** — status in the refusal band.
3. **The reason** matches the frozen string (substring; §2.2).
4. **No data seam was reached** — the IDS object is still exactly as declared.
5. **The refusal was not tolerated into a partial read** — it is barred from
   read-side tolerance, so it must arrive as a refusal status and not as a
   skipped path with a completed read.

**Get the seam right.** This is the test IMAS-Fortran had wrong, and the
correction is the most transferable thing in this document. Contract §3 puts
the refusal at the **occurrence** open and says to test it by opening, not by
reading. But *data-entry* open is not that call — a data entry holds no DD
stamp, so there is nothing for the shim to read and nothing to refuse; it
forwards and returns a usable handle. The first call that opens an
**occurrence**, and therefore the first that can carry this refusal to a user,
is `get`. IMAS-Fortran asserted on the data-entry open, was red against a shim
behaving exactly as required, and recorded the shim as the cause in its README.
**Find the call in your HLI that performs the occurrence open, and assert
there.** In most HLIs that is `get` / `get_slice`.

### 5.4 Family 4 — read conversion, by rule (4 tests, `contract-assertion`)

All four share the same two reads: the older-DD pulse through the shim
(**converted**), and the newer-DD pulse same-version (**oracle**). Offer them
as two separate calls rather than one paired call — the refusal test has to
copy the refused-path record out **between** them, because the record resets at
the start of each read and the oracle read would erase what that test exists to
assert.

**Preconditions MUST be asserted, not assumed.** A failed oracle read makes
every verdict absent-vs-absent, which proves nothing and looks like a pass in a
suite that counts mismatches. Require: the oracle read succeeded *cleanly*; the
converted read succeeded or returned the partial-read status, but nothing else;
and both reached the containers the assertions index into.

**F4.1 `structural-rules`.** The `identical` / `renamed` / `moved` / `merged` /
`split` table (23 entries in IMAS-Fortran). Expects `SAME` per rule.

A rule combining several leaves (an r/z pair, a split's two targets) folds into
one verdict: it fails if any leaf does, and the **first non-agreeing verdict**
is what gets reported, so the message names what went wrong rather than the
expectation. The fold **MUST** look the expectation up through the kind mapping
(§4.5), not hardcode `SAME`.

**F4.2 `cocos-rules`.** Every sign flip the map declares (30 entries). Also
expects `SAME` — a correct flip leaves the two HLI-side values equal — so
`NOFLIP` is what a stopped flip reports, and it must fail at mismatch severity.

Do **not** pad this table to a count quoted in a ticket (§4.5). And do not
carry paths negated outside the map's flip block: for a `right_only` path there
is no conversion for a sign flip to be a statement about, so asserting it here
tests the fixture, not the shim. Assert those as `right_only` rules instead.

**F4.3 `right-only-rules`.** The 13 paths the newer DD introduced. Expects
`ONLY_ORACLE` — the shim correctly serves nothing, and the oracle holds a real
value proving the comparison is not vacuous.

This test **MUST** carry the vacuity demonstration of D6: take a reading the
assertions above just established is served-nothing, and put it through the
*same* agreement predicate every rule check uses, against an expectation
fetched from a real structural-table entry. Two assertions — that the anchor
reading is genuinely served-nothing (so the demonstration cannot pass
vacuously), and that it fails an agreement expectation (the property itself).
Pick an anchor rule that currently **holds**; if it is red the demonstration
fails for the same cause as the rule and stops demonstrating anything.

**F4.4 `refusal-rules`.** The paths the map refuses: the one `retyped` rule and
the four unit-`redefined` globs.

This is the family's most instructive test, because **a refusal must arrive on
all three channels and a suite checking only one would pass while the other two
were broken**:

1. **Value** — the field is left absent, so a caller sees an absent quantity
   rather than a converted one or a defaulted zero;
2. **Refused-path record** — the path is *named*, so the refusal is
   discoverable rather than merely survivable;
3. **Status** — the read reports a partial outcome, so the caller's
   `status != 0` test fires.

Tolerating a refusal without reporting it is a **failure** here, not a success:
a read that left the field unset, ran to the end and returned 0 satisfies
channel 1 and fails 2 and 3.

For the `retyped` rule the refusal is **correct** and is asserted as a tolerated
refusal, with three structural checks around it: the containers *around* the
refused path survived (so the refusal is what is being observed); a field read
*after* it within the same structure arrived (so the refusal was absorbed at
the field, not by truncating the enclosing struct); and a served field from
later in the traversal still agrees (so the read carried on *serving data*, not
merely carried on).

For the four `redefined` rules the expectation is that the value **is** served:
both dictionaries hold the same number — there is nothing to apply to a
redefinition — so the number should be delivered. Assert agreement **and**
assert that no refusal for that path appears in the record. Both halves are red
while the shim refuses them, and per D5 they stay that way.

Why the double assertion matters: for a redefinition, both fixtures hold the
same number **by construction**. A shim passing the older number straight
through would look perfect to a value comparison while handing a physicist a
number that no longer means what its label says. What separates the two is the
absence of the value plus a named entry in the record.

When matching the record, match **three** things and no fewer: the path (the
record may hold only a leaf name, so match the full DD path inside the
*message*, which carries it — and match the leaf on its tail, so a future
generator prefixing it does not break the test); the **reason** string (a test
accepting any refusal would not notice the wrong rule firing); and the status
**band** (so an ordinary I/O error recorded here cannot satisfy it).

### 5.5 Family 5 — the loss log (1 test, `contract-assertion`)

**F5.1 `nested-loss`.** A cross-version read of the full older-DD pulse, with a
private loss-log directory, wrapped by a harness step that then inspects the file.

The program itself asserts only that the read reported a partial outcome and
that at least one path was refused. The **harness** asserts:

- the fixture is **unchanged** after the read (§3.3);
- **exactly one** loss file exists in the private directory;
- the **format marker** and the **column header** are exact;
- every row has **7 columns**;
- the set of `(operation, fidelity, path)` triples is **exactly** the expected
  set — sorted-set equality, not "contains".

Two conventions this test establishes, both about what an expected set may
contain:

**Expected sets may contain honest refusals with a different fidelity, and you
must explain why per row.** IMAS-Fortran's expected set holds 14 `LOSSY` rows
and 3 `UNMAPPABLE` ones. The `LOSSY` rows all come from `right_only` rules
carrying a `lossy` reverse fidelity. The three `UNMAPPABLE` ones are
`right_only` too — one of them a *sibling of a LOSSY row under the same single
subtree rule*, so the map draws no distinction between them at all. **Shape
does**: those three are the map's only `struct_array` `right_only` paths, so
they alone need an array-of-structures context open, and a `right_only` path
has no stored counterpart to open. The shim stamps that refusal `UNMAPPABLE` at
the seam without consulting the map, because no conversion ran to have a
fidelity. Both verdicts are right; they answer different questions.

The lesson, stated as a rule: **when two siblings disagree, check the DD
`data_type` before you read the map.** IMAS-Fortran spent a review cycle
treating this as an unexplained asymmetry in the map.

And the caveat that must travel with it: what this pins is the **refusal
decision**, not the absence of a mapping. A shim that returned an empty
array-of-structures instead of refusing would move these rows and turn this
test red **on an improvement**. A reader arriving from that failure should
suspect the decision changed, not that a mapping regressed. Write that in the
test.

**A known defect MUST NOT be listed as an expected row.** IMAS-Fortran keeps a
separate `known_defect` set: rows the shim emits today that the contract says
it should not. They are removed from the actual set and reported as their own
named failure. Listing them among the expected rows would make the test pass
for exactly as long as the defect stands and **go red the day it is fixed** —
red on the fix, green on the bug. It would also directly contradict F4.4, which
asserts those same paths are served; the suite would then hold two opposite
expectations of one defect, with no state of the shim satisfying both.

### 5.6 Family 6 — write and delete (4 tests)

**F6.1 `roundtrip-cross-dd`** (`contract-assertion`). Against a **private copy**
of the older-DD pulse: append one slice carrying a curated value at a mapped
COCOS path, then read the whole occurrence back and check the value returned.

**F6.2 `roundtrip-same-dd`** (`contract-assertion`). The identical program
against a private copy of the **same-version** pulse.

**These two are one argument and MUST NOT be split up.** Only the cross-DD case
exercises the map; the same-version control is what rules out a round trip that
succeeds *without* conversion. The two differ in exactly one further way, and
the harness passes it in: the complete older-DD fixture contains paths the shim
refuses, so its read may legitimately be **partial**, while the control's read
**must be clean** — otherwise it could not prove the cross-DD round trip is
meaningful. Pass that as an explicit argument (`clean-read` /
`partial-read-allowed`) and **reject any other value**, rather than defaulting.

Assert the whole shape of the append, not just the value: the container grew by
exactly one; the time base grew by one; the time-mode flag is unchanged; the
appended slice's own time is right; the curated value came back.

**And state in the test what it does not prove.** Contract §9: write flips
HLI→stored and read flips stored→HLI, so the caller's value returns whether or
not the shim's sign convention is right, and whether or not the value on disk
is even in the stored convention. A round trip is a **consistency check**, not
a correctness proof. It gives zero evidence about the stored path, the raw sign
on disk, the stamp, or whether a non-primary candidate was correctly left
alone. Those need C5 (§2), a different suite.

**F6.3 `torn-write`** (**`behaviour-pin`**). Against a private copy of the
older-DD pulse: build a slice containing both a mapped field *and* a field that
exists only in the newer DD, and `put_slice` it.

Asserts: the call reports a **partial put**; the harness finds the exact
refused path named in the diagnostic on **stdout** (not stderr — a match on
stderr would mean the path was named by an error rather than by the traversal
that tolerated it); and the read-back shows the **torn** result — the container
is one element longer, and the field written *before* the refusal is readable.

This is a pin on an **accepted limitation**, which is why its label differs.
The HLI's generated write traversal has no rollback: a refusal partway through
leaves everything already written on disk, and the container one element longer
regardless, because the array-of-structures open widened it before any leaf
write ran and the core commits that shape at end-action time no matter what
follows. Do not expect atomic rollback and do not write a test that demands it.

The harness **MUST** assert the **specific** path, not merely that *some* write
was refused — a traversal dropping a different field would carry the same
partial status and must still fail this pin.

**F6.4 `full-put-stamp`** (`contract-assertion`). Against a private copy of the
older-DD pulse opened by the newer-DD HLI: read the occurrence, add a marker
value at a field the traversal reaches *after* `ids_properties`, and perform a
**full put** (not a slice put).

This **MUST** stay a full-put scenario: a slice put has an empty body for the
DD-version stamp and never reaches it.

Asserts four things, each on its own counter, read out **before** any later
operation can disturb them:

1. **The delete seam refused** — a full put opens by deleting the previous
   occurrence, and a delete that would remove the stamp while data remains is
   refused;
2. **The write seam refused** — a write to the stamp under a mismatch is
   refused always;
3. **The status** is the partial-put outcome — asserted as the derived summary
   it is, not as the primary evidence;
4. **The traversal finished and the stored stamp survived** — the marker field
   after `ids_properties` reads back, and the stamp still names the **stored**
   version, not the HLI's.

**Why 1 and 2 are separate counters.** Either refusal alone makes the operation
partial, so the status no longer identifies which happened. IMAS-Fortran
asserted the status alone and it was sufficient only because of a defect — its
generated delete traversal discarded the status at all 7757 of its call sites,
so a tolerated refusal never became a partial outcome. Once refused deletes were
recorded, the status would have been satisfied by the delete refusal alone and
the test would have stopped noticing whether the stamp write was refused at all.
**When two independent conditions collapse into one summary status, assert each
condition and treat the status as derived.**

This test is also the one whose result depends on which IMAS-Core is loaded
(D5, rule 2). Against a core whose HDF5 delete ignores its `path` argument, the
first delete a full put issues destroys the whole occurrence; the refused stamp
delete then protects nothing, the stamp probe that follows finds no occurrence,
an absent stamp is presumed to match, no conversion is armed, and every write
is an untranslated forward. The test is red, and neither this repository nor
the shim is the cause.

---

## 6. Harness conventions

**Registration.** The suite registers **only** in a shim-enabled build. With
shim mode off there is nothing to assert and the test list **MUST** stay exactly
what it was.

**Graceful non-registration.** A missing prerequisite — no dependency inspector,
no fixture-generation venv, an unsupported platform — **MUST** print a status
line naming what is missing and skip registration. It **MUST NOT** register a
test that silently passes. Skipping the whole suite on a missing prerequisite is
acceptable and honest; a green run that checked nothing is not.

**Pass conditions.** Refusals, `SKIPPED`, `REFUSED WRITE` and other error-shaped
text are **legitimate output** of these tests. The pass condition is therefore a
**distinctive failure marker plus the exit status** — never the absence of the
word "error". IMAS-Fortran gives each program a marker
(`STRUCTURAL-FAILURE`, `COCOS-FAILURE`, `RIGHT-ONLY-FAILURE`,
`REFUSAL-FAILURE`, `COMPARISON-FAILURE`, `SCENARIO-FAILURE`) and configures the
runner to fail on it.

Where a harness step both runs a program and inspects what it left behind, it
**MUST** require the program's clean exit **and** its own assertion. Using only
a "this string appeared in the output" pass condition would accept the expected
line even though a later assertion in the program aborted.

**Isolation.** Per §3.3 and §3.4: private loss-log directory per test, cleaned
before the run; private fixture copy per write scenario; one process per
version scenario. Build-system note: if your build writes per-target
intermediates into a shared directory (Fortran `.mod` files are the classic
case), give every target in the suite its own, or parallel builds race.

**Labels.** `shim` on everything; plus `contract-assertion`, `behaviour-pin`,
or `harness`. A reviewer must be able to select only the statements about the
agreement.

**CI.** IMAS-Fortran deliberately does **not** gate CI on this suite, because a
suite designed to start red cannot gate anything until the red list is empty and
stays that way. Wiring it into CI is a decision to take explicitly, with the
loaded IMAS-Core pinned.

---

## 7. Conformance checklist

Implement in this order; each step makes the next one meaningful.

- [ ] **Declare your profile** (§2.3) and your direction (D2) in the suite README.
- [ ] **F1.1 linkage.** Until this passes, nothing else means anything.
- [ ] **Comparator + F1.2 unit test** (§4.1–4.4).
- [ ] **F1.3 verdict orientation** (§4.3), with its match-count floor.
- [ ] **Fixture pair in place + F1.4 provenance** (§3.1–3.2).
- [ ] **Loss-log directory isolation + cleaning** for every test (§3.4).
- [ ] **F2.1–F2.4 passthrough.** Cheap, and they prove the environment is wired.
- [ ] **F3.1 stamp-malformed** — get the seam right (§5.3).
- [ ] **Rule table with citations** (§4.5) + the shared rule-checking loop.
- [ ] **F4.1–F4.3 read conversion**, including the vacuity demonstration.
- [ ] **F4.4 refusal rules** — three channels.
- [ ] **F5.1 loss log**, with `expected` and `known_defect` sets kept apart.
- [ ] **F6.1–F6.2 round trip**, as a pair.
- [ ] **F6.3 torn write** as a `behaviour-pin`.
- [ ] **F6.4 full-put stamp**, counters asserted separately.
- [ ] **Run guards** on every program (D6).
- [ ] **README with the observed red list**, the loaded IMAS-Core, the date, and
      the coverage boundaries of §8.

A suite that stops after the passthrough family is still worth having. A suite
that implements the rule families **without** F1.1–F1.4 is worse than none: it
reports a coverage it does not have.

---

## 8. Coverage boundaries to restate in your own README

Copy these, adjusted for your HLI. They are not disclaimers; they are the
difference between a suite that is trusted correctly and one that is trusted
too much.

1. **One direction.** The reverse needs a second from-scratch build against the
   other DD. In the shipped artifact that leaves **23 `left_only` rules
   unreachable**.
2. **A rule, not every leaf, is the unit** (D3). A shim serving part of a
   subtree escapes detection.
3. **No C-ABI tests** (D1). The shim repository owns seam-level coverage and can
   inject failures this suite cannot reach.
4. **Any assertion that reaches below the public API is a named exception.**
   IMAS-Fortran has exactly one — the malformed-stamp *reason*, which the
   refusal delivers at a seam whose message its `get` prints but does not
   return, so the test reads it from the read-policy's record of the last
   non-zero status, guarded by matching the status code first. List yours, or
   state that you have none.
5. **Per-candidate delete effects are not observable** against real HDF5: the
   backend's delete ignores its path argument and removes the whole IDS file,
   so a candidate fan-out collapses to one whole-occurrence deletion. Test the
   call sequence (shim repository, recording stub) separately from the on-disk
   consequence.
6. **`timebase` conversion beyond identity is untested** — `time` is untouched
   by any rule in the shipped artifact, so every scenario exercises timebase
   resolution at exact fidelity only.
7. **`datapath` translation on a first open is untested** — it only fires from
   an occurrence's second open onward.
8. **Merged-rule loss is ambiguity, not a measurement.** The shim never reads a
   merged field's untried candidates to check whether they held different data;
   `PotentiallyLossy` is a statement about the rule, never a verified fact about
   the occurrence.

---

## 9. Notes for IMAS-Cpp, IMAS-MATLAB, IMAS-Java

I have not read those codebases. These are the questions to answer first, in
order, because each one decides how much of §5 you can implement:

1. **Which call performs the occurrence open?** F3.1 depends entirely on this
   (§5.3), and it is *not* the data-entry open. Find the call that reaches
   `al_begin_global_action` and assert there.
2. **Does a refused path abort the read, or does the traversal continue?**
   Profile A or B (§2.3). If it aborts, F4.1–F4.4 need either narrowed reads or
   HLI work first.
3. **Can an end user learn *which* path was refused?** If yes, C3 is live and
   F4.4's channel 2 is implementable. If no, F4.4 degrades to channels 1 and 3,
   and you **MUST** say so — that is the channel that separates a refusal from
   a silent passthrough of a redefined value.
4. **What does an unserved field look like?** §2.1. If your HLI can hand back
   uninitialised memory, that is a finding to report, not a wrinkle to route
   around.
5. **How does a refusal reach the user — status code, or exception?** If it is
   an exception, the refusal *band* and the reason substring live on the
   exception; assert both, and keep the "core not resolvable" case (§2.2) out
   of the refusal handler.
6. **Does anything cross a language boundary that reshapes statuses or
   truncates messages?** A JNI or MEX layer may normalise a `-1000` into a
   generic failure, or clip the 256-byte message before your substring match
   sees the reason. Assert the reason **through the boundary** in one small test
   before relying on it in twenty.
7. **Can you enforce named arguments** (§4.3)? Keyword-only parameters, an
   options struct, a builder — pick one and make positional calling impossible.
   If the language genuinely cannot, lean harder on the source check of F1.3 and
   raise its floor.
8. **Does your test runner give each test its own process?** §3.4 requires it.
   In-process test frameworks (common in MATLAB and Java) **MUST** fork, or
   register the version scenarios as separate runner invocations.

---

## 10. Asks of the shim, carried forward

Three surfaces this convention depends on. They are reproduced here so a second
HLI adopting it makes the same asks rather than working around them silently:

1. **Keep the loss file's format marker, preamble, column order, filename
   pattern and `IMAS_MVDD_LOSS_LOG_DIR` semantics as a versioned contract.**
   It is the only loss channel a Tier-1 suite has.
2. **Publish a flattened, machine-readable rule manifest.** The externally
   available map has unresolved includes (§4.5), so every suite following this
   convention maintains a hand-authored table rather than risk silent
   under-coverage. A manifest would let the table be *generated and checked*
   rather than merely trusted.
3. **Provide a preflight check for dynamic loading and ABI compatibility.**
   Today a missing or incompatible core appears as a generic failure that a
   contributor can mistake for a conversion-contract violation (§2.2).
