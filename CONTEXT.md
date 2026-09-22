# IMAS-Cpp

The C++ High Level Interface of the IMAS Access Layer. Almost all of it is
generated at build time by XSLT stylesheets that transform the IMAS Data
Dictionary into C++ classes, so the stylesheets — not the generated sources —
are where this context's language is realised.

Shim-side vocabulary (shim, seam, occurrence, DD-version stamp, stored DD
version, loss log, rule, fidelity verdict) is owned by
`IMAS-Multiversion-DD-Loader/CONTEXT.md` and is used here unchanged. The terms
below are the ones this repository owns.

## Language

**Refusal band**:
The status codes `-1000..-1099`, reserved for a shim that declines to serve a
path. Disjoint from IMAS-Core's own `-1..-4`.
_Avoid_: error range, MVDD codes

**Tolerated refusal**:
A refusal that the generated traversal absorbs at a single field and carries
on past, instead of ending the operation. Only a leaf data seam and an
array-of-structures open may tolerate one.
_Avoid_: ignored error, swallowed refusal, soft failure

**Skipped path**:
One field the traversal left unset because of a tolerated refusal, recorded
with the path, the status code and the refusal message.
_Avoid_: missing field, failed path, skipped node

**Partial read**:
The outcome of a read that completed after at least one tolerated refusal. A
positive status, because the operation succeeded and the IDS is usable.
_Avoid_: failed read, incomplete read, degraded read

**Partial put**:
The write-side counterpart of a partial read. Covers both a refused write and
a refused delete, which reach the caller through the same outcome.
_Avoid_: failed put, partial write
