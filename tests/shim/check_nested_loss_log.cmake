# F5.1 / issue #20: inspect the public loss file after a full older-DD read.
# This pins a refusal decision, not the absence of a mapping. If the shim
# starts returning empty arrays of structures instead of refusing their opens,
# rows can disappear on an improvement: suspect that decision changed before
# assuming a mapping regressed. Check DD data_type before comparing siblings.
cmake_minimum_required( VERSION 3.16 )
if( NOT DEFINED LOSS_LOG_DIR OR NOT DEFINED FIXTURE_ROOT OR NOT DEFINED COMMAND_TO_RUN )
  message( FATAL_ERROR "LOSS-LOG-FAILURE: LOSS_LOG_DIR, FIXTURE_ROOT and COMMAND_TO_RUN are required" )
endif()

# Reuse the content-digest wrapper without its optional empty-log assertion.
# Require the program's exit status, never a PASS_REGULAR_EXPRESSION: a line
# printed before a later abort cannot make this harness pass.
execute_process(
  COMMAND "${CMAKE_COMMAND}"
    -D "FIXTURE_ROOT=${FIXTURE_ROOT}"
    -D "COMMAND_TO_RUN=${COMMAND_TO_RUN}"
    -P "${CMAKE_CURRENT_LIST_DIR}/verify_fixture_unchanged.cmake"
  RESULT_VARIABLE _result
)
if( NOT _result EQUAL 0 )
  message( FATAL_ERROR "LOSS-LOG-FAILURE: read/fixture verification failed (${_result})" )
endif()

file( GLOB _logs "${LOSS_LOG_DIR}/imas-mvdd-loss-*.txt" )
list( LENGTH _logs _count )
if( NOT _count EQUAL 1 )
  message( FATAL_ERROR "LOSS-LOG-FAILURE: expected exactly one loss file, found ${_count}" )
endif()
list( GET _logs 0 _log )
file( READ "${_log}" _contents )
# Protect literal semicolons (e.g. in a URI) from CMake's list syntax.
string( REPLACE ";" "\\;" _contents "${_contents}" )
# A final newline terminates the last row; an interior blank row is invalid.
string( REGEX REPLACE "\n$" "" _contents "${_contents}" )
string( REPLACE "\n" ";" _lines "${_contents}" )
list( LENGTH _lines _line_count )
if( _line_count LESS 5 )
  message( FATAL_ERROR "LOSS-LOG-FAILURE: truncated preamble/header" )
endif()
list( GET _lines 0 _marker )
if( NOT _marker STREQUAL "# imas-mvdd loss log format 1" )
  message( FATAL_ERROR "LOSS-LOG-FAILURE: unexpected format marker: ${_marker}" )
endif()
string( ASCII 9 _tab )
# Line five is data-shaped. Locate it by position, never by stripping comments.
list( GET _lines 4 _header )
if( NOT _header STREQUAL "uri${_tab}ids${_tab}stored-dd${_tab}hli-dd${_tab}operation${_tab}fidelity${_tab}path" )
  message( FATAL_ERROR "LOSS-LOG-FAILURE: unexpected column header: ${_header}" )
endif()
set( _actual )
set( _line_index 5 )
while( _line_index LESS _line_count )
  list( GET _lines ${_line_index} _row )
  math( EXPR _line_index "${_line_index} + 1" )
  string( REPLACE ";" "\\;" _row "${_row}" )
  string( REPLACE "${_tab}" ";" _columns "${_row}" )
  list( LENGTH _columns _column_count )
  if( NOT _column_count EQUAL 7 )
    message( FATAL_ERROR "LOSS-LOG-FAILURE: row has ${_column_count} columns, expected 7: ${_row}" )
  endif()
  list( GET _columns 4 _operation )
  list( GET _columns 5 _fidelity )
  list( GET _columns 6 _path )
  list( APPEND _actual "${_operation}${_tab}${_fidelity}${_tab}${_path}" )
endwhile()

# Hand-transcribed from the map's right_only reverse-lossy rules, expanded
# at DD 4.1.1 leaves (shim_rule_table.h rightOnlyRules; convention S5.5).
set( _expected
  "read${_tab}LOSSY${_tab}time_slice/boundary/rho_tor"
  "read${_tab}LOSSY${_tab}time_slice/boundary/phi"
  "read${_tab}LOSSY${_tab}time_slice/boundary/phi_poloidal_current"
  "read${_tab}LOSSY${_tab}time_slice/contour_tree/edges"
  "read${_tab}LOSSY${_tab}time_slice/constraints/chi_squared_reduced"
  "read${_tab}LOSSY${_tab}time_slice/constraints/freedom_degrees_n"
  "read${_tab}LOSSY${_tab}time_slice/constraints/constraints_n"
  "read${_tab}LOSSY${_tab}time_slice/global_quantities/rho_tor_boundary"
  "read${_tab}LOSSY${_tab}time_slice/global_quantities/q_min/psi_norm"
  "read${_tab}LOSSY${_tab}time_slice/global_quantities/q_min/psi"
  "read${_tab}LOSSY${_tab}time_slice/profiles_1d/psi_norm"
  "read${_tab}LOSSY${_tab}time_slice/convergence/result/name"
  "read${_tab}LOSSY${_tab}time_slice/convergence/result/index"
  "read${_tab}LOSSY${_tab}time_slice/convergence/result/description"
  # retype-coordinates-type: int_1d became struct_array. Unlike right_only
  # leaves, opening that container cannot reshape the stored integer array;
  # the seam honestly refuses it as UNMAPPABLE (contract 8.2, issue #18).
  "read${_tab}UNMAPPABLE${_tab}grids_ggd/grid/space/coordinates_type"
  # new-constraints-j-parallel: a DD-4-only struct_array, with no stored
  # container to open. UNMAPPABLE describes this open refusal; no conversion
  # ran to earn the map's reverse LOSSY. j_phi is a different quantity.
  "read${_tab}UNMAPPABLE${_tab}time_slice/constraints/j_parallel"
  # new-contour-tree: node is struct_array, so its open is refused as
  # UNMAPPABLE. Its sibling edges is a leaf under the SAME right_only rule
  # and earns reverse LOSSY. DD shape, not a different map, explains this.
  "read${_tab}UNMAPPABLE${_tab}time_slice/contour_tree/node"
)

# Contract-forbidden historical redefinition refusals (issue #19/F4.4).
# They must disappear for this test to pass, never become expected rows.
set( _known_defect
  "read${_tab}UNMAPPABLE${_tab}time_slice/constraints/x_point/chi_squared_r"
  "read${_tab}UNMAPPABLE${_tab}time_slice/constraints/x_point/chi_squared_z"
  "read${_tab}UNMAPPABLE${_tab}time_slice/constraints/strike_point/chi_squared_r"
  "read${_tab}UNMAPPABLE${_tab}time_slice/constraints/strike_point/chi_squared_z"
)
foreach( _row IN LISTS _known_defect )
  if( "${_row}" IN_LIST _actual )
    list( REMOVE_ITEM _actual "${_row}" )
    message( SEND_ERROR "LOSS-LOG-REDEFINITION-FAILURE: unit-redefined path must be served (issue #19): ${_row}" )
  endif()
endforeach()

# Repeated slice/index visits may record the same path: compare sets, not
# row order or multiplicity, while still validating EVERY row's columns.
list( REMOVE_DUPLICATES _actual )
list( SORT _actual )
list( SORT _expected )
if( NOT _actual STREQUAL _expected )
  list( JOIN _expected "\n" _expected_display )
  list( JOIN _actual "\n" _actual_display )
  message( FATAL_ERROR "LOSS-LOG-FAILURE: operation-fidelity-path set differs\nexpected:\n${_expected_display}\nactual:\n${_actual_display}" )
endif()
