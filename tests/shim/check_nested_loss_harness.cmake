# Exercise F5.1's public harness from a literal format-1 report, without a
# shim or pulse. The report is independent of the parser's expected set.
cmake_minimum_required( VERSION 3.16 )
set( _expected_cases 22 )
set( _cases 0 )
set( _work "${CMAKE_CURRENT_BINARY_DIR}/nested-loss-self-test" )
file( MAKE_DIRECTORY "${_work}/fixture" "${_work}/logs" )
file( WRITE "${_work}/fixture/value" "original" )
set( _report [=[# imas-mvdd loss log format 1
# written synthetic
# process 1
# hli-dd-version 4.1.1
uri	ids	stored-dd	hli-dd	operation	fidelity	path
pulse	equilibrium	3.39.0	4.1.1	read	UNMAPPABLE	grids_ggd/grid/space/coordinates_type
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/boundary/rho_tor
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/boundary/phi
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/boundary/phi_poloidal_current
pulse	equilibrium	3.39.0	4.1.1	read	UNMAPPABLE	time_slice/contour_tree/node
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/contour_tree/edges
pulse	equilibrium	3.39.0	4.1.1	read	UNMAPPABLE	time_slice/constraints/j_parallel
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/constraints/chi_squared_reduced
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/constraints/freedom_degrees_n
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/constraints/constraints_n
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/global_quantities/rho_tor_boundary
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/global_quantities/q_min/psi_norm
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/global_quantities/q_min/psi
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/profiles_1d/psi_norm
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/convergence/result/name
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/convergence/result/index
pulse	equilibrium	3.39.0	4.1.1	read	LOSSY	time_slice/convergence/result/description
]=] )

function( check_case name report command expected_diagnostic )
  math( EXPR _next_case "${_cases} + 1" )
  set( _cases ${_next_case} PARENT_SCOPE )
  file( WRITE "${_work}/logs/imas-mvdd-loss-synthetic.txt" "${report}" )
  execute_process(
    COMMAND "${CMAKE_COMMAND}"
      -D "FIXTURE_ROOT=${_work}/fixture"
      -D "LOSS_LOG_DIR=${_work}/logs"
      -D "COMMAND_TO_RUN=${command}"
      -P "${CMAKE_CURRENT_LIST_DIR}/check_nested_loss_log.cmake"
    RESULT_VARIABLE _result
    OUTPUT_VARIABLE _output ERROR_VARIABLE _output
  )
  if( expected_diagnostic STREQUAL "" )
    if( NOT _result EQUAL 0 )
      message( FATAL_ERROR "LOSS-HARNESS-FAILURE: ${name}: ${_output}" )
    endif()
  elseif( _result EQUAL 0 OR NOT _output MATCHES "${expected_diagnostic}" )
    message( FATAL_ERROR "LOSS-HARNESS-FAILURE: ${name}: expected ${expected_diagnostic}, got ${_result}: ${_output}" )
  endif()
endfunction()

set( _clean_command "${CMAKE_COMMAND};-E;true" )
check_case( valid "${_report}" "${_clean_command}" "" )

# Set equality accepts duplicates/order changes, rejects omissions and extras.
set( _one_row "pulse\tequilibrium\t3.39.0\t4.1.1\tread\tLOSSY\ttime_slice/boundary/phi\n" )
check_case( duplicate "${_report}${_one_row}" "${_clean_command}" "" )
string( REPLACE "${_one_row}" "" _missing "${_report}" )
check_case( missing "${_missing}" "${_clean_command}" "set differs" )
set( _extra "pulse\tequilibrium\t3.39.0\t4.1.1\tread\tLOSSY\tunexpected\n" )
check_case( extra "${_report}${_extra}" "${_clean_command}" "set differs" )
string( REPLACE "read\tLOSSY" "write\tLOSSY" _wrong_operation "${_report}" )
check_case( operation "${_wrong_operation}" "${_clean_command}" "set differs" )
string( REPLACE "read\tLOSSY" "read\tUNMAPPABLE" _wrong_fidelity "${_report}" )
check_case( fidelity "${_wrong_fidelity}" "${_clean_command}" "set differs" )

string( REPLACE "format 1" "format 2" _bad_marker "${_report}" )
check_case( marker "${_bad_marker}" "${_clean_command}" "unexpected format marker" )
string( REPLACE "operation\tfidelity\tpath" "operation\tpath\tfidelity" _bad_header "${_report}" )
check_case( header "${_bad_header}" "${_clean_command}" "unexpected column header" )
string( REPLACE "# process 1\n" "" _shifted_header "${_report}" )
check_case( header_position "${_shifted_header}" "${_clean_command}" "unexpected column header" )
check_case( truncated "# imas-mvdd loss log format 1\n" "${_clean_command}" "truncated preamble/header" )
check_case( few_columns "${_report}read\tLOSSY\tpath\n" "${_clean_command}" "expected 7" )
check_case( many_columns "${_report}uri\tids\tstored\thli\tread\tLOSSY\tpath\textra\n" "${_clean_command}" "expected 7" )
check_case( blank_row "${_report}\n" "${_clean_command}" "expected 7" )
string( REPLACE "pulse\t" "pulse;parameter\t" _semicolon_uri "${_report}" )
check_case( semicolon_uri "${_semicolon_uri}" "${_clean_command}" "" )

foreach( _container x_point strike_point )
  foreach( _coordinate r z )
    set( _defect "pulse\tequilibrium\t3.39.0\t4.1.1\tread\tUNMAPPABLE\ttime_slice/constraints/${_container}/chi_squared_${_coordinate}\n" )
    check_case( "redefinition_${_container}_${_coordinate}"
      "${_report}${_defect}" "${_clean_command}" "LOSS-LOG-REDEFINITION-FAILURE" )
  endforeach()
endforeach()

# A valid report and reassuring stdout cannot hide a later process failure.
file( WRITE "${_work}/fail.cmake"
  "execute_process(COMMAND \"${CMAKE_COMMAND}\" -E echo \"partial read with refused paths\")\nmessage(FATAL_ERROR \"deliberate failure\")\n" )
check_case( failed_program "${_report}" "${CMAKE_COMMAND};-P;${_work}/fail.cmake" "command exited with status" )
file( WRITE "${_work}/mutate.cmake" "file(WRITE \"${_work}/fixture/value\" \"changed\")\n" )
check_case( modified_fixture "${_report}" "${CMAKE_COMMAND};-P;${_work}/mutate.cmake" "read modified" )

file( WRITE "${_work}/logs/imas-mvdd-loss-second.txt" "${_report}" )
check_case( two_files "${_report}" "${_clean_command}" "expected exactly one loss file" )
file( REMOVE "${_work}/logs/imas-mvdd-loss-second.txt" )
check_case( no_file "${_report}"
  "${CMAKE_COMMAND};-E;rm;${_work}/logs/imas-mvdd-loss-synthetic.txt"
  "expected exactly one loss file" )
file( REMOVE_RECURSE "${_work}" )
if( NOT _cases EQUAL _expected_cases )
  message( FATAL_ERROR "LOSS-HARNESS-FAILURE: ran ${_cases} cases, expected ${_expected_cases}" )
endif()
message( STATUS "cpp-test-shim-loss-log-harness: ${_cases}/${_expected_cases} checks passed" )
