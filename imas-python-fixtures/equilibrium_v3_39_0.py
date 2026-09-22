"""Fill every field of a DD 3.39.0 `equilibrium`, from `equilibrium_values.py`.

Coverage is total over DD 3.39.0's 527 non-error leaf nodes. The error triplet
(`*_error_upper` / `*_error_lower` / `*_error_index`, 1047 further nodes) is
deliberately left empty: DD 4.1.1 has no such nodes at all, so filling them
would add a thousand values to one side of a fixture *pair* whose whole point
is that the two sides correspond. `dd-maps/common/error-model-3to4.xml` drops
them wholesale for the same reason.

Every value comes from `equilibrium_values.py` and nothing is invented here.
What this file decides is only *where* each value goes in DD 3.39.0's tree.
Three kinds of decision recur:

  Obsolescent aliases. 3.39.0 is a transitional version that ships some
  quantities twice -- `profiles_2d/b_tor` beside `profiles_2d/b_field_tor`,
  `global_quantities/w_mhd` beside `energy_mhd`, `profiles_1d/b_max` beside
  `b_field_max`. Both spellings name one quantity, so both get the *same*
  number. A converter folding them (see the `fold-*` rules in
  `dd-maps/equilibrium/3.39.0--4.1.1.xml`) then cannot produce a wrong answer
  by picking the wrong precedence, which is the honest state of affairs -- the
  fold is only lossy when a writer let the two disagree.

  Note that the modern spellings the map lists at precedence 1 --
  `profiles_1d/j_phi`, `ggd/j_phi`, `ggd/b_field_phi`, `profiles_2d/j_phi`,
  `constraints/j_phi` -- do **not** exist in 3.39.0. Only `j_tor` does. So
  those folds have exactly one source here, and a converter reaching them is
  necessarily falling back to the obsolescent alias.

  Structures DD 4 dropped. `boundary_separatrix` and
  `boundary_secondary_separatrix` describe surfaces at flux labels beyond the
  boundary. They are filled as what they are -- surfaces of the *same*
  equilibrium, slightly larger than `boundary` -- rather than as copies of it.
  Three of their children (`closest_wall_point`, `dr_dz_zero_point`, `gap`)
  were absorbed into DD 4's `boundary`, so those take the shared values that
  the DD 4 fixture writes under `boundary`.

  Per-slice GGD grid. `time_slice/ggd/grid` is a full copy of the grid that
  `grids_ggd` already carries. It is filled from the same `grid_values(i)`, so
  the copy and the original agree.
"""

import equilibrium_values as V
from imas.ids_defs import IDS_TIME_MODE_HOMOGENEOUS

DD_VERSION = "3.39.0"


# ------------------------------------------------------------ ids_properties


def _fill_plugin_op(node, op):
    p = V.plugin(op)
    node.name = p["name"]
    node.description = p["description"]
    node.commit = p["commit"]
    node.version = p["version"]
    node.repository = p["repository"]
    node.parameters = p["parameters"]


def _fill_infrastructure(node):
    node.name = V.PLUGIN_INFRASTRUCTURE["name"]
    node.description = V.PLUGIN_INFRASTRUCTURE["description"]
    node.commit = V.PLUGIN_INFRASTRUCTURE["commit"]
    node.version = V.PLUGIN_INFRASTRUCTURE["version"]
    node.repository = V.PLUGIN_INFRASTRUCTURE["repository"]


def _ids_properties(eq):
    ip = eq.ids_properties
    ip.comment = V.COMMENT
    ip.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS
    # DD 3's single free-text provenance field. DD 4 removed it in favour of
    # the provenance/node structure below.
    ip.source = V.SOURCE
    ip.provider = V.PROVIDER
    ip.creation_date = V.CREATION_DATE
    # ids_properties/version_put/* is written by imas-python at put() time.

    ip.provenance.node.resize(1)
    ip.provenance.node[0].path = V.PROVENANCE_PATH
    # STR_1D in DD 3; DD 4 replaces it with an array of reference structures.
    ip.provenance.node[0].sources = [V.SOURCE]

    ip.plugins.node.resize(1)
    node = ip.plugins.node[0]
    node.path = V.PLUGIN_PATH
    for aos, op in (
        (node.put_operation, "put"),
        (node.readback, "readback"),
        (node.get_operation, "get"),
    ):
        aos.resize(1)
        _fill_plugin_op(aos[0], op)
    _fill_infrastructure(ip.plugins.infrastructure_put)
    _fill_infrastructure(ip.plugins.infrastructure_get)


# ------------------------------------------------------------------ the grid


def _fill_identifier(node, triple):
    node.name, node.index, node.description = triple


def _fill_grid(grid, g):
    """Fill one ggd grid description. Used for `grids_ggd/grid` and, because
    DD 3 keeps a per-slice copy of it, for `time_slice/ggd/grid` as well."""
    _fill_identifier(grid.identifier, V.ID_GGD_GRID)
    grid.path = g["path"]

    grid.space.resize(V.NGGD_SPACE)
    for space in grid.space:
        _fill_identifier(space.identifier, V.ID_GGD_SPACE)
        _fill_identifier(space.geometry_type, V.ID_GGD_GEOMETRY_TYPE)
        # DD 3: a flat list of coordinate-type codes. DD 4 stores the same
        # integers as identifier structures (rule retype-coordinates-type).
        space.coordinates_type = [t[1] for t in V.ID_COORDINATES_TYPE]

        space.objects_per_dimension.resize(V.NGGD_DIM)
        for d, opd in enumerate(space.objects_per_dimension):
            _fill_identifier(opd.geometry_content, V.ID_GGD_GEOMETRY_CONTENT)
            opd.object.resize(V.NGGD_OBJ)
            for o, obj in enumerate(opd.object):
                obj.geometry = g["object_geometry"](d, o)
                obj.nodes = g["object_nodes"](d, o)
                obj.measure = g["object_measure"](d, o)
                obj.geometry_2d = g["object_geometry_2d"](d, o)
                obj.boundary.resize(V.NGGD_OBJ)
                for b, bnd in enumerate(obj.boundary):
                    bnd.index = g["object_boundary_index"](d, o, b)
                    bnd.neighbours = g["object_boundary_neighbours"](d, o, b)

    grid.grid_subset.resize(V.NGGD_SUBSET)
    for s, subset in enumerate(grid.grid_subset):
        _fill_identifier(subset.identifier, V.ID_GGD_SUBSET[s])
        subset.dimension = g["subset_dimension"](s)

        subset.element.resize(V.NGGD_ELEM)
        for e, elem in enumerate(subset.element):
            elem.object.resize(1)
            for o, obj in enumerate(elem.object):
                obj.space = g["subset_element_object_space"](s, e, o)
                obj.dimension = g["subset_element_object_dimension"](s, e, o)
                obj.index = g["subset_element_object_index"](s, e, o)

        subset.base.resize(1)
        for b, base in enumerate(subset.base):
            base.jacobian = g["subset_base_jacobian"](s, b)
            base.tensor_covariant = g["subset_base_tensor_cov"](s, b)
            base.tensor_contravariant = g["subset_base_tensor_con"](s, b)

        subset.metric.jacobian = g["subset_metric_jacobian"](s)
        subset.metric.tensor_covariant = g["subset_metric_tensor_cov"](s)
        subset.metric.tensor_contravariant = g["subset_metric_tensor_con"](s)


def _grids_ggd(eq):
    eq.grids_ggd.resize(V.NTIME)
    for i, gg in enumerate(eq.grids_ggd):
        g = V.grid_values(i)
        gg.time = g["time"]
        gg.grid.resize(V.NGGD_GRID)
        for grid in gg.grid:
            _fill_grid(grid, g)


# ------------------------------------------------------------------ boundary


def _boundary(ts, v):
    b = ts.boundary
    b.type = v["boundary_type"]
    b.outline.r = v["boundary_outline_r"]
    b.outline.z = v["boundary_outline_z"]
    # `lcfs` is DD 3's obsolescent spelling of `outline`; same surface, so the
    # same points.
    b.lcfs.r = v["boundary_outline_r"]
    b.lcfs.z = v["boundary_outline_z"]
    b.psi_norm = v["boundary_psi_norm"]
    # Obsolescent alias of psi_norm.
    b.b_flux_pol_norm = v["boundary_b_flux_pol_norm"]
    b.psi = v["boundary_psi"]
    b.geometric_axis.r = v["boundary_geometric_axis_r"]
    b.geometric_axis.z = v["boundary_geometric_axis_z"]
    b.minor_radius = v["boundary_minor_radius"]
    b.elongation = v["boundary_elongation"]
    b.elongation_upper = v["boundary_elongation_upper"]
    b.elongation_lower = v["boundary_elongation_lower"]
    b.triangularity = v["boundary_triangularity"]
    b.triangularity_upper = v["boundary_triangularity_upper"]
    b.triangularity_lower = v["boundary_triangularity_lower"]
    b.squareness_upper_inner = v["boundary_squareness_upper_inner"]
    b.squareness_upper_outer = v["boundary_squareness_upper_outer"]
    b.squareness_lower_inner = v["boundary_squareness_lower_inner"]
    b.squareness_lower_outer = v["boundary_squareness_lower_outer"]

    b.x_point.resize(V.NXPT)
    for k, xp in enumerate(b.x_point):
        xp.r = v["x_point_r"][k]
        xp.z = v["x_point_z"][k]
    b.strike_point.resize(V.NSTRIKE)
    for k, sp in enumerate(b.strike_point):
        sp.r = v["strike_point_r"][k]
        sp.z = v["strike_point_z"][k]
    b.active_limiter_point.r = v["active_limiter_point_r"]
    b.active_limiter_point.z = v["active_limiter_point_z"]


def _boundary_separatrix(ts, v):
    """DD 3 only. A surface of the same equilibrium, just outside `boundary`.

    Its closest_wall_point, dr_dz_zero_point and gap children are the ones DD 4
    moved under `boundary` (rules move-closest-wall-point, move-dr-dz-zero-point
    and move-gap), so they carry the values the DD 4 fixture writes there.
    """
    s = ts.boundary_separatrix
    s.type = v["separatrix_type"]
    s.outline.r = v["separatrix_outline_r"]
    s.outline.z = v["separatrix_outline_z"]
    s.psi = v["separatrix_psi"]
    s.geometric_axis.r = v["separatrix_geometric_axis_r"]
    s.geometric_axis.z = v["separatrix_geometric_axis_z"]
    s.minor_radius = v["separatrix_minor_radius"]
    s.elongation = v["separatrix_elongation"]
    s.elongation_upper = v["separatrix_elongation_upper"]
    s.elongation_lower = v["separatrix_elongation_lower"]
    s.triangularity = v["separatrix_triangularity"]
    s.triangularity_upper = v["separatrix_triangularity_upper"]
    s.triangularity_lower = v["separatrix_triangularity_lower"]
    s.triangularity_outer = v["separatrix_triangularity_outer"]
    s.triangularity_inner = v["separatrix_triangularity_inner"]
    s.triangularity_minor = v["separatrix_triangularity_minor"]
    s.squareness_upper_inner = v["separatrix_squareness_upper_inner"]
    s.squareness_upper_outer = v["separatrix_squareness_upper_outer"]
    s.squareness_lower_inner = v["separatrix_squareness_lower_inner"]
    s.squareness_lower_outer = v["separatrix_squareness_lower_outer"]

    s.x_point.resize(V.NXPT)
    for k, xp in enumerate(s.x_point):
        xp.r = v["x_point_r"][k]
        xp.z = v["x_point_z"][k]
    s.strike_point.resize(V.NSTRIKE)
    for k, sp in enumerate(s.strike_point):
        sp.r = v["strike_point_r"][k]
        sp.z = v["strike_point_z"][k]
    s.active_limiter_point.r = v["active_limiter_point_r"]
    s.active_limiter_point.z = v["active_limiter_point_z"]

    # --- the three children DD 4 moved under `boundary` ---
    s.closest_wall_point.r = v["closest_wall_point_r"]
    s.closest_wall_point.z = v["closest_wall_point_z"]
    s.closest_wall_point.distance = v["closest_wall_point_distance"]
    s.dr_dz_zero_point.r = v["dr_dz_zero_point_r"]
    s.dr_dz_zero_point.z = v["dr_dz_zero_point_z"]
    s.gap.resize(V.NGAP)
    for k, gap in enumerate(s.gap):
        gap.name = v["gap_name"][k]
        # DD 3 only: dropped by rule drop-gap-identifier. DD 4 carries
        # gap/description instead, which DD 3 does not have.
        gap.identifier = v["gap_identifier"][k]
        gap.r = v["gap_r"][k]
        gap.z = v["gap_z"][k]
        gap.angle = v["gap_angle"][k]
        gap.value = v["gap_value"][k]


def _boundary_secondary_separatrix(ts, v):
    """DD 3 only; DD 4 has no secondary-separatrix container at all."""
    s = ts.boundary_secondary_separatrix
    s.outline.r = v["secondary_outline_r"]
    s.outline.z = v["secondary_outline_z"]
    s.psi = v["secondary_psi"]
    s.distance_inner_outer = v["secondary_distance_inner_outer"]
    s.x_point.resize(V.NXPT)
    for k, xp in enumerate(s.x_point):
        xp.r = v["secondary_x_point_r"][k]
        xp.z = v["secondary_x_point_z"][k]
    s.strike_point.resize(V.NSTRIKE)
    for k, sp in enumerate(s.strike_point):
        sp.r = v["secondary_strike_point_r"][k]
        sp.z = v["secondary_strike_point_z"][k]


# --------------------------------------------------------------- constraints


def _constraint(node, v, k, measured, reconstructed):
    """The seven fields every DD 3 constraint structure has."""
    node.measured = measured
    node.source = v["constraint_source"]
    node.time_measurement = v["constraint_time_measurement"]
    node.exact = v["constraint_exact"]
    node.weight = v["constraint_weight"](k)
    node.reconstructed = reconstructed
    node.chi_squared = v["constraint_chi_squared"](k)


def _position(node, v, k):
    node.r = v["constraint_position_r"](k)
    node.z = v["constraint_position_z"](k)
    node.phi = v["constraint_position_phi"](k)
    node.rho_tor_norm = v["constraint_position_rho_tor_norm"](k)
    node.psi = v["constraint_position_psi"](k)


def _point_constraint(node, v, k):
    """x_point / strike_point constraints: measured and reconstructed
    positions plus a chi-squared per coordinate."""
    node.position_measured.r = v["constraint_point_measured_r"](k)
    node.position_measured.z = v["constraint_point_measured_z"](k)
    node.source = v["constraint_source"]
    node.time_measurement = v["constraint_time_measurement"]
    node.exact = v["constraint_exact"]
    node.weight = v["constraint_weight"](k)
    node.position_reconstructed.r = v["constraint_point_reconstructed_r"](k)
    node.position_reconstructed.z = v["constraint_point_reconstructed_z"](k)
    # Units m here, m^-2 in DD 4: the map calls this pair unmappable, and the
    # DD 4 fixture writes the same number so the two sides differ only in what
    # the DD says the number means.
    node.chi_squared_r = v["constraint_chi_squared_r"](k)
    node.chi_squared_z = v["constraint_chi_squared_z"](k)


def _constraints(ts, v):
    c = ts.constraints

    _constraint(
        c.b_field_tor_vacuum_r, v, 0,
        v["b_field_tor_vacuum_r_measured"], v["b_field_tor_vacuum_r_reconstructed"],
    )
    _constraint(c.ip, v, 0, v["ip_measured"], v["ip_reconstructed"])
    _constraint(
        c.diamagnetic_flux, v, 0,
        v["diamagnetic_flux_measured"], v["diamagnetic_flux_reconstructed"],
    )

    # DD 3's `bpol_probe` is DD 4's `b_field_pol_probe` (rule rename-bpol-probe).
    simple = (
        (c.bpol_probe, "b_field_pol_probe"),
        (c.faraday_angle, "faraday_angle"),
        # British spelling; DD 4 uses `mse_polarization_angle`.
        (c.mse_polarisation_angle, "mse_polarization_angle"),
        (c.flux_loop, "flux_loop"),
        (c.n_e_line, "n_e_line"),
        (c.pf_current, "pf_current"),
        (c.pf_passive_current, "pf_passive_current"),
    )
    for aos, key in simple:
        aos.resize(V.NCONSTR)
        for k, node in enumerate(aos):
            _constraint(node, v, k, v[f"{key}_measured"](k), v[f"{key}_reconstructed"](k))

    # Constraints that additionally carry a measurement position. DD 3 has no
    # `j_parallel` here -- DD 4 added it -- and spells the toroidal one `j_tor`.
    positioned = (
        (c.n_e, "n_e"),
        (c.pressure, "pressure"),
        (c.pressure_rotational, "pressure_rotational"),
        (c.q, "q"),
        (c.j_tor, "j_phi"),
    )
    for aos, key in positioned:
        aos.resize(V.NCONSTR)
        for k, node in enumerate(aos):
            _constraint(node, v, k, v[f"{key}_measured"](k), v[f"{key}_reconstructed"](k))
            _position(node.position, v, k)

    # British spelling again, on a structure this time.
    c.iron_core_segment.resize(V.NCONSTR)
    for k, seg in enumerate(c.iron_core_segment):
        _constraint(
            seg.magnetisation_r, v, k,
            v["magnetization_r_measured"](k), v["magnetization_r_reconstructed"](k),
        )
        _constraint(
            seg.magnetisation_z, v, k,
            v["magnetization_z_measured"](k), v["magnetization_z_reconstructed"](k),
        )

    c.x_point.resize(V.NXPT)
    for k, node in enumerate(c.x_point):
        _point_constraint(node, v, k)
    c.strike_point.resize(V.NSTRIKE)
    for k, node in enumerate(c.strike_point):
        _point_constraint(node, v, k)


# ---------------------------------------------------------- global_quantities


def _global_quantities(ts, v):
    g = ts.global_quantities
    g.beta_pol = v["beta_pol"]
    g.beta_tor = v["beta_tor"]
    # DD 4 renames this to beta_tor_norm (rule rename-beta-normal).
    g.beta_normal = v["beta_tor_norm"]
    g.ip = v["ip"]
    g.li_3 = v["li_3"]
    g.volume = v["volume"]
    g.area = v["area"]
    g.surface = v["surface"]
    g.length_pol = v["length_pol"]
    # DD 4 keeps psi_axis but marks it obsolescent and adds psi_magnetic_axis
    # (rule split-psi-axis). DD 3 has only this one spelling.
    g.psi_axis = v["psi_axis"]
    g.psi_boundary = v["psi_boundary"]

    g.magnetic_axis.r = v["magnetic_axis_r"]
    g.magnetic_axis.z = v["magnetic_axis_z"]
    # Two spellings of one quantity in 3.39.0, three counting DD 4's
    # b_field_phi (rule fold-axis-bphi). Same quantity, same number.
    g.magnetic_axis.b_tor = v["b_field_phi_axis"]
    g.magnetic_axis.b_field_tor = v["b_field_phi_axis"]

    g.current_centre.r = v["current_centre_r"]
    g.current_centre.z = v["current_centre_z"]
    g.current_centre.velocity_z = v["current_centre_velocity_z"]
    g.q_axis = v["q_axis"]
    g.q_95 = v["q_95"]
    g.q_min.value = v["q_min_value"]
    g.q_min.rho_tor_norm = v["q_min_rho_tor_norm"]
    # w_mhd is the obsolescent alias of energy_mhd (rule fold-energy-mhd).
    g.energy_mhd = v["energy_mhd"]
    g.w_mhd = v["energy_mhd"]
    g.psi_external_average = v["psi_external_average"]
    g.v_external = v["v_external"]
    g.plasma_inductance = v["plasma_inductance"]
    g.plasma_resistance = v["plasma_resistance"]


# ---------------------------------------------------------------- profiles_1d


def _profiles_1d(ts, v):
    p = ts.profiles_1d
    p.psi = v["p1d_psi"]
    p.phi = v["p1d_phi"]
    p.pressure = v["p1d_pressure"]
    p.f = v["p1d_f"]
    p.dpressure_dpsi = v["p1d_dpressure_dpsi"]
    p.f_df_dpsi = v["p1d_f_df_dpsi"]
    # DD 4 spells this j_phi; 3.39.0 has only j_tor.
    p.j_tor = v["p1d_j_phi"]
    p.j_parallel = v["p1d_j_parallel"]
    p.q = v["p1d_q"]
    p.magnetic_shear = v["p1d_magnetic_shear"]
    p.r_inboard = v["p1d_r_inboard"]
    p.r_outboard = v["p1d_r_outboard"]
    p.rho_tor = v["p1d_rho_tor"]
    p.rho_tor_norm = v["p1d_rho_tor_norm"]
    p.dpsi_drho_tor = v["p1d_dpsi_drho_tor"]
    p.geometric_axis.r = v["p1d_geometric_axis_r"]
    p.geometric_axis.z = v["p1d_geometric_axis_z"]
    p.elongation = v["p1d_elongation"]
    p.triangularity_upper = v["p1d_triangularity_upper"]
    p.triangularity_lower = v["p1d_triangularity_lower"]
    p.squareness_upper_inner = v["p1d_squareness_upper_inner"]
    p.squareness_upper_outer = v["p1d_squareness_upper_outer"]
    p.squareness_lower_inner = v["p1d_squareness_lower_inner"]
    p.squareness_lower_outer = v["p1d_squareness_lower_outer"]
    p.volume = v["p1d_volume"]
    p.rho_volume_norm = v["p1d_rho_volume_norm"]
    p.dvolume_dpsi = v["p1d_dvolume_dpsi"]
    p.dvolume_drho_tor = v["p1d_dvolume_drho_tor"]
    p.area = v["p1d_area"]
    p.darea_dpsi = v["p1d_darea_dpsi"]
    p.darea_drho_tor = v["p1d_darea_drho_tor"]
    p.surface = v["p1d_surface"]
    p.trapped_fraction = v["p1d_trapped_fraction"]
    for n in range(1, 10):
        setattr(p, f"gm{n}", v[f"p1d_gm{n}"])
    # Three obsolescent aliases, each beside its modern spelling (rules
    # fold-p1d-baverage, fold-p1d-bmin, fold-p1d-bmax).
    p.b_average = v["p1d_b_field_average"]
    p.b_field_average = v["p1d_b_field_average"]
    p.b_min = v["p1d_b_field_min"]
    p.b_field_min = v["p1d_b_field_min"]
    p.b_max = v["p1d_b_field_max"]
    p.b_field_max = v["p1d_b_field_max"]
    p.beta_pol = v["p1d_beta_pol"]
    p.mass_density = v["p1d_mass_density"]


# ---------------------------------------------------------------- profiles_2d


def _profiles_2d(ts, v):
    ts.profiles_2d.resize(1)
    p = ts.profiles_2d[0]
    _fill_identifier(p.type, V.ID_PROFILES_2D_TYPE)
    _fill_identifier(p.grid_type, V.ID_GRID_TYPE)
    p.grid.dim1 = v["p2d_grid_dim1"]
    p.grid.dim2 = v["p2d_grid_dim2"]
    p.grid.volume_element = v["p2d_grid_volume_element"]
    p.r = v["p2d_r"]
    p.z = v["p2d_z"]
    p.psi = v["p2d_psi"]
    p.theta = v["p2d_theta"]
    p.phi = v["p2d_phi"]
    # DD 4 spells this j_phi; 3.39.0 has only j_tor.
    p.j_tor = v["p2d_j_phi"]
    p.j_parallel = v["p2d_j_parallel"]
    # Each field component has an obsolescent alias here (rules fold-p2d-br,
    # fold-p2d-bz, fold-p2d-bphi). Same component, same number.
    p.b_r = v["p2d_b_field_r"]
    p.b_field_r = v["p2d_b_field_r"]
    p.b_z = v["p2d_b_field_z"]
    p.b_field_z = v["p2d_b_field_z"]
    p.b_tor = v["p2d_b_field_phi"]
    p.b_field_tor = v["p2d_b_field_phi"]


# ----------------------------------------------------------------------- ggd


def _ggd(ts, v, g):
    # One ggd entry per grid in grids_ggd for this slice.
    ts.ggd.resize(V.NGGD_GRID)
    for gd in ts.ggd:
        # DD 3 embeds a full copy of the grid in every time slice; DD 4 dropped
        # it (rule drop-timeslice-ggd-grid) and references grids_ggd through
        # grid_index instead. Filled from the same grid_values(i).
        _fill_grid(gd.grid, g)

        quantities = (
            (gd.r, "ggd_r", 5.0),
            (gd.z, "ggd_z", 6.0),
            (gd.psi, "ggd_psi", 7.0),
            (gd.phi, "ggd_phi", 8.0),
            (gd.theta, "ggd_theta", 9.0),
            # DD 4 spells these j_phi / b_field_phi.
            (gd.j_tor, "ggd_j_phi", 10.0),
            (gd.j_parallel, "ggd_j_parallel", 11.0),
            (gd.b_field_r, "ggd_b_field_r", 12.0),
            (gd.b_field_z, "ggd_b_field_z", 13.0),
            (gd.b_field_tor, "ggd_b_field_phi", 14.0),
        )
        for aos, key, coef_base in quantities:
            aos.resize(V.NGGD_SUBSET)
            for s, node in enumerate(aos):
                node.grid_index = v["ggd_grid_index"](s)
                node.grid_subset_index = v["ggd_grid_subset_index"](s)
                node.values = v[key](s)
                node.coefficients = v["ggd_coefficients"](s, coef_base)


# --------------------------------------------------------- coordinate_system


# The twelve obsolescent g_ij components, in the order the DD declares them,
# with the (row, column) of the tensor each one is a component of.
_G_COMPONENTS = (
    ("g11", 0, 0), ("g12", 0, 1), ("g13", 0, 2),
    ("g22", 1, 1), ("g23", 1, 2), ("g33", 2, 2),
)


def _coordinate_system(ts, v):
    cs = ts.coordinate_system
    _fill_identifier(cs.grid_type, V.ID_COORDINATE_SYSTEM_GRID_TYPE)
    cs.grid.dim1 = v["cs_grid_dim1"]
    cs.grid.dim2 = v["cs_grid_dim2"]
    cs.grid.volume_element = v["cs_grid_volume_element"]
    cs.r = v["cs_r"]
    cs.z = v["cs_z"]
    cs.jacobian = v["cs_jacobian"]
    cs.tensor_covariant = v["cs_tensor_covariant"]
    cs.tensor_contravariant = v["cs_tensor_contravariant"]
    # DD 3 only, and obsolescent already in 3.39.0 (rules drop-g*-cov /
    # drop-g*-contra). Each is one component of the tensor above it, so the
    # value is taken from there rather than invented.
    for name, a, b in _G_COMPONENTS:
        setattr(cs, f"{name}_covariant", v["cs_g_covariant"](a, b))
        setattr(cs, f"{name}_contravariant", v["cs_g_contravariant"](a, b))


# --------------------------------------------------------------------- code


def _code(eq):
    c = eq.code
    c.name = V.CODE["name"]
    c.description = V.CODE["description"]
    c.commit = V.CODE["commit"]
    c.version = V.CODE["version"]
    c.repository = V.CODE["repository"]
    c.parameters = V.CODE["parameters"]
    c.output_flag = V.CODE["output_flag"]
    c.library.resize(1)
    lib = c.library[0]
    lib.name = V.CODE_LIBRARY["name"]
    lib.description = V.CODE_LIBRARY["description"]
    lib.commit = V.CODE_LIBRARY["commit"]
    lib.version = V.CODE_LIBRARY["version"]
    lib.repository = V.CODE_LIBRARY["repository"]
    lib.parameters = V.CODE_LIBRARY["parameters"]


# -------------------------------------------------------------------- driver


def fill(eq):
    """Fill a DD 3.39.0 `equilibrium` IDS in place."""
    _ids_properties(eq)
    eq.vacuum_toroidal_field.r0 = V.R0
    eq.vacuum_toroidal_field.b0 = V.B0
    eq.time = V.TIME
    _grids_ggd(eq)

    eq.time_slice.resize(V.NTIME)
    for i, ts in enumerate(eq.time_slice):
        v = V.slice_values(i)
        g = V.grid_values(i)
        ts.time = v["time"]
        _boundary(ts, v)
        _boundary_separatrix(ts, v)
        _boundary_secondary_separatrix(ts, v)
        _constraints(ts, v)
        _global_quantities(ts, v)
        _profiles_1d(ts, v)
        _profiles_2d(ts, v)
        _ggd(ts, v, g)
        _coordinate_system(ts, v)
        ts.convergence.iterations_n = v["convergence_iterations_n"]
        _fill_identifier(
            ts.convergence.grad_shafranov_deviation_expression, V.ID_GS_DEVIATION
        )
        ts.convergence.grad_shafranov_deviation_value = v[
            "convergence_gs_deviation_value"
        ]

    _code(eq)
