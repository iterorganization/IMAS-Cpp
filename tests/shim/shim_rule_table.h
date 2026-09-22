// Hand-authored conversion-rule tables for the shim conformance suite.
//
// Transcribed and re-verified against IMAS-Multiversion-DD-Loader's
// docs/3.39.0--4.1.1.xml on 2026-09-15.  Its externally reachable copy has
// unresolved error-model-3to4.xml and naming-3to4.xml includes; the latter
// holds common cross-IDS renames.  Generating this table by following only
// resolvable includes would silently omit that rename family, so this remains
// a hand-authored, compile-time table.
//
// Audit disagreements retained here: the map contains 30 <cocos><flip>
// entries, while the fixture README and the ticket say 32.  The two extra
// fixture-only negations are contour_tree/node/psi and
// constraints/j_parallel/position/psi; both are inside right-only DD 4
// structures with no DD 3 source, so they are intentionally represented by
// the right-only table rather than invented COCOS map rules.  The map count
// wins.  cocos-p1d-j-phi and cocos-p2d-j-phi also use their fold map rules,
// recorded in their individual citations below.
//
// The fixture/contract still records four chi-squared unit redefinitions, but
// the current map says its matching <redefine> globs were removed after
// review: these paths now fall through to identical and the shim leaves their
// values unchanged.  Keep the four entries as the cited historical/unit
// record, but the map's current Same verdict wins over a refusal.
#pragma once

#include "shim_comparator.h"

#include <array>
#include <cstddef>

namespace ShimRuleTable {

enum class Kind { Identical, Renamed, Moved, Merged, Split, Cocos, RightOnly, Retyped, Redefined };

struct KindDefinition {
  const char* name;
  ShimTest::Verdict expected;
};

// The one kind-to-verdict mapping.  Callers must never state an expected
// verdict at a rule check site.
inline constexpr std::array<KindDefinition, 9> kKinds{{
    {"identical", ShimTest::Verdict::Same}, {"renamed", ShimTest::Verdict::Same},
    {"moved", ShimTest::Verdict::Same}, {"merged", ShimTest::Verdict::Same},
    {"split", ShimTest::Verdict::Same}, {"cocos", ShimTest::Verdict::Same},
    {"right_only", ShimTest::Verdict::OnlyOracle},
    {"retyped", ShimTest::Verdict::OnlyOracle}, {"redefined", ShimTest::Verdict::Same},
}};

struct Rule {
  const char* id;
  Kind kind;
  const char* hliPath;
  const char* citation;
};

constexpr const KindDefinition& definition(Kind kind) {
  return kKinds[static_cast<std::size_t>(kind)];
}

constexpr ShimTest::Verdict expectedVerdict(Kind kind) { return definition(kind).expected; }
constexpr const char* kindName(Kind kind) { return definition(kind).name; }

inline constexpr std::array<Rule, 23> kStructuralRules{{
    {"identical-vacuum-r0", Kind::Identical, "vacuum_toroidal_field/r0",
     "map <default rel=\"identical\"/>; coverage vacuum_toroidal_field exact"},
    {"identical-time", Kind::Identical, "time",
     "map <default rel=\"identical\"/>; coverage time exact"},
    {"identical-beta-pol", Kind::Identical, "time_slice/global_quantities/beta_pol",
     "map <default rel=\"identical\"/>; unclaimed explicit rule"},
    {"rename-beta-normal", Kind::Renamed, "time_slice/global_quantities/beta_tor_norm",
     "map rule rename-beta-normal; fixtures README Renames global_quantities/beta_normal"},
    {"rename-bpol-probe", Kind::Renamed, "time_slice/constraints/b_field_pol_probe/measured",
     "map rule rename-bpol-probe; fixtures README Renames constraints/bpol_probe"},
    {"rename-mse-polarisation-angle", Kind::Renamed,
     "time_slice/constraints/mse_polarization_angle/measured",
     "map rule rename-mse-polarisation-angle; fixtures README Renames constraints/mse_polarisation_angle"},
    {"rename-magnetisation-r", Kind::Renamed,
     "time_slice/constraints/iron_core_segment/magnetization_r/measured",
     "map rule rename-magnetisation-r; fixtures README Renames iron_core_segment/magnetisation_r"},
    {"rename-magnetisation-z", Kind::Renamed,
     "time_slice/constraints/iron_core_segment/magnetization_z/measured",
     "map rule rename-magnetisation-z; fixtures README Renames iron_core_segment/magnetisation_z"},
    {"move-closest-wall-point", Kind::Moved, "time_slice/boundary/closest_wall_point",
     "map rule move-closest-wall-point; fixtures README Container and structure changes"},
    {"move-dr-dz-zero-point", Kind::Moved, "time_slice/boundary/dr_dz_zero_point",
     "map rule move-dr-dz-zero-point; fixtures README Container and structure changes"},
    {"move-gap", Kind::Moved, "time_slice/boundary/gap",
     "map rule move-gap; fixtures README Container and structure changes"},
    {"fold-p2d-br", Kind::Merged, "time_slice/profiles_2d/b_field_r",
     "map rule fold-p2d-br; fixtures README Folds profiles_2d/b_r+b_field_r"},
    {"fold-p2d-bz", Kind::Merged, "time_slice/profiles_2d/b_field_z",
     "map rule fold-p2d-bz; fixtures README Folds profiles_2d/b_z+b_field_z"},
    {"fold-p2d-bphi", Kind::Merged, "time_slice/profiles_2d/b_field_phi",
     "map rule fold-p2d-bphi; fixtures README Folds profiles_2d/b_tor+b_field_tor"},
    {"fold-axis-bphi", Kind::Merged,
     "time_slice/global_quantities/magnetic_axis/b_field_phi",
     "map rule fold-axis-bphi; fixtures README Folds magnetic_axis/b_tor+b_field_tor"},
    {"fold-p1d-baverage", Kind::Merged, "time_slice/profiles_1d/b_field_average",
     "map rule fold-p1d-baverage; fixtures README Folds profiles_1d/b_average+b_field_average"},
    {"fold-p1d-bmax", Kind::Merged, "time_slice/profiles_1d/b_field_max",
     "map rule fold-p1d-bmax; fixtures README Folds profiles_1d/b_max+b_field_max"},
    {"fold-p1d-bmin", Kind::Merged, "time_slice/profiles_1d/b_field_min",
     "map rule fold-p1d-bmin; fixtures README Folds profiles_1d/b_min+b_field_min"},
    {"fold-energy-mhd", Kind::Merged, "time_slice/global_quantities/energy_mhd",
     "map rule fold-energy-mhd; fixtures README Folds global_quantities/w_mhd+energy_mhd"},
    {"fold-constraints-j", Kind::Merged, "time_slice/constraints/j_phi",
     "map rule fold-constraints-j; fixtures README Renames/Folds constraints/j_tor -> j_phi"},
    {"fold-ggd-j", Kind::Merged, "time_slice/ggd/j_phi",
     "map rule fold-ggd-j; fixtures README Renames/Folds ggd/j_tor -> j_phi"},
    {"fold-ggd-bfield", Kind::Merged, "time_slice/ggd/b_field_phi",
     "map rule fold-ggd-bfield; fixtures README Renames/Folds ggd/b_field_tor -> b_field_phi"},
    {"split-psi-axis", Kind::Split,
     "time_slice/global_quantities/{psi_axis,psi_magnetic_axis}",
     "map rule split-psi-axis; fixtures README Container and structure changes global_quantities/psi_axis"},
}};

#define SHIM_COCOS_RULE(id, path) \
  Rule{id, Kind::Cocos, path, "map <cocos> flip path=\"" path "\"; fixtures README COCOS 11 -> 17"}
inline constexpr std::array<Rule, 30> kCocosRules{{
    SHIM_COCOS_RULE("cocos-boundary-psi", "time_slice/boundary/psi"),
    SHIM_COCOS_RULE("cocos-flux-loop-measured", "time_slice/constraints/flux_loop/measured"),
    SHIM_COCOS_RULE("cocos-flux-loop-reconstructed", "time_slice/constraints/flux_loop/reconstructed"),
    SHIM_COCOS_RULE("cocos-ip-measured", "time_slice/constraints/ip/measured"),
    SHIM_COCOS_RULE("cocos-ip-reconstructed", "time_slice/constraints/ip/reconstructed"),
    SHIM_COCOS_RULE("cocos-j-phi-position-psi", "time_slice/constraints/j_phi/position/psi"),
    SHIM_COCOS_RULE("cocos-n-e-position-psi", "time_slice/constraints/n_e/position/psi"),
    SHIM_COCOS_RULE("cocos-pf-current-measured", "time_slice/constraints/pf_current/measured"),
    SHIM_COCOS_RULE("cocos-pf-current-reconstructed", "time_slice/constraints/pf_current/reconstructed"),
    SHIM_COCOS_RULE("cocos-pressure-position-psi", "time_slice/constraints/pressure/position/psi"),
    SHIM_COCOS_RULE("cocos-pressure-rot-position-psi", "time_slice/constraints/pressure_rotational/position/psi"),
    SHIM_COCOS_RULE("cocos-q-position-psi", "time_slice/constraints/q/position/psi"),
    SHIM_COCOS_RULE("cocos-ggd-psi-values", "time_slice/ggd/psi/values"),
    SHIM_COCOS_RULE("cocos-gq-ip", "time_slice/global_quantities/ip"),
    SHIM_COCOS_RULE("cocos-psi-axis", "time_slice/global_quantities/psi_axis"),
    SHIM_COCOS_RULE("cocos-psi-magnetic-axis", "time_slice/global_quantities/psi_magnetic_axis"),
    SHIM_COCOS_RULE("cocos-psi-boundary", "time_slice/global_quantities/psi_boundary"),
    SHIM_COCOS_RULE("cocos-psi-external-average", "time_slice/global_quantities/psi_external_average"),
    SHIM_COCOS_RULE("cocos-v-external", "time_slice/global_quantities/v_external"),
    SHIM_COCOS_RULE("cocos-p1d-darea-dpsi", "time_slice/profiles_1d/darea_dpsi"),
    SHIM_COCOS_RULE("cocos-p1d-dpressure-dpsi", "time_slice/profiles_1d/dpressure_dpsi"),
    SHIM_COCOS_RULE("cocos-p1d-dpsi-drho-tor", "time_slice/profiles_1d/dpsi_drho_tor"),
    SHIM_COCOS_RULE("cocos-p1d-dvolume-dpsi", "time_slice/profiles_1d/dvolume_dpsi"),
    SHIM_COCOS_RULE("cocos-p1d-f-df-dpsi", "time_slice/profiles_1d/f_df_dpsi"),
    SHIM_COCOS_RULE("cocos-p1d-j-parallel", "time_slice/profiles_1d/j_parallel"),
    {"cocos-p1d-j-phi", Kind::Cocos, "time_slice/profiles_1d/j_phi",
     "map <cocos> flip path=time_slice/profiles_1d/j_phi; also map rule fold-p1d-j; fixtures README COCOS 11 -> 17 and Folds"},
    SHIM_COCOS_RULE("cocos-p1d-psi", "time_slice/profiles_1d/psi"),
    SHIM_COCOS_RULE("cocos-p2d-j-parallel", "time_slice/profiles_2d/j_parallel"),
    {"cocos-p2d-j-phi", Kind::Cocos, "time_slice/profiles_2d/j_phi",
     "map <cocos> flip path=time_slice/profiles_2d/j_phi; also map rule fold-p2d-j; fixtures README COCOS 11 -> 17 and Folds"},
    SHIM_COCOS_RULE("cocos-p2d-psi", "time_slice/profiles_2d/psi"),
}};
#undef SHIM_COCOS_RULE

inline constexpr std::array<Rule, 13> kRightOnlyRules{{
    {"new-contour-tree", Kind::RightOnly, "time_slice/contour_tree",
     "map rule new-contour-tree; fixtures README One reality, not two"},
    {"new-constraints-j-parallel", Kind::RightOnly, "time_slice/constraints/j_parallel",
     "map rule new-constraints-j-parallel; 13-path subtree added in DD 3.40.0"},
    {"new-convergence-result", Kind::RightOnly, "time_slice/convergence/result",
     "map rule new-convergence-result; 2-path subtree added in DD 3.41.0"},
    {"new-boundary-rho-tor", Kind::RightOnly, "time_slice/boundary/rho_tor",
     "map rule new-boundary-rho-tor; fixtures README One reality, not two"},
    {"new-boundary-phi", Kind::RightOnly, "time_slice/boundary/phi",
     "map rule new-boundary-phi; equilibrium_v4_1_1.py New in DD 4"},
    {"new-boundary-phi-poloidal-current", Kind::RightOnly,
     "time_slice/boundary/phi_poloidal_current",
     "map rule new-boundary-phi-poloidal-current; equilibrium_v4_1_1.py New in DD 4"},
    {"new-q-min-psi", Kind::RightOnly, "time_slice/global_quantities/q_min/psi",
     "map rule new-q-min-psi; equilibrium_v4_1_1.py DD 4 only"},
    {"new-q-min-psi-norm", Kind::RightOnly, "time_slice/global_quantities/q_min/psi_norm",
     "map rule new-q-min-psi-norm; equilibrium_v4_1_1.py DD 4 only"},
    {"new-global-quantities-rho-tor-boundary", Kind::RightOnly,
     "time_slice/global_quantities/rho_tor_boundary",
     "map rule new-global-quantities-rho-tor-boundary; equilibrium_v4_1_1.py DD 4 only"},
    {"new-constraints-chi-squared-reduced", Kind::RightOnly,
     "time_slice/constraints/chi_squared_reduced",
     "map rule new-constraints-chi-squared-reduced; equilibrium_v4_1_1.py New in DD 4"},
    {"new-constraints-freedom-degrees-n", Kind::RightOnly,
     "time_slice/constraints/freedom_degrees_n",
     "map rule new-constraints-freedom-degrees-n; equilibrium_v4_1_1.py New in DD 4"},
    {"new-constraints-constraints-n", Kind::RightOnly, "time_slice/constraints/constraints_n",
     "map rule new-constraints-constraints-n; equilibrium_v4_1_1.py New in DD 4"},
    {"new-profiles-1d-psi-norm", Kind::RightOnly, "time_slice/profiles_1d/psi_norm",
     "map rule new-profiles-1d-psi-norm; equilibrium_v4_1_1.py DD 4 only"},
}};

inline constexpr std::array<Rule, 5> kRefusalRules{{
    {"retype-coordinates-type", Kind::Retyped, "grids_ggd/grid/space/coordinates_type",
     "map rule retype-coordinates-type rel=retyped shape=int_1d:struct_array; contract 8.2"},
    {"redefine-x-point-chi-sq-r", Kind::Redefined,
     "time_slice/constraints/x_point/chi_squared_r",
     "fixture/contract unit change m -> m^-2; map audit: redefine glob removed, falls through identical"},
    {"redefine-x-point-chi-sq-z", Kind::Redefined,
     "time_slice/constraints/x_point/chi_squared_z",
     "fixture/contract unit change m -> m^-2; map audit: redefine glob removed, falls through identical"},
    {"redefine-strike-pt-chi-sq-r", Kind::Redefined,
     "time_slice/constraints/strike_point/chi_squared_r",
     "fixture/contract unit change m -> m^-2; map audit: redefine glob removed, falls through identical"},
    {"redefine-strike-pt-chi-sq-z", Kind::Redefined,
     "time_slice/constraints/strike_point/chi_squared_z",
     "fixture/contract unit change m -> m^-2; map audit: redefine glob removed, falls through identical"},
}};

// Frozen reason strings, transcribed from
// docs/SHIM_INTEGRATION_CONTRACT.md S8.2 ("Path-resolution reasons"). They
// carry their citation for the same reason every Rule above does: the only
// text this suite matches against the shim's own message must be traceable to
// the agreement rather than to somebody's typing.
//
// Matched as substrings, never whole messages: S8.1 truncates a message to
// MAX_ERR_MSG_LEN in a fixed order, so a deep DD path can legitimately push
// the version pair out of it.

// S8.2: raised "on the `retyped` rule -- unconditional, even where the rule
// declares itself `exact`".
inline constexpr const char* kRetypedRefusalReason =
    "this path's container changed shape and cannot be served";
// S8.2: raised "on a unit-redefinition rule".
inline constexpr const char* kRedefinedRefusalReason =
    "this path's unit was redefined and cannot be converted";

inline constexpr const std::array<Rule, 23>& structuralRules() { return kStructuralRules; }
inline constexpr const std::array<Rule, 30>& cocosRules() { return kCocosRules; }
inline constexpr const std::array<Rule, 13>& rightOnlyRules() { return kRightOnlyRules; }
inline constexpr const std::array<Rule, 5>& refusalRules() { return kRefusalRules; }

}  // namespace ShimRuleTable
