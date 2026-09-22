# Fails unless the built al-cpp library records the multiversion shim as a
# dynamic dependency.
#
# The point is not that the library links *something*, but that the shim is
# visible in an ordinary dependency listing: it is what makes "is the shim in
# the call path" answerable at a glance instead of by reading the build
# files. A build that resolved the shim's symbols out of a static archive, or
# one whose link line was bypassed, would pass every functional test while
# showing nothing here. A build directory's name is not evidence.
#
# Invoked by tests/shim/CMakeLists.txt; every -D it needs is checked below.

foreach( _var LIBRARY INSPECT_TOOL INSPECT_ARGS SHIM_LIBRARY_NAME )
  if( NOT DEFINED ${_var} )
    message( FATAL_ERROR "check_shim_linkage.cmake: -D ${_var}=... is required" )
  endif()
endforeach()

if( NOT EXISTS "${LIBRARY}" )
  message( FATAL_ERROR "No such library: ${LIBRARY}" )
endif()

execute_process(
  COMMAND ${INSPECT_TOOL} ${INSPECT_ARGS} "${LIBRARY}"
  OUTPUT_VARIABLE _dependencies
  ERROR_VARIABLE _inspect_error
  RESULT_VARIABLE _inspect_result
)
if( NOT _inspect_result EQUAL 0 )
  message( FATAL_ERROR
    "Dependency inspection failed (${INSPECT_TOOL} exited ${_inspect_result}):\n${_inspect_error}"
  )
endif()

# FIND rather than MATCHES: the name is a file name, not a regular expression.
string( FIND "${_dependencies}" "${SHIM_LIBRARY_NAME}" _shim_position )
if( _shim_position EQUAL -1 )
  message( FATAL_ERROR
    "${LIBRARY} does not depend on ${SHIM_LIBRARY_NAME}: the multiversion shim is "
    "not in the call path even though AL_USE_MULTIVERSION_SHIM is on.\n"
    "Dependencies reported by ${INSPECT_TOOL} ${INSPECT_ARGS}:\n${_dependencies}"
  )
endif()

message( STATUS "${LIBRARY} depends on ${SHIM_LIBRARY_NAME}" )
