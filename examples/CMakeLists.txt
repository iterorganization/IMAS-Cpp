project( cppinterface-ex )


########################################################################################################################
# Dependencies

find_package( Blitz NO_CMAKE_PATH REQUIRED )
find_package( Blitz REQUIRED )


########################################################################################################################
# Sources

include_directories(
  ${Blitz_INCLUDE_DIRS}
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_SOURCE_DIR}/lowlevel
  ${CMAKE_SOURCE_DIR}/cppinterface/src
)


########################################################################################################################
# Targets

set( EXE_FLAG  )
set( EXE_EXT  )

if( BUILD_SHARED_LIBS )
  set( CPPHLI_LINK ${Blitz_LIBRARIES} lowlevel-shared cppinterface-shared )
else()
  set( CPPHLI_LINK ${Blitz_LIBRARIES} lowlevel-static cppinterface-static )
endif()

macro( BUILD_TEST NAME SOURCE )
  add_executable( ${NAME} ${EXE_FLAG} ${SOURCE} )
  target_link_libraries( ${NAME} PRIVATE
    ${CPPHLI_LINK}
  )
  
  if( BUILD_SHARED_LIBS )
    add_dependencies( ${NAME} cppinterface-shared )
  else()
    add_dependencies( ${NAME} cppinterface-static )
  endif()

  set_target_properties( ${NAME}
    PROPERTIES
      OUTPUT_NAME ${NAME}${EXE_EXT}
      COMPILE_FLAGS -DNOIMPLIB
  )
  
  install( TARGETS
    ${NAME}
    DESTINATION bin
  )
endmacro( BUILD_TEST )

########################################################################################################################
# Examples

set( TESTS
  test_core_profiles_get
  test_core_profiles_getSlice
  test_core_profiles_put
  test_core_profiles_putSlice
  test_core_profiles_serialize
  test_core_sources_get
  test_core_sources_put
  test_core_sources_putSlice
  test_magnetics_get
  test_magnetics_memory
  test_magnetics_put
  test_pf_active_get
  test_pf_active_getSlice
  test_pf_active_put
  test_pf_active_putSlice
  test_pulse_create
)

foreach( TEST ${TESTS} )
  BUILD_TEST( ${TEST} ${TEST}.cpp )
endforeach()
