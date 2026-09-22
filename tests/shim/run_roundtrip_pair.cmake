# Run both Family 6 controls as one CTest fixture. The named cross-DD and
# same-DD tests require this fixture, so selecting either one cannot produce a
# round-trip result without first executing its required control.
foreach( _required PROGRAM CROSS_FIXTURE CROSS_LOSS_LOG_DIR CROSS_RESULT_FILE SAME_FIXTURE SAME_LOSS_LOG_DIR SAME_RESULT_FILE )
  if( NOT DEFINED ${_required} )
    message( FATAL_ERROR "ROUNDTRIP-FAILURE: ${_required} is required" )
  endif()
endforeach()

function( al_cpp_shim_run_roundtrip fixture read_policy loss_log_dir result_file )
  execute_process(
    COMMAND "${CMAKE_COMMAND}" -E env "IMAS_MVDD_LOSS_LOG_DIR=${loss_log_dir}"
      "${PROGRAM}" "${fixture}" "${read_policy}"
    RESULT_VARIABLE _result
    OUTPUT_VARIABLE _stdout
    ERROR_VARIABLE _stderr
  )
  if( NOT _result EQUAL 0 )
    message( FATAL_ERROR
      "ROUNDTRIP-FAILURE: paired ${read_policy} run exited with ${_result}:\n${_stdout}${_stderr}" )
  endif()
  file( WRITE "${result_file}" "passed\n" )
endfunction()

al_cpp_shim_run_roundtrip( "${CROSS_FIXTURE}" partial-read-allowed
  "${CROSS_LOSS_LOG_DIR}" "${CROSS_RESULT_FILE}" )
al_cpp_shim_run_roundtrip( "${SAME_FIXTURE}" clean-read "${SAME_LOSS_LOG_DIR}"
  "${SAME_RESULT_FILE}" )
