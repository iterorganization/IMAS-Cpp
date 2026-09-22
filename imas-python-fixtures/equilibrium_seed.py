"""Write the two `equilibrium` HDF5 fixtures, DD 3.39.0 and DD 4.1.1.

Usage: python equilibrium_seed.py [output-dir]   # default: fixtures

This file is only the driver. What goes into each fixture lives in:

  equilibrium_values.py   one equilibrium, expressed once, in COCOS 11
  equilibrium_v3_39_0.py  where DD 3.39.0 keeps each of those values
  equilibrium_v4_1_1.py   where DD 4.1.1 keeps them, after the renames, folds,
                          relocations and COCOS 11 -> 17 sign flips that
                          dd-maps/equilibrium/3.39.0--4.1.1.xml declares

Both fixtures are filled completely: every leaf node of the IDS in that
version carries a value, except DD 3's error triplet (see the module docstring
in equilibrium_v3_39_0.py for why). The two describe the *same* equilibrium --
same magnetic axis, same boundary, same profiles -- so diffing the two fill
modules shows the whole 3 -> 4 conversion and nothing else.
"""

import shutil
import sys
from pathlib import Path

import imas

import equilibrium_v3_39_0
import equilibrium_v4_1_1

FIXTURES = (equilibrium_v3_39_0, equilibrium_v4_1_1)


def write(pulse_dir, module):
    entry = imas.DBEntry(
        f"imas:hdf5?path={pulse_dir}", "w", dd_version=module.DD_VERSION
    )
    eq = entry.factory.new("equilibrium")
    module.fill(eq)
    entry.put(eq)
    entry.close()


def main(out):
    out.mkdir(parents=True, exist_ok=True)
    for module in FIXTURES:
        pulse_dir = out / f"dd-{module.DD_VERSION}"
        shutil.rmtree(pulse_dir, ignore_errors=True)
        write(pulse_dir, module)
        print(f"wrote {pulse_dir}")


if __name__ == "__main__":
    main(Path(sys.argv[1] if len(sys.argv) > 1 else "fixtures"))
