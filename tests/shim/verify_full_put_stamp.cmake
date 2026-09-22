# Run the F6.4 full-put-stamp program and prove both its refusal
# diagnostics -- the refused stamp delete and the refused stamp write --
# reached standard output, not standard error (docs/SHIM_SUITE_CONVENTION.md
# S5.6). Generalizes verify_torn_write.cmake's single-substring check to a
# list, because F6.4 needs two distinct diagnostics from one run, not one.
#
# Like verify_torn_write.cmake, this wraps a write scenario against a private
# fixture copy that is *expected* to change, so it does not assert the
# fixture stayed untouched.
if( NOT DEFINED COMMAND_TO_RUN OR NOT DEFINED EXPECTED_STDOUT_SUBSTRINGS )
  message( FATAL_ERROR "SCENARIO-FAILURE: COMMAND_TO_RUN and EXPECTED_STDOUT_SUBSTRINGS are required" )
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

# The program's exit status is checked above, before either diagnostic is
# trusted -- matching text from a program that failed for an unrelated reason
# must not satisfy either assertion.
foreach( _al_cpp_shim_substring ${EXPECTED_STDOUT_SUBSTRINGS} )
  string( FIND "${_al_cpp_shim_stdout}" "${_al_cpp_shim_substring}" _al_cpp_shim_stdout_at )
  if( _al_cpp_shim_stdout_at EQUAL -1 )
    message( FATAL_ERROR
      "SCENARIO-FAILURE: program standard output did not contain '${_al_cpp_shim_substring}'" )
  endif()

  # A match here would mean the refused path was named by an error rather
  # than by the traversal that tolerated it -- see F6.4 in
  # docs/SHIM_SUITE_CONVENTION.md.
  string( FIND "${_al_cpp_shim_stderr}" "${_al_cpp_shim_substring}" _al_cpp_shim_stderr_at )
  if( NOT _al_cpp_shim_stderr_at EQUAL -1 )
    message( FATAL_ERROR
      "SCENARIO-FAILURE: '${_al_cpp_shim_substring}' also appeared on standard error" )
  endif()
endforeach()
