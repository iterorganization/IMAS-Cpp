"""Verify the three derived stamp-state fixtures keep the states this suite's
passthrough and occurrence-open-refusal families (issues #13, #14) depend on
distinct.

docs/SHIM_SUITE_CONVENTION.md F2.3 vs F3.1: "Absence means 'no stamp field'; a
present-but-invalid value is unsafe metadata. Do not conflate them in a
fixture." This checks derive_stamp_variant.py kept that distinction rather
than merely trusting it did -- a bug that, say, deleted the dataset for both
"absent" and "malformed" would make F3.1 (which needs a *present* invalid
value to refuse) silently degenerate into another copy of the absence case.
"""

import sys
from pathlib import Path

import h5py

from derive_stamp_variant import MALFORMED_STAMP, MISMATCH_STAMP, STAMP_DATASET

COVERED_VERSIONS = ("3.39.0", "4.1.1")


def _read_stamp(pulse_dir: Path):
    with h5py.File(pulse_dir / "equilibrium.h5", "r") as pulse:
        if STAMP_DATASET not in pulse:
            return None
        value = pulse[STAMP_DATASET][()]
        return value.decode() if isinstance(value, bytes) else value


def fail(message: str) -> None:
    sys.exit(f"STAMP-VARIANT-FAILURE: {message}")


def main() -> None:
    absent_dir, malformed_dir, mismatch_dir = (Path(p) for p in sys.argv[1:4])

    absent_stamp = _read_stamp(absent_dir)
    if absent_stamp is not None:
        fail(f"stamp-absent fixture still has {STAMP_DATASET} (value {absent_stamp!r})")

    malformed_stamp = _read_stamp(malformed_dir)
    if malformed_stamp is None:
        fail(
            "stamp-malformed fixture has no stamp dataset at all -- "
            "indistinguishable from stamp-absent"
        )
    if malformed_stamp != MALFORMED_STAMP:
        fail(f"stamp-malformed fixture stamp is {malformed_stamp!r}, expected {MALFORMED_STAMP!r}")

    mismatch_stamp = _read_stamp(mismatch_dir)
    if mismatch_stamp is None:
        fail("stamp-mismatch fixture has no stamp dataset at all")
    if mismatch_stamp != MISMATCH_STAMP:
        fail(
            f"stamp-mismatch fixture stamp is {mismatch_stamp!r}, expected a "
            f"grammar-valid known release the artifact has no rule for ({MISMATCH_STAMP!r})"
        )
    if mismatch_stamp in COVERED_VERSIONS:
        fail("stamp-mismatch fixture must not match either version the fixture pair covers")

    print(
        "stamp variants OK: stamp-absent has no dataset; "
        "stamp-malformed and stamp-mismatch each have a distinct present value"
    )


if __name__ == "__main__":
    main()
