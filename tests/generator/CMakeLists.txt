project( cppinterface-tests )

include( ListSharedLibDependencies )


########################################################################################################################
# Dependencies

find_package( Blitz NO_CMAKE_PATH REQUIRED )
find_package( Blitz REQUIRED )


########################################################################################################################
# Sources

set( SRC_FILES helper.cpp TestSuite.cpp )
set( HEADER_FILES helper.h TestSuite.h )

include_directories(
  ${Blitz_INCLUDE_DIRS}
  ${CMAKE_CURRENT_SOURCE_DIR}/../../src
  ${CMAKE_SOURCE_DIR}/lowlevel
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

add_executable( TestSuite ${EXE_FLAG} ${SRC_FILES} )
target_link_libraries( TestSuite PRIVATE
  ${CPPHLI_LINK}
)

if( BUILD_SHARED_LIBS )
  add_dependencies( TestSuite cppinterface-shared )
else()
  add_dependencies( TestSuite cppinterface-static )
endif()

set_target_properties( TestSuite
  PROPERTIES
    OUTPUT_NAME TestSuite${EXE_EXT}
    COMPILE_FLAGS -DNOIMPLIB
)


########################################################################################################################
# Install

install( TARGETS TestSuite
  DESTINATION bin
)
