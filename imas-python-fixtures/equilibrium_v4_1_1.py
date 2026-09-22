"""Fill every field of a DD 4.1.1 `equilibrium`, from `equilibrium_values.py`.

Coverage is total over DD 4.1.1's 486 leaf nodes. DD 4 has no error triplet, so
unlike the DD 3 side there is nothing excluded.

This file reads the *same* values as `equilibrium_v3_39_0.py` and writes them
where DD 4.1.1 keeps them. It is the DD 3 fixture converted forward, done by
hand, which is what makes it usable as an oracle: `dd-maps/equilibrium/
3.39.0--4.1.1.xml` says what the conversion should do, and this file does it
independently of any code that executes that map.

Four things happen to a value on the way in, and they are the only differences
between this file and its DD 3 counterpart:

  Sign flips. COCOS 11 -> 17 negates exactly the 32 paths the map lists under
  `<cocos from="11" to="17">`, and `flip()` below marks every one of them at
  the point of use. Nothing else is negated. Two quantities the map cannot
  speak about are flipped anyway and say so inline: `contour_tree/node/psi` is
  a poloidal flux on a structure that has no DD 3 source, so the map has no
  rule for it, but a DD 4 fixture that stated it in COCOS 11 would contradict
  its own `global_quantities/psi_axis`.

  Renames. `beta_normal` -> `beta_tor_norm`, `bpol_probe` ->
  `b_field_pol_probe`, `magnetisation_*` -> `magnetization_*`,
  `mse_polarisation_angle` -> `mse_polarization_angle`, and the `_tor` ->
  `_phi` family.

  Folds. Where 3.39.0 shipped a quantity under two or three spellings, DD 4
  keeps one. Since the DD 3 fixture wrote one value to all of them, the fold
  has a single answer and this file writes it.

  Relocations. `closest_wall_point`, `dr_dz_zero_point` and `gap` come from DD
  3's `boundary_separatrix` and land under `boundary`. The critical points DD 3
  kept as `boundary/x_point` become `contour_tree` nodes.

Quantities with no DD 3 source at all -- `boundary/rho_tor`, `boundary/phi`,
`boundary/phi_poloidal_current`, `contour_tree`, `profiles_1d/psi_norm`,
`global_quantities/rho_tor_boundary`, `q_min/psi_norm`, `q_min/psi`,
`constraints/j_parallel`, `constraints/chi_squared_reduced`,
`constraints/freedom_degrees_n`, `constraints/constraints_n`,
`ids_properties/name`, `ids_properties/occurrence_type`, `convergence/result`
and the plugin `library` arrays -- are still filled, and filled with values
belonging to this same equilibrium rather than with placeholders. That is what
makes the pair say "one reality, two schemas" rather than "one reality plus
some noise".
"""

import equilibrium_values as V
from imas.ids_defs import IDS_TIME_MODE_HOMOGENEOUS

DD_VERSION = "4.1.1"


def flip(x):
    """COCOS 11 -> 17. Applied only to the paths the map's <cocos> block lists.

    A list comes back a list, a scalar a scalar, so a call site reads the same
    whether the quantity is 0D or 1D. Multiplying by -1 touches only the IEEE
    sign bit, so this is exactly invertible.
    """
    if isinstance(x, (list, tuple)):
        return [flip(e) for e in x]
    return -x


# ------------------------------------------------------------ ids_properties


def _fill_library(aos):
    """plugins/node/<op>/library: DD 4 only."""
    aos.resize(1)
    lib = aos[0]
    lib.name = V.CODE_LIBRARY["name"]
    lib.description = V.CODE_LIBRARY["description"]
    lib.commit = V.CODE_LIBRARY["commit"]
    lib.version = V.CODE_LIBRARY["version"]
    lib.repository = V.CODE_LIBRARY["repository"]
    lib.parameters = V.CODE_LIBRARY["parameters"]


def _fill_plugin_op(node, op):
    p = V.plugin(op)
    node.name = p["name"]
    node.description = p["description"]
    node.commit = p["commit"]
    node.version = p["version"]
    node.repository = p["repository"]
    node.parameters = p["parameters"]
    _fill_library(node.library)


def _fill_infrastructure(node):
    node.name = V.PLUGIN_INFRASTRUCTURE["name"]
    node.description = V.PLUGIN_INFRASTRUCTURE["description"]
    node.commit = V.PLUGIN_INFRASTRUCTURE["commit"]
    node.version = V.PLUGIN_INFRASTRUCTURE["version"]
    node.repository = V.PLUGIN_INFRASTRUCTURE["repository"]


def _fill_identifier(node, triple):
    node.name, node.index, node.description = triple


def _ids_properties(eq):
    ip = eq.ids_properties
    ip.comment = V.COMMENT
    ip.name = V.NAME  # DD 4 only
    ip.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS
    _fill_identifier(ip.occurrence_type, V.OCCURRENCE_TYPE)  # DD 4 only
    ip.provider = V.PROVIDER
    ip.creation_date = V.CREATION_DATE
    # ids_properties/version_put/* is written by imas-python at put() time.

    # DD 3's `ids_properties/source` string and its STR_1D
    # `provenance/node/sources` both land here: DD 4 replaced them with an
    # array of reference structures, each a name and a timestamp.
    ip.provenance.node.resize(1)
    ip.provenance.node[0].path = V.PROVENANCE_PATH
    ip.provenance.node[0].reference.resize(1)
    ip.provenance.node[0].reference[0].name = V.SOURCE
    ip.provenance.node[0].reference[0].timestamp = V.PROVENANCE_TIMESTAMP

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


def _grids_ggd(eq):
    eq.grids_ggd.resize(V.NTIME)
    for i, gg in enumerate(eq.grids_ggd):
        g = V.grid_values(i)
        gg.time = g["time"]
        gg.grid.resize(V.NGGD_GRID)
        for grid in gg.grid:
            _fill_identifier(grid.identifier, V.ID_GGD_GRID)
            grid.path = g["path"]

            grid.space.resize(V.NGGD_SPACE)
            for space in grid.space:
                _fill_identifier(space.identifier, V.ID_GGD_SPACE)
                _fill_identifier(space.geometry_type, V.ID_GGD_GEOMETRY_TYPE)
                # rule retype-coordinates-type: DD 3's INT_1D of codes becomes
                # an array of identifier structures holding the same integers.
                space.coordinates_type.resize(len(V.ID_COORDINATES_TYPE))
                for ct, triple in zip(space.coordinates_type, V.ID_COORDINATES_TYPE):
                    _fill_identifier(ct, triple)

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


# ------------------------------------------------------------------ boundary


def _boundary(ts, v):
    """DD 4's `boundary`: DD 3's `boundary` minus the point geometry, plus
    three children moved in from `boundary_separatrix`."""
    b = ts.boundary
    b.type = v["boundary_type"]
    b.outline.r = v["boundary_outline_r"]
    b.outline.z = v["boundary_outline_z"]
    b.psi_norm = v["boundary_psi_norm"]
    b.psi = flip(v["boundary_psi"])  # COCOS
    b.geometric_axis.r = v["boundary_geometric_axis_r"]
    b.geometric_axis.z = v["boundary_geometric_axis_z"]
    b.minor_radius = v["boundary_minor_radius"]
    b.elongation = v["boundary_elongation"]
    b.triangularity = v["boundary_triangularity"]
    b.triangularity_upper = v["boundary_triangularity_upper"]
    b.triangularity_lower = v["boundary_triangularity_lower"]
    b.squareness_upper_inner = v["boundary_squareness_upper_inner"]
    b.squareness_upper_outer = v["boundary_squareness_upper_outer"]
    b.squareness_lower_inner = v["boundary_squareness_lower_inner"]
    b.squareness_lower_outer = v["boundary_squareness_lower_outer"]

    # rule move-closest-wall-point / move-dr-dz-zero-point / move-gap: these
    # three lived under boundary_separatrix in DD 3.
    b.closest_wall_point.r = v["closest_wall_point_r"]
    b.closest_wall_point.z = v["closest_wall_point_z"]
    b.closest_wall_point.distance = v["closest_wall_point_distance"]
    b.dr_dz_zero_point.r = v["dr_dz_zero_point_r"]
    b.dr_dz_zero_point.z = v["dr_dz_zero_point_z"]
    b.gap.resize(V.NGAP)
    for k, gap in enumerate(b.gap):
        gap.name = v["gap_name"][k]
        # DD 4 has `description` where DD 3 had `identifier`; the latter is
        # dropped outright (rule drop-gap-identifier), so this is not a rename
        # and the two hold different strings.
        gap.description = v["gap_description"][k]
        gap.r = v["gap_r"][k]
        gap.z = v["gap_z"][k]
        gap.angle = v["gap_angle"][k]
        gap.value = v["gap_value"][k]

    # New in DD 4 (rules new-boundary-rho-tor / -phi / -phi-poloidal-current).
    # Not placeholders: rho_tor at the boundary is the last point of this
    # slice's own profiles_1d/rho_tor.
    b.rho_tor = v["boundary_rho_tor"]
    b.phi = v["boundary_phi"]
    b.phi_poloidal_current = v["boundary_phi_poloidal_current"]


def _contour_tree(ts, v):
    """DD 4 only (rule new-contour-tree).

    Nothing in DD 3 has this shape, but the critical points it describes are
    not new: node 0 is the magnetic axis DD 3 keeps under
    global_quantities/magnetic_axis, node 1 the X-point DD 3 keeps under
    boundary/x_point. Filling it from those is what keeps the two fixtures one
    equilibrium rather than two.
    """
    ct = ts.contour_tree
    n_nodes = len(v["contour_node_critical_type"])
    ct.node.resize(n_nodes)
    for n, node in enumerate(ct.node):
        node.critical_type = v["contour_node_critical_type"][n]
        node.r = v["contour_node_r"][n]
        node.z = v["contour_node_z"][n]
        # COCOS, though no map rule can say so: this structure has no DD 3
        # source, so the map has nothing to hang a <flip> on. It is still a
        # poloidal flux in a COCOS 17 document, and must agree in sign with
        # global_quantities/psi_axis, which the map does flip.
        node.psi = flip(v["contour_node_psi"][n])
        node.levelset.r = v["contour_node_levelset_r"](n)
        node.levelset.z = v["contour_node_levelset_z"](n)
    ct.edges = v["contour_edges"]


# --------------------------------------------------------------- constraints


def _constraint(node, v, k, measured, reconstructed):
    node.measured = measured
    node.source = v["constraint_source"]
    node.time_measurement = v["constraint_time_measurement"]
    node.exact = v["constraint_exact"]
    node.weight = v["constraint_weight"](k)
    node.reconstructed = reconstructed
    node.chi_squared = v["constraint_chi_squared"](k)


def _position(node, v, k):
    node.r = v["constraint_position_r"](k)
    node.phi = v["constraint_position_phi"](k)
    node.z = v["constraint_position_z"](k)
    node.rho_tor_norm = v["constraint_position_rho_tor_norm"](k)
    node.psi = flip(v["constraint_position_psi"](k))  # COCOS


def _point_constraint(node, v, k):
    node.position_measured.r = v["constraint_point_measured_r"](k)
    node.position_measured.z = v["constraint_point_measured_z"](k)
    node.source = v["constraint_source"]
    node.time_measurement = v["constraint_time_measurement"]
    node.exact = v["constraint_exact"]
    node.weight = v["constraint_weight"](k)
    node.position_reconstructed.r = v["constraint_point_reconstructed_r"](k)
    node.position_reconstructed.z = v["constraint_point_reconstructed_z"](k)
    # Units went m -> m^-2, which is a redefinition and not a rescale: the map
    # declares it unmappable, so there is no factor to apply and the DD 3
    # number is written unchanged. The two fixtures therefore agree here
    # numerically while disagreeing about what the number means -- which is
    # exactly what "unmappable" looks like from the outside, and why
    # play_eq_mw_convert.f90 expects the middleware to refuse rather than to
    # reproduce this value.
    node.chi_squared_r = v["constraint_chi_squared_r"](k)
    node.chi_squared_z = v["constraint_chi_squared_z"](k)


def _constraints(ts, v):
    c = ts.constraints

    _constraint(
        c.b_field_tor_vacuum_r, v, 0,
        v["b_field_tor_vacuum_r_measured"], v["b_field_tor_vacuum_r_reconstructed"],
    )
    # COCOS on both measured and reconstructed.
    _constraint(c.ip, v, 0, flip(v["ip_measured"]), flip(v["ip_reconstructed"]))
    _constraint(
        c.diamagnetic_flux, v, 0,
        v["diamagnetic_flux_measured"], v["diamagnetic_flux_reconstructed"],
    )

    # `bpol_probe` renamed to `b_field_pol_probe`, `mse_polarisation_angle` to
    # `mse_polarization_angle`. flux_loop and pf_current take the COCOS flip.
    simple = (
        (c.b_field_pol_probe, "b_field_pol_probe", False),
        (c.faraday_angle, "faraday_angle", False),
        (c.mse_polarization_angle, "mse_polarization_angle", False),
        (c.flux_loop, "flux_loop", True),
        (c.n_e_line, "n_e_line", False),
        (c.pf_current, "pf_current", True),
        (c.pf_passive_current, "pf_passive_current", False),
    )
    for aos, key, cocos in simple:
        aos.resize(V.NCONSTR)
        for k, node in enumerate(aos):
            m = v[f"{key}_measured"](k)
            r = v[f"{key}_reconstructed"](k)
            _constraint(node, v, k, flip(m) if cocos else m, flip(r) if cocos else r)

    # Positioned constraints. `j_tor` is `j_phi` here, and `j_parallel` is new
    # in DD 4. Only position/psi flips; the measurements themselves are not in
    # the map's <cocos> list.
    positioned = (
        (c.n_e, "n_e"),
        (c.pressure, "pressure"),
        (c.pressure_rotational, "pressure_rotational"),
        (c.q, "q"),
        (c.j_phi, "j_phi"),
        (c.j_parallel, "j_parallel"),
    )
    for aos, key in positioned:
        aos.resize(V.NCONSTR)
        for k, node in enumerate(aos):
            _constraint(node, v, k, v[f"{key}_measured"](k), v[f"{key}_reconstructed"](k))
            _position(node.position, v, k)

    c.iron_core_segment.resize(V.NCONSTR)
    for k, seg in enumerate(c.iron_core_segment):
        _constraint(
            seg.magnetization_r, v, k,
            v["magnetization_r_measured"](k), v["magnetization_r_reconstructed"](k),
        )
        _constraint(
            seg.magnetization_z, v, k,
            v["magnetization_z_measured"](k), v["magnetization_z_reconstructed"](k),
        )

    c.x_point.resize(V.NXPT)
    for k, node in enumerate(c.x_point):
        _point_constraint(node, v, k)
    c.strike_point.resize(V.NSTRIKE)
    for k, node in enumerate(c.strike_point):
        _point_constraint(node, v, k)

    # New in DD 4: goodness-of-fit summary for the reconstruction above.
    c.chi_squared_reduced = v["constraints_chi_squared_reduced"]
    c.freedom_degrees_n = v["constraints_freedom_degrees_n"]
    c.constraints_n = v["constraints_n"]


# ---------------------------------------------------------- global_quantities


def _global_quantities(ts, v):
    g = ts.global_quantities
    g.beta_pol = v["beta_pol"]
    g.beta_tor = v["beta_tor"]
    g.beta_tor_norm = v["beta_tor_norm"]  # rule rename-beta-normal
    g.ip = flip(v["ip"])  # COCOS
    g.li_3 = v["li_3"]
    g.volume = v["volume"]
    g.area = v["area"]
    g.surface = v["surface"]
    g.length_pol = v["length_pol"]
    # rule split-psi-axis: one DD 3 path feeds both DD 4 spellings, and the
    # map flips both. psi_axis is obsolescent in DD 4 but still present, so
    # leaving it empty would be a hole in a fixture that claims to fill
    # everything.
    g.psi_axis = flip(v["psi_axis"])  # COCOS
    g.psi_magnetic_axis = flip(v["psi_axis"])  # COCOS
    g.psi_boundary = flip(v["psi_boundary"])  # COCOS
    g.rho_tor_boundary = v["rho_tor_boundary"]  # DD 4 only

    g.magnetic_axis.r = v["magnetic_axis_r"]
    g.magnetic_axis.z = v["magnetic_axis_z"]
    # rule fold-axis-bphi: DD 3's b_tor and b_field_tor collapse here.
    g.magnetic_axis.b_field_phi = v["b_field_phi_axis"]

    g.current_centre.r = v["current_centre_r"]
    g.current_centre.z = v["current_centre_z"]
    g.current_centre.velocity_z = v["current_centre_velocity_z"]
    g.q_axis = v["q_axis"]
    g.q_95 = v["q_95"]
    g.q_min.value = v["q_min_value"]
    g.q_min.rho_tor_norm = v["q_min_rho_tor_norm"]
    g.q_min.psi_norm = v["q_min_psi_norm"]  # DD 4 only
    g.q_min.psi = flip(v["q_min_psi"])  # DD 4 only, COCOS
    # rule fold-energy-mhd: DD 3's w_mhd collapses here.
    g.energy_mhd = v["energy_mhd"]
    g.psi_external_average = flip(v["psi_external_average"])  # COCOS
    g.v_external = flip(v["v_external"])  # COCOS
    g.plasma_inductance = v["plasma_inductance"]
    g.plasma_resistance = v["plasma_resistance"]


# ---------------------------------------------------------------- profiles_1d


def _profiles_1d(ts, v):
    p = ts.profiles_1d
    p.psi = flip(v["p1d_psi"])  # COCOS
    p.psi_norm = v["p1d_psi_norm"]  # DD 4 only; a ratio, so no flip
    p.phi = v["p1d_phi"]
    p.pressure = v["p1d_pressure"]
    p.f = v["p1d_f"]
    p.dpressure_dpsi = flip(v["p1d_dpressure_dpsi"])  # COCOS
    p.f_df_dpsi = flip(v["p1d_f_df_dpsi"])  # COCOS
    p.j_phi = flip(v["p1d_j_phi"])  # rule fold-p1d-j + COCOS
    p.j_parallel = flip(v["p1d_j_parallel"])  # COCOS
    p.q = v["p1d_q"]
    p.magnetic_shear = v["p1d_magnetic_shear"]
    p.r_inboard = v["p1d_r_inboard"]
    p.r_outboard = v["p1d_r_outboard"]
    p.rho_tor = v["p1d_rho_tor"]
    p.rho_tor_norm = v["p1d_rho_tor_norm"]
    p.dpsi_drho_tor = flip(v["p1d_dpsi_drho_tor"])  # COCOS
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
    p.dvolume_dpsi = flip(v["p1d_dvolume_dpsi"])  # COCOS
    p.dvolume_drho_tor = v["p1d_dvolume_drho_tor"]
    p.area = v["p1d_area"]
    p.darea_dpsi = flip(v["p1d_darea_dpsi"])  # COCOS
    p.darea_drho_tor = v["p1d_darea_drho_tor"]
    p.surface = v["p1d_surface"]
    p.trapped_fraction = v["p1d_trapped_fraction"]
    for n in range(1, 10):
        setattr(p, f"gm{n}", v[f"p1d_gm{n}"])
    # rules fold-p1d-baverage / -bmin / -bmax: DD 3's b_average, b_min and
    # b_max collapse into these.
    p.b_field_average = v["p1d_b_field_average"]
    p.b_field_min = v["p1d_b_field_min"]
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
    p.psi = flip(v["p2d_psi"])  # COCOS
    p.theta = v["p2d_theta"]
    p.phi = v["p2d_phi"]
    p.j_phi = flip(v["p2d_j_phi"])  # rule fold-p2d-j + COCOS
    p.j_parallel = flip(v["p2d_j_parallel"])  # COCOS
    # rules fold-p2d-br / -bz / -bphi: DD 3's b_r/b_field_r, b_z/b_field_z and
    # b_tor/b_field_tor each collapse to one path. None is in the <cocos> list.
    p.b_field_r = v["p2d_b_field_r"]
    p.b_field_phi = v["p2d_b_field_phi"]
    p.b_field_z = v["p2d_b_field_z"]


# ----------------------------------------------------------------------- ggd


def _ggd(ts, v):
    # DD 4 has no per-slice grid copy (rule drop-timeslice-ggd-grid); the grid
    # lives in grids_ggd and is referenced through grid_index below.
    ts.ggd.resize(V.NGGD_GRID)
    for gd in ts.ggd:
        quantities = (
            (gd.r, "ggd_r", 5.0, False),
            (gd.z, "ggd_z", 6.0, False),
            (gd.psi, "ggd_psi", 7.0, True),  # COCOS
            (gd.phi, "ggd_phi", 8.0, False),
            (gd.theta, "ggd_theta", 9.0, False),
            (gd.j_phi, "ggd_j_phi", 10.0, False),  # rule fold-ggd-j
            (gd.j_parallel, "ggd_j_parallel", 11.0, False),
            (gd.b_field_r, "ggd_b_field_r", 12.0, False),
            (gd.b_field_z, "ggd_b_field_z", 13.0, False),
            (gd.b_field_phi, "ggd_b_field_phi", 14.0, False),  # rule fold-ggd-bfield
        )
        for aos, key, coef_base, cocos in quantities:
            aos.resize(V.NGGD_SUBSET)
            for s, node in enumerate(aos):
                node.grid_index = v["ggd_grid_index"](s)
                node.grid_subset_index = v["ggd_grid_subset_index"](s)
                values = v[key](s)
                node.values = flip(values) if cocos else values
                # coefficients are interpolation weights, not the quantity, so
                # the map does not flip them and neither does this.
                node.coefficients = v["ggd_coefficients"](s, coef_base)


# --------------------------------------------------------- coordinate_system


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
    # DD 3's twelve explicit g_ij components have no DD 4 counterpart; the
    # tensors above carry the same information and are written identically on
    # both sides.


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
    """Fill a DD 4.1.1 `equilibrium` IDS in place."""
    _ids_properties(eq)
    eq.vacuum_toroidal_field.r0 = V.R0
    # b0 is not in the map's <cocos> list: the toroidal field direction is
    # unchanged between COCOS 11 and 17.
    eq.vacuum_toroidal_field.b0 = V.B0
    eq.time = V.TIME
    _grids_ggd(eq)

    eq.time_slice.resize(V.NTIME)
    for i, ts in enumerate(eq.time_slice):
        v = V.slice_values(i)
        ts.time = v["time"]
        _boundary(ts, v)
        _contour_tree(ts, v)
        _constraints(ts, v)
        _global_quantities(ts, v)
        _profiles_1d(ts, v)
        _profiles_2d(ts, v)
        _ggd(ts, v)
        _coordinate_system(ts, v)
        ts.convergence.iterations_n = v["convergence_iterations_n"]
        _fill_identifier(
            ts.convergence.grad_shafranov_deviation_expression, V.ID_GS_DEVIATION
        )
        ts.convergence.grad_shafranov_deviation_value = v[
            "convergence_gs_deviation_value"
        ]
        # DD 4 only.
        _fill_identifier(ts.convergence.result, V.ID_CONVERGENCE_RESULT)

    _code(eq)
