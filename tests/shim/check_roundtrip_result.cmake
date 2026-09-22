# The paired round-trip fixture owns the executable runs; each named CTest
# case verifies the marker for its own control.
if( NOT DEFINED RESULT_FILE OR NOT EXISTS "${RESULT_FILE}" )
  message( FATAL_ERROR "ROUNDTRIP-FAILURE: paired control did not report success" )
endif()
