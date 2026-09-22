# imas-python-fixtures

Two **completely filled** `equilibrium` HDF5 fixtures, written with
[imas-python](https://github.com/iterorganization/IMAS-Python) — one in DD
**3.39.0**, one in DD **4.1.1** — describing *one* equilibrium in two
dictionaries. The DD 4.1.1 fixture is the expected result of converting the DD
3.39.0 one: same physical content, at the renamed paths, in the renamed
containers, with the COCOS 11 → 17 sign flips applied.

Vendored verbatim from IMAS-Fortran's `imas-python-fixtures/` (see
`docs/SHIM_SUITE_CONVENTION.md` §3.1: "An HLI SHOULD reuse the existing
fixture pair rather than generate its own. Two HLIs asserting against two
different pulses are not comparable"). Do not hand-edit the generator or the
checked-in pulses independently of that repository; a divergence here would
make this suite's fixture pair incomparable with IMAS-Fortran's and with the
shim repository's own tests.

## Setup

```
pip install -r requirements.txt
```

`imas` must be importable (`python -c "import imas"`); it pulls in `imas_core`
and the Data Dictionary as dependencies.

## Usage

```
python equilibrium_seed.py [output-dir]   # default: fixtures
```

One HDF5 pulse per version is created in `<output-dir>/dd-<version>` (an
`imas:hdf5?path=...` URI, overwritten if it exists). The generated output for
both versions is checked in under `fixtures/`.

Run `./verify_fixtures.sh` to regenerate the pair outside the checkout and
compare every HDF5 dataset against the checked-in oracle. This uses `h5diff`:
HDF5 metadata is not byte-stable, so a bytewise comparison would report drift
where the fixture data is identical. `tests/shim/`'s `cpp-test-shim-fixture-
provenance` (F1.4) registers this script as a CTest test whenever both a
fixtures venv and `h5diff` are present; see `tests/shim/README.md`.

## Layout

| File | What it is |
|---|---|
| `equilibrium_seed.py` | driver: calls the two fixture modules, writes the two pulses |
| `equilibrium_values.py` | **one** equilibrium, expressed once, in COCOS 11 |
| `equilibrium_v3_39_0.py` | where DD 3.39.0 keeps each of those values |
| `equilibrium_v4_1_1.py` | where DD 4.1.1 keeps them, after the conversion |

The split is what makes "the two fixtures share their values" a property of the
code rather than a promise. Neither fixture module contains a number: both read
`equilibrium_values.py` and only decide *where* each value goes. A shared
quantity cannot drift between the versions, because there is one place it is
written.

`equilibrium_v4_1_1.py` is therefore the DD 3 → DD 4 conversion, performed by
hand, and diffing the two fixture modules shows the whole of it.

## Coverage

Every leaf node of the IDS is filled, in both versions:

| | DD 3.39.0 | DD 4.1.1 |
|---|---|---|
| leaf nodes | 527 | 486 |
| filled | 527 | 486 |

Two deliberate exceptions, both symmetric across the versions so the pair is
unaffected:

- **`grids_ggd/grid/path`** (and DD 3's per-slice copy) is left empty *because*
  the grid is described inline. A non-empty `path` means "this grid lives in
  another IDS, do not fill `grid_ggd` here", so filling both would be
  self-contradicting data rather than more coverage.
- **DD 3's error triplet** — `*_error_upper`, `*_error_lower`, `*_error_index`,
  1047 further nodes — is not filled. DD 4.1.1 has no such nodes at all, so
  populating them would add a thousand values to one side of a fixture *pair*
  whose point is that the two sides correspond.
  `dd-maps/common/error-model-3to4.xml` drops them wholesale for the same
  reason.

## What the fixtures cover

The correspondence is `dd-maps/equilibrium/3.39.0--4.1.1.xml`, and every rule
in it is exercised. Paths are relative to `time_slice` unless noted.

### Renames

| DD 3.39.0 | DD 4.1.1 |
|---|---|
| `global_quantities/beta_normal` | `global_quantities/beta_tor_norm` |
| `constraints/bpol_probe` | `constraints/b_field_pol_probe` (AOS) |
| `constraints/mse_polarisation_angle` | `constraints/mse_polarization_angle` |
| `constraints/iron_core_segment/magnetisation_r`, `_z` | `…/magnetization_r`, `_z` |
| `constraints/j_tor`, `profiles_1d/j_tor`, `profiles_2d/j_tor`, `ggd/j_tor` | `…/j_phi` |
| `profiles_2d/b_field_tor`, `ggd/b_field_tor`, `global_quantities/magnetic_axis/b_field_tor` | `…/b_field_phi` |

### Folds — one quantity, two or three DD 3 spellings

3.39.0 is a transitional version that ships some quantities twice. Both
spellings name one quantity, so **both get the same number**: a converter
folding them cannot produce a wrong answer by picking the wrong precedence,
which is the honest state of affairs — the fold is lossy only when a writer let
the two disagree.

`profiles_2d/b_r`+`b_field_r`, `b_z`+`b_field_z`, `b_tor`+`b_field_tor`;
`magnetic_axis/b_tor`+`b_field_tor`; `profiles_1d/b_average`+`b_field_average`,
`b_min`+`b_field_min`, `b_max`+`b_field_max`;
`global_quantities/w_mhd`+`energy_mhd`.

Note the modern names the map lists at precedence 1 — `profiles_1d/j_phi`,
`profiles_2d/j_phi`, `constraints/j_phi`, `ggd/j_phi`, `ggd/b_field_phi` — do
**not** exist in 3.39.0. Those folds have exactly one source, so a converter
reaching them is necessarily falling back to the obsolescent alias.

### Container and structure changes

| DD 3.39.0 | DD 4.1.1 | |
|---|---|---|
| `ids_properties/source`, `provenance/node/sources` (STR_1D) | `provenance/node/reference[]/{name,timestamp}` | field removed, moved into an AOS |
| `grids_ggd/grid/space/coordinates_type` (INT_1D) | same path, array of identifier structures | container change, same integers |
| `boundary_separatrix/{closest_wall_point,dr_dz_zero_point,gap}` | `boundary/{…}` | moved |
| `boundary_separatrix/gap/identifier` | — | dropped; DD 4's `gap/description` is a different field |
| `boundary/{lcfs,x_point,strike_point,active_limiter_point,elongation_upper,elongation_lower,b_flux_pol_norm}` | — | dropped |
| `boundary_separatrix`, `boundary_secondary_separatrix` | — | whole structures dropped |
| `coordinate_system/g{11,12,13,22,23,33}_{co,contra}variant` | — | dropped; the tensors carry the same information |
| `time_slice/ggd/grid` | — | dropped; `grids_ggd` is the single grid container |
| `global_quantities/psi_axis` | `psi_axis` **and** `psi_magnetic_axis` | split: one DD 3 value feeds both |
| — | `contour_tree` | new |

### COCOS 11 → 17

The 32 paths in the map's `<cocos>` block, and only those, are negated in the
DD 4.1.1 fixture. `equilibrium_v4_1_1.py` marks each one at the point of use.
One quantity outside the map is also negated and says so inline:
`contour_tree/node/psi` is a poloidal flux on a structure with no DD 3 source,
so the map has no rule for it, but a DD 4 document that stated it in COCOS 11
would contradict its own `global_quantities/psi_axis`.

### Redefinitions the map refuses

`constraints/{x_point,strike_point}/chi_squared_{r,z}` went from `m` to `m^-2`:
chi-squared is now normalised by the measurement variance, and no factor
inverts that without the variance used at reconstruction time. There is nothing
to apply, so the DD 3 number is written unchanged on both sides — the two
fixtures agree numerically while disagreeing about what the number means. That
is what `unmappable` looks like from the outside.

## One reality, not two

Where a field exists on only one side, it is still filled with a value
belonging to *this* equilibrium rather than with a placeholder:

- `boundary/rho_tor` (DD 4 only) is the last point of the same slice's
  `profiles_1d/rho_tor`.
- `contour_tree` (DD 4 only) describes the critical points DD 3 keeps as
  `global_quantities/magnetic_axis` (the O-point) and `boundary/x_point` (the
  saddle) — same positions, same flux.
- `boundary_separatrix` and `boundary_secondary_separatrix` (DD 3 only) are
  surfaces of the same equilibrium at flux labels just outside `boundary`, not
  copies of it.
- `coordinate_system/g_ij` (DD 3 only) are components of the
  `tensor_covariant` / `tensor_contravariant` written identically on both
  sides, taken from there rather than invented.
- `time_slice/ggd/grid` (DD 3 only) is filled from the same `grid_values(i)` as
  `grids_ggd`, so the per-slice copy and the original agree.

Two time slices are written, with different values per slice, so a slice mix-up
is visible. The numbers are a deterministic test pattern, not a converged
Grad-Shafranov solve; where self-consistency is cheap it is honoured (`psi_norm`
runs 0→1 across the profile grid, the boundary outline closes, `profiles_2d/r`
and `/z` agree with `grid/dim1` and `/dim2`), because a fixture that contradicts
itself is a bad oracle.

## Downstream

The checked-in output under `fixtures/` is build input for
`tests/shim/`'s conformance suite, which reads it directly rather than via
literals (`docs/SHIM_SUITE_CONVENTION.md` D4). Changing a value here changes
what that suite expects:

- Family 4 (read conversion, by rule) — the structural, COCOS, right-only and
  refusal rule tables (issues #13, #14) compare a shim-converted read of
  `dd-3.39.0` against a same-version read of `dd-4.1.1`.
- Family 5 (loss log) and Family 6 (write and delete) (issue #24) — the
  nested-loss read and the round-trip/torn-write/full-put scenarios, the
  latter against private per-run copies (see `tests/shim/copy_fixture.cmake`).
- The three stamp-state variants derived at build time from `dd-3.39.0` (see
  `tests/shim/derive_stamp_variant.py`) for the passthrough and
  occurrence-open-refusal families (Families 2 and 3).

No quantity here is `PINNED` to a transcribed IMAS-Cpp assertion the way
IMAS-Fortran's are: this suite reads every expected value back out of the
`dd-4.1.1` fixture itself (the oracle, `docs/SHIM_SUITE_CONVENTION.md` D4)
rather than out of a literal, so there is nothing here for a C++ test to pin.
