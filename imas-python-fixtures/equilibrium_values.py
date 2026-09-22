"""One equilibrium, expressed once, in the DD 3.39.0 sign convention (COCOS 11).

`equilibrium_v3_39_0.py` and `equilibrium_v4_1_1.py` both fill their whole IDS
from this module and nothing else. That is what makes the two fixtures describe
*one* equilibrium rather than two that happen to look alike: a shared quantity
cannot drift between the versions, because there is only one place it is
written.

Names here are version-neutral and use DD 4's modern vocabulary (`j_phi`,
`b_field_phi`, `magnetization_r`, `beta_tor_norm`, ...). Where DD 3.39.0 spells
the same quantity differently -- or twice, once under an obsolescent alias --
the DD 3 fixture writes this one value to every spelling DD 3 has. Where the
two versions genuinely disagree about *shape*, each fixture arranges this one
value into its own container; see the module docstrings there.

Sign convention: every value below is COCOS 11, which is what DD 3.39.0 uses.
`equilibrium_v4_1_1.py` negates the 32 quantities that `dd-maps/equilibrium/
3.39.0--4.1.1.xml` lists under `<cocos from="11" to="17">` and nothing else.
This module never applies a flip itself -- if it did, "the same value" would
stop meaning the same number and the fixtures would no longer be diffable.

The numbers are a deterministic test pattern, not a converged Grad-Shafranov
solve. Where self-consistency is cheap it is honoured (psi_norm runs 0->1
across the profile grid, the boundary outline closes, rho_tor_norm ends at 1,
profiles_2d/r and /z agree with grid/dim1 and /dim2), because a fixture that
contradicts itself is a bad oracle. Where it is not, values are simply distinct
and slice-dependent so that a slice mix-up or a crossed field is visible.

The quantities marked PINNED below are transcribed into assertions in
IMAS-Fortran's own `playground/play_eq_mw_convert.f90` and
`tests/two_dd/two_dd_versions_test.f90.in`. This repository vendors this
generator and its output verbatim (`docs/SHIM_SUITE_CONVENTION.md` §3.1) and
transcribes nothing: `tests/shim/`'s suite reads every expected value back out
of the `dd-4.1.1` fixture itself rather than out of a literal. The PINNED
markers are kept anyway, unedited, so this file stays diffable against
IMAS-Fortran's copy.
"""

# --------------------------------------------------------------------- sizes
# NPSI, NDIM1 and NDIM2 are PINNED: IMAS-Fortran's own tests declare arrays of
# exactly these lengths.

NTIME = 2  # time slices
NPSI = 4  # profiles_1d radial grid points
NDIM1 = 2  # profiles_2d grid/dim1 (R)
NDIM2 = 3  # profiles_2d grid/dim2 (Z)
NBND = 5  # boundary outline points (closed: last == first)
NRHO = 3  # coordinate_system grid/dim1
NTHETA = 4  # coordinate_system grid/dim2
NGAP = 2  # wall gaps around the boundary
NXPT = 1  # X-points (single null)
NSTRIKE = 2  # strike points (inner, outer divertor)
NCONSTR = 2  # elements in every constraint array of structures
NAOS = 2  # elements in every other unconstrained array of structures

# GGD: one grid, one space, two object dimensions, two grid subsets.
NGGD_GRID = 1
NGGD_SPACE = 1
NGGD_DIM = 2  # objects_per_dimension: 0D nodes, 1D edges
NGGD_OBJ = 2  # objects per dimension
NGGD_SUBSET = 2
NGGD_ELEM = 2  # elements per grid subset
NGGD_VALUES = 4  # values per ggd quantity
NGGD_COEF = 2  # interpolation coefficients per value

# ----------------------------------------------------------------- machine
# PINNED.
TIME = [1.0, 1.5]
R0 = 6.2
B0 = [5.3, 5.2]

# ---------------------------------------------------------------- metadata
COMMENT = "equilibrium DD 3.39.0 <-> DD 4.1.1 fixture pair, all fields filled"
NAME = "equilibrium_seed"
SOURCE = "equilibrium_seed fixture"
PROVIDER = "imas-python-fixtures"
CREATION_DATE = "2024-01-01T00:00:00Z"
PROVENANCE_PATH = "time_slice/profiles_1d"
PROVENANCE_TIMESTAMP = "2024-01-01T00:00:00Z"

# ids_properties/occurrence_type, DD 4 only. occurrence_type_identifier.
OCCURRENCE_TYPE = ("reconstruction", 1, "Equilibrium reconstruction")

CODE = {
    "name": "equilibrium_seed",
    "description": "Fixture generator, not a solver",
    "commit": "0000000000000000000000000000000000000000",
    "version": "1.0.0",
    "repository": "https://github.com/iterorganization/IMAS-Fortran",
    "parameters": "<parameters><fixture>equilibrium</fixture></parameters>",
    # output_flag is FLT/INT over the root time base, so one entry per slice.
    "output_flag": [0, 0],
}

CODE_LIBRARY = {
    "name": "imas-python",
    "description": "Data access layer used to write this fixture",
    "commit": "1111111111111111111111111111111111111111",
    "version": "2.3.0",
    "repository": "https://github.com/iterorganization/IMAS-Python",
    "parameters": "<parameters><backend>hdf5</backend></parameters>",
}

# ids_properties/plugins. The same six strings describe every plugin
# operation; the operation name is what distinguishes them.
PLUGIN_PATH = "time_slice/profiles_1d/psi"


def plugin(op):
    """Values for one plugins/node/<op> entry (and its library, in DD 4)."""
    return {
        "name": f"equilibrium_{op}",
        "description": f"Fixture plugin, {op}",
        "commit": "2222222222222222222222222222222222222222",
        "version": "0.1.0",
        "repository": "https://github.com/iterorganization/IMAS-Core-Plugins",
        "parameters": f"<parameters><op>{op}</op></parameters>",
    }


PLUGIN_INFRASTRUCTURE = {
    "name": "al-core",
    "description": "Access Layer infrastructure",
    "commit": "3333333333333333333333333333333333333333",
    "version": "5.4.3",
    "repository": "https://github.com/iterorganization/IMAS-Core",
}

# ------------------------------------------------------------- identifiers
# (name, index, description) triples, taken from the DD identifier schemas.

ID_PROFILES_2D_TYPE = ("total", 0, "Total fields")
ID_GRID_TYPE = (
    "rectangular",
    1,
    "Cylindrical R,Z ala eqdsk (R=dim1, Z=dim2). In this case the position "
    "arrays should not be filled since they are redundant with grid/dim1 and dim2.",
)
# Deliberately a *normalised* radial label rather than one of the `psi`
# variants: dim1 then carries a dimensionless number, identical in both
# versions. A psi-labelled grid would put a sign-flipped quantity into a node
# the DD types as `mixed` and the map's <cocos> list does not mention, leaving
# the fixture to invent a rule the conversion map does not declare.
ID_COORDINATE_SYSTEM_GRID_TYPE = (
    "inverse_rhopolnorm_straight_field_line",
    21,
    "Flux surface type with radial label sqrt[(psi-psi_axis)/(psi_edge-psi_axis)] "
    "(dim1) and the straight-field line poloidal angle (dim2)",
)
ID_GS_DEVIATION = (
    "max_absolute_psi_residual_norm",
    6,
    "Maximum absolute difference over the plasma poloidal cross-section of the "
    "normalised poloidal flux (with normalization being the poloidal flux "
    "difference between the axis and boundary) between the current and "
    "preceding iteration, on fixed grid points",
)
# convergence/result is DD 4 only.
ID_CONVERGENCE_RESULT = ("converged", 1, "Converged case with plasma")

ID_GGD_GRID = ("SN", 4, "Single null")
ID_GGD_SPACE = ("primary_standard", 1, "Primary space defining the standard grid")
ID_GGD_GEOMETRY_TYPE = ("standard", 0, "Standard geometry")
ID_GGD_GEOMETRY_CONTENT = ("node_coordinates", 1, "For nodes : node coordinates")
ID_GGD_SUBSET = [
    ("nodes", 1, "All nodes (0D) belonging to the associated spaces"),
    ("cells", 5, "All cells (2D) belonging to the associated spaces"),
]
# grids_ggd/grid/space/coordinates_type: R and Z, from coordinate_identifier.
# DD 3 stores the bare indices in an INT_1D; DD 4 stores identifier structures.
ID_COORDINATES_TYPE = [
    ("r", 4, "Major radius"),
    ("z", 3, "Vertical coordinate z"),
]

GGD_GRID_PATH = ""  # empty: the grid is described here, not by reference

# --------------------------------------------------------------------- misc
CONSTRAINT_SOURCE = "equilibrium_seed synthetic diagnostic"


# ------------------------------------------------------------------ helpers


def ramp(n, base, step, i=0, dslice=0.0):
    """n values, base + step*k, offset by dslice per time slice."""
    return [base + step * k + dslice * i for k in range(n)]


def ramp2d(n1, n2, base, d1, d2, i=0, dslice=0.0):
    """n1 x n2 values, base + d1*a + d2*b, offset by dslice per time slice."""
    return [
        [base + d1 * a + d2 * b + dslice * i for b in range(n2)] for a in range(n1)
    ]


def ramp3d(n1, n2, n3, base, d1, d2, d3, i=0, dslice=0.0):
    return [
        [[base + d1 * a + d2 * b + d3 * c + dslice * i for c in range(n3)]
         for b in range(n2)]
        for a in range(n1)
    ]


def ramp4d(n1, n2, n3, n4, base, d1, d2, d3, d4, i=0, dslice=0.0):
    return [
        [[[base + d1 * a + d2 * b + d3 * c + d4 * d + dslice * i for d in range(n4)]
          for c in range(n3)] for b in range(n2)]
        for a in range(n1)
    ]


def _outline(n, r_centre, z_centre, a, kappa, i=0):
    """A closed, convex poloidal outline: n points, last == first.

    Deliberately arithmetic rather than trigonometric so the values transcribe
    into a hand-written assertion exactly.
    """
    # n-1 distinct points around the surface, then repeat the first to close.
    steps = [(1.0, 0.0), (0.0, 1.0), (-1.0, 0.0), (0.0, -1.0)]
    pts = []
    for k in range(n - 1):
        dr, dz = steps[k % len(steps)]
        pts.append((r_centre + a * dr + 0.01 * i, z_centre + a * kappa * dz + 0.01 * i))
    pts.append(pts[0])
    return [p[0] for p in pts], [p[1] for p in pts]


# ================================================================= the values


def grid_values(i):
    """The GGD grid description for time slice i.

    Identical in both versions except for `space/coordinates_type`, whose
    container changed (see ID_COORDINATES_TYPE). DD 3 additionally carries a
    per-slice copy of this whole grid under `time_slice/ggd/grid`, which DD 4
    dropped; the DD 3 fixture fills it from here too, so the copy and the
    original agree.
    """
    return {
        "time": TIME[i],
        "path": GGD_GRID_PATH,
        # objects_per_dimension[d].object[o]
        "object_geometry": lambda d, o: ramp(2, 4.0 + d + 0.5 * o, 0.25, i, 0.01),
        "object_nodes": lambda d, o: [1 + o, 2 + o],
        "object_measure": lambda d, o: 0.5 + 0.1 * d + 0.01 * o + 0.001 * i,
        "object_geometry_2d": lambda d, o: ramp2d(2, 2, 6.0 + d + 0.5 * o, 0.1, 0.01, i, 0.001),
        "object_boundary_index": lambda d, o, b: 1 + b + o,
        "object_boundary_neighbours": lambda d, o, b: [1 + b, 2 + b],
        # grid_subset[s]
        "subset_dimension": lambda s: s + 1,
        "subset_element_object_space": lambda s, e, o: 1,
        "subset_element_object_dimension": lambda s, e, o: s + 1,
        "subset_element_object_index": lambda s, e, o: 1 + e + o,
        "subset_base_jacobian": lambda s, b: ramp(NGGD_ELEM, 1.0 + 0.1 * b, 0.01, i, 0.001),
        "subset_base_tensor_cov": lambda s, b: ramp3d(NGGD_ELEM, 2, 2, 2.0 + 0.1 * b, 0.1, 0.01, 0.001, i, 0.0001),
        "subset_base_tensor_con": lambda s, b: ramp3d(NGGD_ELEM, 2, 2, 3.0 + 0.1 * b, 0.1, 0.01, 0.001, i, 0.0001),
        "subset_metric_jacobian": lambda s: ramp(NGGD_ELEM, 1.5, 0.01, i, 0.001),
        "subset_metric_tensor_cov": lambda s: ramp3d(NGGD_ELEM, 2, 2, 2.5, 0.1, 0.01, 0.001, i, 0.0001),
        "subset_metric_tensor_con": lambda s: ramp3d(NGGD_ELEM, 2, 2, 3.5, 0.1, 0.01, 0.001, i, 0.0001),
    }


def slice_values(i):
    """Every quantity of time slice i, in COCOS 11.

    One key per physical quantity. Keys are named for the quantity, not for a
    DD path, so that a quantity DD 3 spells two ways and DD 4 spells one way
    appears here exactly once.
    """
    # --- the flux coordinates everything else hangs off ----------------------
    # PINNED: psi, f_df_dpsi, j_phi_1d, ip, ip_measured, psi_axis,
    # beta_tor_norm, b_field_phi_axis, b_field_pol_probe_measured,
    # chi_squared_r, and the profiles_2d grid and b_field_phi.
    psi = ramp(NPSI, 0.25, 1.0, i, 10.0)
    psi_axis = -0.75 - 0.05 * i
    psi_boundary = psi[-1]
    # 0 at the axis, 1 at the boundary. Sign-convention independent, so this is
    # one of the few flux quantities DD 4 does not flip.
    psi_norm = [(p - psi_axis) / (psi_boundary - psi_axis) for p in psi]

    rho_tor_boundary = 1.85 + 0.01 * i
    rho_tor = [rho_tor_boundary * pn for pn in psi_norm]
    rho_tor_norm = list(psi_norm)

    r_axis = 6.35 + 0.01 * i
    z_axis = 0.55 + 0.01 * i
    minor_radius = 1.95 + 0.01 * i

    bnd_r, bnd_z = _outline(NBND, r_axis, z_axis, minor_radius, 1.7, i)
    sep_r, sep_z = _outline(NBND, r_axis, z_axis, minor_radius + 0.05, 1.75, i)
    sec_r, sec_z = _outline(NBND, r_axis, z_axis, minor_radius + 0.30, 1.80, i)

    return {
        # ------------------------------------------------------------- time
        "time": TIME[i],

        # =========================================================== boundary
        # DD 3 `boundary` and DD 4 `boundary` share these. DD 3's
        # `boundary_separatrix` describes a slightly larger surface (same
        # equilibrium, different flux label), so it gets its own geometry
        # below rather than a copy.
        "boundary_type": 1,  # 0 limiter, 1 separatrix/divertor
        "boundary_outline_r": bnd_r,
        "boundary_outline_z": bnd_z,
        "boundary_psi_norm": 0.995,
        "boundary_psi": psi_boundary,
        "boundary_geometric_axis_r": r_axis - 0.05,
        "boundary_geometric_axis_z": z_axis - 0.05,
        "boundary_minor_radius": minor_radius,
        "boundary_elongation": 1.70 + 0.01 * i,
        "boundary_elongation_upper": 1.72 + 0.01 * i,  # DD 3 only
        "boundary_elongation_lower": 1.68 + 0.01 * i,  # DD 3 only
        "boundary_triangularity": 0.45 + 0.01 * i,
        "boundary_triangularity_upper": 0.38 + 0.01 * i,
        "boundary_triangularity_lower": 0.52 + 0.01 * i,
        "boundary_squareness_upper_inner": 0.11 + 0.01 * i,
        "boundary_squareness_upper_outer": 0.12 + 0.01 * i,
        "boundary_squareness_lower_inner": 0.13 + 0.01 * i,
        "boundary_squareness_lower_outer": 0.14 + 0.01 * i,
        # DD 4 only, but the same equilibrium: the toroidal flux label at the
        # boundary is the last point of the profiles_1d grid.
        "boundary_rho_tor": rho_tor[-1],
        "boundary_phi": 122.0 + 0.5 * i,
        "boundary_phi_poloidal_current": 3.5 + 0.05 * i,
        # DD 3 only: `lcfs` was the obsolescent spelling of `outline`, so it
        # carries the same outline.
        "boundary_b_flux_pol_norm": 0.995,

        # Point geometry. In DD 3 these hang off `boundary` (and again off
        # `boundary_separatrix`); DD 4 dropped both copies and describes the
        # same critical points through `contour_tree` instead, which is how the
        # DD 4 fixture keeps them.
        "x_point_r": [5.35 + 0.01 * i],
        "x_point_z": [-3.35 - 0.01 * i],
        "strike_point_r": [4.55 + 0.01 * i, 5.55 + 0.01 * i],
        "strike_point_z": [-3.85 - 0.01 * i, -3.95 - 0.01 * i],
        "active_limiter_point_r": 8.30 + 0.01 * i,
        "active_limiter_point_z": 0.65 + 0.01 * i,

        # Absorbed by DD 4's `boundary`, from DD 3's `boundary_separatrix`.
        "closest_wall_point_r": 8.05 + 0.01 * i,
        "closest_wall_point_z": 0.75 + 0.01 * i,
        "closest_wall_point_distance": 0.35 + 0.01 * i,
        "dr_dz_zero_point_r": 8.20 + 0.01 * i,
        "dr_dz_zero_point_z": 0.45 + 0.01 * i,
        "gap_name": ["gap_outboard", "gap_inboard"],
        # DD 3 only: gap/identifier has no DD 4 counterpart. DD 4 has
        # gap/description, which DD 3 lacks.
        "gap_identifier": ["GAP_OUT", "GAP_IN"],
        "gap_description": ["Outboard midplane gap", "Inboard midplane gap"],
        "gap_r": [8.15 + 0.01 * i, 4.15 + 0.01 * i],
        "gap_z": [0.55 + 0.01 * i, 0.55 + 0.01 * i],
        "gap_angle": [0.0, 3.14],
        "gap_value": [0.25 + 0.01 * i, 0.35 + 0.01 * i],

        # --------------------------------------- boundary_separatrix (DD 3)
        "separatrix_type": 1,
        "separatrix_outline_r": sep_r,
        "separatrix_outline_z": sep_z,
        "separatrix_psi": psi_boundary + 0.10,
        "separatrix_geometric_axis_r": r_axis - 0.04,
        "separatrix_geometric_axis_z": z_axis - 0.04,
        "separatrix_minor_radius": minor_radius + 0.05,
        "separatrix_elongation": 1.75 + 0.01 * i,
        "separatrix_elongation_upper": 1.77 + 0.01 * i,
        "separatrix_elongation_lower": 1.73 + 0.01 * i,
        "separatrix_triangularity": 0.47 + 0.01 * i,
        "separatrix_triangularity_upper": 0.40 + 0.01 * i,
        "separatrix_triangularity_lower": 0.54 + 0.01 * i,
        "separatrix_triangularity_outer": 0.21 + 0.01 * i,
        "separatrix_triangularity_inner": 0.23 + 0.01 * i,
        "separatrix_triangularity_minor": 0.09 + 0.01 * i,
        "separatrix_squareness_upper_inner": 0.16 + 0.01 * i,
        "separatrix_squareness_upper_outer": 0.17 + 0.01 * i,
        "separatrix_squareness_lower_inner": 0.18 + 0.01 * i,
        "separatrix_squareness_lower_outer": 0.19 + 0.01 * i,

        # ---------------------------- boundary_secondary_separatrix (DD 3)
        "secondary_outline_r": sec_r,
        "secondary_outline_z": sec_z,
        "secondary_psi": psi_boundary + 0.30,
        "secondary_distance_inner_outer": 0.09 + 0.01 * i,
        "secondary_x_point_r": [5.15 + 0.01 * i],
        "secondary_x_point_z": [3.55 + 0.01 * i],
        "secondary_strike_point_r": [4.35 + 0.01 * i, 5.75 + 0.01 * i],
        "secondary_strike_point_z": [3.95 + 0.01 * i, 4.05 + 0.01 * i],

        # ------------------------------------------- contour_tree (DD 4 only)
        # The same critical points DD 3 keeps under boundary/x_point and
        # global_quantities/magnetic_axis, in DD 4's topological form.
        # critical_type: 0 minimum (O-point / magnetic axis), 1 saddle
        # (X-point).
        "contour_node_critical_type": [0, 1],
        "contour_node_r": [r_axis, 5.35 + 0.01 * i],
        "contour_node_z": [z_axis, -3.35 - 0.01 * i],
        "contour_node_psi": [psi_axis, psi_boundary + 0.10],
        "contour_node_levelset_r": lambda n: ramp(3, 6.0 + 0.1 * n, 0.2, i, 0.01),
        "contour_node_levelset_z": lambda n: ramp(3, 0.5 + 0.1 * n, 0.2, i, 0.01),
        "contour_edges": [[1, 2], [2, 1]],

        # ======================================================== constraints
        # Every constraint structure has the same seven fields. `k` indexes the
        # element of an array of structures; a 0D constraint passes k=0.
        "constraint_source": CONSTRAINT_SOURCE,
        "constraint_time_measurement": TIME[i],
        "constraint_exact": 0,
        "constraint_weight": lambda k: 1.0 + 0.1 * k + 0.01 * i,
        # chi_squared is dimensionless in DD 4 and carries the measurement's
        # units in DD 3, but the DD does not restate the value, so one number
        # serves both.
        "constraint_chi_squared": lambda k: 0.02 + 0.01 * k + 0.001 * i,

        "b_field_tor_vacuum_r_measured": 32.86 + 0.1 * i,
        "b_field_tor_vacuum_r_reconstructed": 32.80 + 0.1 * i,
        "b_field_pol_probe_measured": lambda k: 0.42 + 0.01 * i + 0.10 * k,  # PINNED at k=0
        "b_field_pol_probe_reconstructed": lambda k: 0.41 + 0.01 * i + 0.10 * k,
        "diamagnetic_flux_measured": 0.031 + 0.001 * i,
        "diamagnetic_flux_reconstructed": 0.030 + 0.001 * i,
        "faraday_angle_measured": lambda k: 0.21 + 0.01 * i + 0.05 * k,
        "faraday_angle_reconstructed": lambda k: 0.20 + 0.01 * i + 0.05 * k,
        "mse_polarization_angle_measured": lambda k: 0.11 + 0.01 * i + 0.05 * k,
        "mse_polarization_angle_reconstructed": lambda k: 0.10 + 0.01 * i + 0.05 * k,
        "flux_loop_measured": lambda k: 1.15 + 0.01 * i + 0.10 * k,
        "flux_loop_reconstructed": lambda k: 1.14 + 0.01 * i + 0.10 * k,
        "ip_measured": 15.1e6 + 1.0e5 * i,  # PINNED
        "ip_reconstructed": 15.05e6 + 1.0e5 * i,
        "magnetization_r_measured": lambda k: 1.31 + 0.01 * i + 0.10 * k,
        "magnetization_r_reconstructed": lambda k: 1.30 + 0.01 * i + 0.10 * k,
        "magnetization_z_measured": lambda k: 1.41 + 0.01 * i + 0.10 * k,
        "magnetization_z_reconstructed": lambda k: 1.40 + 0.01 * i + 0.10 * k,
        "n_e_measured": lambda k: 8.1e19 + 1.0e18 * i + 1.0e18 * k,
        "n_e_reconstructed": lambda k: 8.0e19 + 1.0e18 * i + 1.0e18 * k,
        "n_e_line_measured": lambda k: 7.1e19 + 1.0e18 * i + 1.0e18 * k,
        "n_e_line_reconstructed": lambda k: 7.0e19 + 1.0e18 * i + 1.0e18 * k,
        "pf_current_measured": lambda k: 4.1e5 + 1.0e4 * i + 1.0e4 * k,
        "pf_current_reconstructed": lambda k: 4.0e5 + 1.0e4 * i + 1.0e4 * k,
        "pf_passive_current_measured": lambda k: 2.1e4 + 1.0e3 * i + 1.0e3 * k,
        "pf_passive_current_reconstructed": lambda k: 2.0e4 + 1.0e3 * i + 1.0e3 * k,
        "pressure_measured": lambda k: 8.1e4 + 1.0e3 * i + 1.0e3 * k,
        "pressure_reconstructed": lambda k: 8.0e4 + 1.0e3 * i + 1.0e3 * k,
        "pressure_rotational_measured": lambda k: 5.1e3 + 1.0e2 * i + 1.0e2 * k,
        "pressure_rotational_reconstructed": lambda k: 5.0e3 + 1.0e2 * i + 1.0e2 * k,
        "q_measured": lambda k: 1.21 + 0.01 * i + 0.50 * k,
        "q_reconstructed": lambda k: 1.20 + 0.01 * i + 0.50 * k,
        "j_phi_measured": lambda k: 9.1e5 + 1.0e4 * i + 1.0e4 * k,
        "j_phi_reconstructed": lambda k: 9.0e5 + 1.0e4 * i + 1.0e4 * k,
        "j_parallel_measured": lambda k: 8.1e5 + 1.0e4 * i + 1.0e4 * k,
        "j_parallel_reconstructed": lambda k: 8.0e5 + 1.0e4 * i + 1.0e4 * k,

        # The position structure shared by the profile-like constraints.
        "constraint_position_r": lambda k: 7.05 + 0.10 * k + 0.01 * i,
        "constraint_position_z": lambda k: 0.45 + 0.10 * k + 0.01 * i,
        "constraint_position_phi": lambda k: 0.35 + 0.10 * k,
        "constraint_position_rho_tor_norm": lambda k: 0.30 + 0.20 * k,
        "constraint_position_psi": lambda k: 1.05 + 0.50 * k + 0.01 * i,

        # x_point / strike_point constraints. chi_squared_r and chi_squared_z
        # are the one pair the map calls unmappable (m -> m^-2), so the value
        # is written unchanged on both sides and the middleware is expected to
        # refuse rather than reproduce it. PINNED at k=0.
        "constraint_point_measured_r": lambda k: 5.35 + 0.10 * k + 0.01 * i,
        "constraint_point_measured_z": lambda k: -3.35 - 0.10 * k - 0.01 * i,
        "constraint_point_reconstructed_r": lambda k: 5.30 + 0.10 * k + 0.01 * i,
        "constraint_point_reconstructed_z": lambda k: -3.30 - 0.10 * k - 0.01 * i,
        "constraint_chi_squared_r": lambda k: 0.05 + 0.01 * i + 0.10 * k,
        "constraint_chi_squared_z": lambda k: 0.06 + 0.01 * i + 0.10 * k,

        # DD 4 only.
        "constraints_chi_squared_reduced": 0.85 + 0.01 * i,
        "constraints_freedom_degrees_n": 120 + i,
        "constraints_n": 145 + i,

        # =================================================== global_quantities
        "beta_pol": 0.65 + 0.01 * i,
        "beta_tor": 0.025 + 0.001 * i,
        "beta_tor_norm": 1.8 + 0.1 * i,  # PINNED (DD 3: beta_normal)
        "ip": 15.0e6 + 1.0e5 * i,  # PINNED
        "li_3": 0.85 + 0.01 * i,
        "volume": 831.0 + 1.0 * i,
        "area": 21.9 + 0.1 * i,
        "surface": 683.0 + 1.0 * i,
        "length_pol": 24.3 + 0.1 * i,
        "psi_axis": psi_axis,  # PINNED
        "psi_boundary": psi_boundary,
        "rho_tor_boundary": rho_tor_boundary,  # DD 4 only
        "magnetic_axis_r": r_axis,
        "magnetic_axis_z": z_axis,
        "b_field_phi_axis": 5.2 + 0.1 * i,  # PINNED
        "current_centre_r": 6.30 + 0.01 * i,
        "current_centre_z": 0.50 + 0.01 * i,
        "current_centre_velocity_z": 0.15 + 0.01 * i,
        "q_axis": 0.95 + 0.01 * i,
        "q_95": 3.15 + 0.01 * i,
        "q_min_value": 0.92 + 0.01 * i,
        "q_min_rho_tor_norm": 0.15 + 0.01 * i,
        "q_min_psi_norm": 0.0225 + 0.01 * i,  # DD 4 only
        "q_min_psi": psi_axis + 0.1,  # DD 4 only
        "energy_mhd": 3.5e8 + 1.0e6 * i,
        "psi_external_average": 0.55 + 0.01 * i,
        "v_external": 0.35 + 0.01 * i,
        "plasma_inductance": 1.35e-5 + 1.0e-7 * i,
        "plasma_resistance": 4.5e-9 + 1.0e-11 * i,

        # ======================================================= profiles_1d
        "p1d_psi": psi,  # PINNED
        "p1d_psi_norm": psi_norm,  # DD 4 only
        "p1d_phi": ramp(NPSI, 0.5, 2.0, i, 0.5),
        "p1d_pressure": ramp(NPSI, 9.0e4, -2.0e4, i, 1.0e3),
        "p1d_f": ramp(NPSI, 32.9, -0.1, i, 0.01),
        "p1d_dpressure_dpsi": ramp(NPSI, -2.1e4, -1.0e3, i, 1.0e2),
        "p1d_f_df_dpsi": ramp(NPSI, -1.5, -1.0, i, -0.5),  # PINNED
        "p1d_j_phi": ramp(NPSI, 1.0e6, 1.0e5, i, 1.0e4),  # PINNED
        "p1d_j_parallel": ramp(NPSI, 1.1e6, 1.0e5, i, 1.0e4),
        "p1d_q": ramp(NPSI, 0.95, 0.75, i, 0.01),
        "p1d_magnetic_shear": ramp(NPSI, 0.05, 0.45, i, 0.01),
        "p1d_r_inboard": ramp(NPSI, 6.30, -0.55, i, 0.01),
        "p1d_r_outboard": ramp(NPSI, 6.40, 0.60, i, 0.01),
        "p1d_rho_tor": rho_tor,
        "p1d_rho_tor_norm": rho_tor_norm,
        "p1d_dpsi_drho_tor": ramp(NPSI, 0.35, 0.55, i, 0.01),
        "p1d_geometric_axis_r": ramp(NPSI, 6.35, -0.03, i, 0.01),
        "p1d_geometric_axis_z": ramp(NPSI, 0.55, -0.02, i, 0.01),
        "p1d_elongation": ramp(NPSI, 1.20, 0.15, i, 0.01),
        "p1d_triangularity_upper": ramp(NPSI, 0.02, 0.12, i, 0.01),
        "p1d_triangularity_lower": ramp(NPSI, 0.03, 0.16, i, 0.01),
        "p1d_squareness_upper_inner": ramp(NPSI, 0.01, 0.03, i, 0.001),
        "p1d_squareness_upper_outer": ramp(NPSI, 0.02, 0.03, i, 0.001),
        "p1d_squareness_lower_inner": ramp(NPSI, 0.03, 0.03, i, 0.001),
        "p1d_squareness_lower_outer": ramp(NPSI, 0.04, 0.03, i, 0.001),
        "p1d_volume": ramp(NPSI, 0.0, 277.0, i, 1.0),
        "p1d_rho_volume_norm": [k / (NPSI - 1) for k in range(NPSI)],
        "p1d_dvolume_dpsi": ramp(NPSI, 190.0, 30.0, i, 1.0),
        "p1d_dvolume_drho_tor": ramp(NPSI, 120.0, 180.0, i, 1.0),
        "p1d_area": ramp(NPSI, 0.0, 7.3, i, 0.1),
        "p1d_darea_dpsi": ramp(NPSI, 4.9, 0.8, i, 0.01),
        "p1d_darea_drho_tor": ramp(NPSI, 3.2, 4.7, i, 0.01),
        "p1d_surface": ramp(NPSI, 0.0, 227.0, i, 1.0),
        "p1d_trapped_fraction": ramp(NPSI, 0.0, 0.22, i, 0.001),
        "p1d_gm1": ramp(NPSI, 0.0248, 0.0005, i, 0.0001),
        "p1d_gm2": ramp(NPSI, 0.0260, 0.0090, i, 0.0001),
        "p1d_gm3": ramp(NPSI, 1.00, 0.11, i, 0.001),
        "p1d_gm4": ramp(NPSI, 0.0360, 0.0020, i, 0.0001),
        "p1d_gm5": ramp(NPSI, 27.5, -0.6, i, 0.01),
        "p1d_gm6": ramp(NPSI, 0.0380, 0.0025, i, 0.0001),
        "p1d_gm7": ramp(NPSI, 1.00, 0.03, i, 0.001),
        "p1d_gm8": ramp(NPSI, 6.35, -0.05, i, 0.01),
        "p1d_gm9": ramp(NPSI, 0.158, 0.002, i, 0.0001),
        "p1d_b_field_average": ramp(NPSI, 5.25, -0.05, i, 0.01),
        "p1d_b_field_min": ramp(NPSI, 4.15, -0.05, i, 0.01),
        "p1d_b_field_max": ramp(NPSI, 6.35, -0.05, i, 0.01),
        "p1d_beta_pol": ramp(NPSI, 0.05, 0.20, i, 0.01),
        "p1d_mass_density": ramp(NPSI, 3.4e-7, -5.0e-8, i, 1.0e-9),

        # ======================================================= profiles_2d
        # PINNED: the grid and b_field_phi.
        "p2d_grid_dim1": [4.0, 5.0],
        "p2d_grid_dim2": [-1.0, 0.0, 1.0],
        "p2d_grid_volume_element": ramp2d(NDIM1, NDIM2, 0.55, 0.05, 0.01, i, 0.001),
        # grid_type is `rectangular`, so r and z are redundant with dim1/dim2.
        # Filled anyway, and filled consistently: r[a][b] = dim1[a],
        # z[a][b] = dim2[b].
        "p2d_r": [[4.0 + a for _ in range(NDIM2)] for a in range(NDIM1)],
        "p2d_z": [[-1.0 + b for b in range(NDIM2)] for _ in range(NDIM1)],
        "p2d_psi": ramp2d(NDIM1, NDIM2, 0.30, 1.10, 0.20, i, 0.10),
        "p2d_theta": ramp2d(NDIM1, NDIM2, 0.10, 0.70, 0.30, i, 0.01),
        "p2d_phi": ramp2d(NDIM1, NDIM2, 1.50, 0.60, 0.20, i, 0.10),
        "p2d_j_phi": ramp2d(NDIM1, NDIM2, 9.5e5, 5.0e4, 1.0e4, i, 1.0e4),
        "p2d_j_parallel": ramp2d(NDIM1, NDIM2, 1.05e6, 5.0e4, 1.0e4, i, 1.0e4),
        "p2d_b_field_r": ramp2d(NDIM1, NDIM2, 0.31, 0.10, 0.01, i, 0.10),
        "p2d_b_field_phi": ramp2d(NDIM1, NDIM2, 3.1, 1.0, 0.1, i, 1.0),  # PINNED
        "p2d_b_field_z": ramp2d(NDIM1, NDIM2, 0.51, 0.10, 0.01, i, 0.10),

        # ============================================================== ggd
        # One entry per quantity per grid subset. `s` indexes the subset.
        "ggd_grid_index": lambda s: 1,
        "ggd_grid_subset_index": lambda s: ID_GGD_SUBSET[s][1],
        "ggd_r": lambda s: ramp(NGGD_VALUES, 5.5 + 0.1 * s, 0.5, i, 0.01),
        "ggd_z": lambda s: ramp(NGGD_VALUES, -0.5 + 0.1 * s, 0.5, i, 0.01),
        "ggd_psi": lambda s: ramp(NGGD_VALUES, 0.35 + 0.1 * s, 0.9, i, 0.01),
        "ggd_phi": lambda s: ramp(NGGD_VALUES, 1.35 + 0.1 * s, 0.8, i, 0.01),
        "ggd_theta": lambda s: ramp(NGGD_VALUES, 0.15 + 0.1 * s, 0.7, i, 0.01),
        "ggd_j_phi": lambda s: ramp(NGGD_VALUES, 9.6e5 + 1.0e4 * s, 5.0e4, i, 1.0e4),
        "ggd_j_parallel": lambda s: ramp(NGGD_VALUES, 1.06e6 + 1.0e4 * s, 5.0e4, i, 1.0e4),
        "ggd_b_field_r": lambda s: ramp(NGGD_VALUES, 0.32 + 0.01 * s, 0.10, i, 0.01),
        "ggd_b_field_phi": lambda s: ramp(NGGD_VALUES, 5.15 + 0.01 * s, -0.10, i, 0.01),
        "ggd_b_field_z": lambda s: ramp(NGGD_VALUES, 0.52 + 0.01 * s, 0.10, i, 0.01),
        "ggd_coefficients": lambda s, base: ramp2d(
            NGGD_VALUES, NGGD_COEF, base + 0.01 * s, 0.05, 0.005, i, 0.001
        ),

        # ================================================== coordinate_system
        # dim1 is sqrt of normalised poloidal flux (see
        # ID_COORDINATE_SYSTEM_GRID_TYPE), dim2 the straight-field-line
        # poloidal angle. Both dimensionless or angular, so neither flips.
        "cs_grid_dim1": [(k / (NRHO - 1)) ** 0.5 for k in range(NRHO)],
        "cs_grid_dim2": ramp(NTHETA, 0.0, 1.57),
        "cs_grid_volume_element": ramp2d(NRHO, NTHETA, 0.45, 0.05, 0.01, i, 0.001),
        "cs_r": ramp2d(NRHO, NTHETA, 6.35, 0.55, 0.10, i, 0.01),
        "cs_z": ramp2d(NRHO, NTHETA, 0.55, 0.45, 0.10, i, 0.01),
        "cs_jacobian": ramp2d(NRHO, NTHETA, 1.15, 0.10, 0.01, i, 0.001),
        "cs_tensor_covariant": ramp4d(NRHO, NTHETA, 3, 3, 1.05, 0.10, 0.01, 0.001, 0.0001, i, 1.0e-5),
        "cs_tensor_contravariant": ramp4d(NRHO, NTHETA, 3, 3, 2.05, 0.10, 0.01, 0.001, 0.0001, i, 1.0e-5),
        # DD 3 only: the twelve explicit metric components, obsolescent in
        # 3.39.0. They are the (a,b) entries of the tensors above, so they are
        # taken from them rather than invented -- one reality, one number.
        "cs_g_covariant": lambda a, b: ramp2d(
            NRHO, NTHETA, 1.05 + 0.001 * a + 0.0001 * b, 0.10, 0.01, i, 1.0e-5
        ),
        "cs_g_contravariant": lambda a, b: ramp2d(
            NRHO, NTHETA, 2.05 + 0.001 * a + 0.0001 * b, 0.10, 0.01, i, 1.0e-5
        ),

        # ======================================================= convergence
        "convergence_iterations_n": 42 + i,
        "convergence_gs_deviation_value": 1.5e-7 + 1.0e-9 * i,
    }
