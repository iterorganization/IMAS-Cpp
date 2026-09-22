# A write test must never run against a checked-in fixture. CTest runs this
# setup test before its dependent scenario, giving every scenario a newly
# made private copy that is safe to mutate in parallel with the others -- and
# that a failed prior run cannot have left poisoned, because the destination
# is wiped before every copy rather than reused.
if( NOT DEFINED SOURCE OR NOT DEFINED DESTINATION )
  message( FATAL_ERROR "SOURCE and DESTINATION are required" )
endif()

if( NOT IS_DIRECTORY "${SOURCE}" )
  message( FATAL_ERROR "fixture source does not exist: ${SOURCE}" )
endif()

file( REMOVE_RECURSE "${DESTINATION}" )
file( COPY "${SOURCE}/" DESTINATION "${DESTINATION}" )
