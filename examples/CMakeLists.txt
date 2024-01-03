include(ALExampleUtilities)

# Sources
################################################################################

set( TESTS
  test_core_profiles_get
  test_core_profiles_getSlice
  test_core_profiles_put
  test_core_profiles_putSlice
  test_core_profiles_serialize
  test_core_sources_get
  test_core_sources_put
  test_core_sources_putSlice
  test_creation_date_plugin
  test_debug_plugin
  test_distributions_validate
  test_ids_is_defined
  test_magnetics_get
  test_magnetics_memory
  test_magnetics_put
  test_parameter_plugin
  test_partial_gt_plugin
  test_patch_reader_plugin
  test_pf_active_get
  test_pf_active_getSlice
  test_pf_active_put
  test_pf_active_putSlice
  test_pulse_create
  test_version
)
# Report an error when a .cpp source file exists without corresponding test:
error_on_missing_tests( "cpp" "${TESTS}" )

# Environment variables
################################################################################

set( TEST_ENVIRONMENT "" )
if( AL_BACKEND_MDSPLUS )
  # Use MDSPLUS backend for testing
  get_target_property( MDSPLUS_MODEL_DIR al-mdsplus-model BINARY_DIR )
  set( TEST_ENVIRONMENT "IMAS_AL_DEFAULT_BACKEND=12;ids_path=${MDSPLUS_MODEL_DIR}" )
  message( "Using MDSPLUS backend for C++ examples" )
elseif( AL_BACKEND_HDF5 )
  # If MDSPLUS is not available and HDF5 is, use that for testing
  set( TEST_ENVIRONMENT "IMAS_AL_DEFAULT_BACKEND=13" )
  message( "Using HDF5 backend for C++ examples" )
else()
  message( "Skipping tests that require persistent storage" )
endif()

# Targets
################################################################################

add_custom_target( example-cpp-all )

foreach( TEST IN LISTS TESTS )
  set( TEST_NAME "example-cpp-${TEST}")
  add_executable( ${TEST_NAME} ${TEST}.cpp )
  target_link_libraries( ${TEST_NAME} al-cpp )
  add_dependencies( example-cpp-all ${TEST_NAME} )

  # Disable some tests if no persistent backends available
  set( DISABLED OFF )
  if( NOT AL_BACKEND_MDSPLUS AND NOT AL_BACKEND_HDF5 AND TEST_NAME MATCHES "get|put|create" )
    set( DISABLED ON )
  endif()

  # Execute the test without plugins
  if( NOT TEST_NAME MATCHES _plugin )
    add_test( NAME ${TEST_NAME} COMMAND ${TEST_NAME} )
    set_al_example_properties( ${TEST_NAME} ${DISABLED} OFF "${TEST_ENVIRONMENT}" )
  endif()

  # Execute the test with plugins
  if( AL_PLUGINS )
    add_test( NAME ${TEST_NAME}-with-plugins COMMAND ${TEST_NAME} )
    set_al_example_properties( ${TEST_NAME}-with-plugins ${DISABLED} ON "${TEST_ENVIRONMENT}" )
  endif()
endforeach()

# FIXME: Some better thought should be given on data entries! Ideally every test
# uses a separate data entry (except for the put/get coupled tests) which would
# also allow the tests to run in parallel.
#
# These plugin tests are dependent on a data entry created by test_magnetics_put
# However, they also overwrite that data entry, so test_magnetics_get MUST run
# before it (otherwise it will segfault on missing plugins)
if( AL_PLUGINS )
  set_tests_properties(
    example-cpp-test_creation_date_plugin-with-plugins
    example-cpp-test_debug_plugin-with-plugins
    PROPERTIES FIXTURES_REQUIRED "example-cpp-test_magnetics_;example-cpp-test_magnetics_get"
  )
endif()
set_tests_properties( example-cpp-test_magnetics_get
  PROPERTIES FIXTURES_SETUP example-cpp-test_magnetics_get
)
