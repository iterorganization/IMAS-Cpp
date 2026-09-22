# Run the F6.3 torn-write program and prove its refusal diagnostic reached
# standard output, not standard error (docs/SHIM_SUITE_CONVENTION.md S5.6).
#
# Unlike verify_fixture_unchanged.cmake, this wraps a write scenario against a
# private fixture copy that is *expected* to change, so it does not assert the
# fixture stayed untouched -- that is the whole point of a torn write.
if( NOT DEFINED COMMAND_TO_RUN OR NOT DEFINED EXPECTED_STDOUT_SUBSTRING )
  message( FATAL_ERROR "SCENARIO-FAILURE: COMMAND_TO_RUN and EXPECTED_STDOUT_SUBSTRING are required" )
endif()

execute_process(
  COMMAND ${COMMAND_TO_RUN}
  RESULT_VARIABLE _al_cpp_shim_result
  OUTPUT_VARIABLE _al_cpp_shim_stdout
  ERROR_VARIABLE _al_cpp_shim_stderr
)

if( DEFINED LOSS_LOG_DIR AND NOT IS_DIRECTORY "${LOSS_LOG_DIR}" )
  message( SEND_ERROR "SCENARIO-FAILURE: private loss-log directory is missing: ${LOSS_LOG_DIR}" )
endif()

if( NOT _al_cpp_shim_result EQUAL 0 )
  message( FATAL_ERROR
    "SCENARIO-FAILURE: command exited with status ${_al_cpp_shim_result}: ${COMMAND_TO_RUN}\n${_al_cpp_shim_stdout}${_al_cpp_shim_stderr}" )
endif()

# The program's exit status is checked above, before this diagnostic is
# trusted -- matching text from a program that failed for an unrelated reason
# must not satisfy the assertion.
string( FIND "${_al_cpp_shim_stdout}" "${EXPECTED_STDOUT_SUBSTRING}" _al_cpp_shim_stdout_at )
if( _al_cpp_shim_stdout_at EQUAL -1 )
  message( FATAL_ERROR
    "SCENARIO-FAILURE: program standard output did not contain '${EXPECTED_STDOUT_SUBSTRING}'" )
endif()

# A match here would mean the refused path was named by an error rather than
# by the traversal that tolerated it -- see F6.3 in
# docs/SHIM_SUITE_CONVENTION.md.
string( FIND "${_al_cpp_shim_stderr}" "${EXPECTED_STDOUT_SUBSTRING}" _al_cpp_shim_stderr_at )
if( NOT _al_cpp_shim_stderr_at EQUAL -1 )
  message( FATAL_ERROR
    "SCENARIO-FAILURE: the refused path also appeared on standard error" )
endif()
