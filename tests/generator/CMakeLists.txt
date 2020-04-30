project( cppinterface )

include( ListSharedLibDependencies )


########################################################################################################################
# Dependencies

find_package( blitz REQUIRED )


########################################################################################################################
# Sources

set( SRC_FILES helper.cpp TestSuite.cpp )
set( HEADER_FILES helper.h TestSuite.h )

include_directories(
  ${blitz_INCLUDE_DIRS}
  ${CMAKE_CURRENT_SOURCE_DIR}/../../src
  ${CMAKE_SOURCE_DIR}/lowlevel
)


########################################################################################################################
# Targets

set( EXE_FLAG WIN32 )
set( EXE_EXT  )

if( BUILD_SHARED_LIBS )
  set( CPPHLI_LINK ${blitz_LIBRARIES} lowlevel-shared cppinterface-shared )
else()
  set( CPPHLI_LINK ${blitz_LIBRARIES} lowlevel-static cppinterface-static )
endif()

add_executable( TestSuite ${EXE_FLAG} ${SRC_FILES} )
target_link_libraries( TestSuite PRIVATE
  ${CPPHLI_LINK}
)

set_target_properties( TestSuite
  PROPERTIES
    OUTPUT_NAME TestSuite${EXE_EXT}
    COMPILE_FLAGS -DNOIMPLIB
)


########################################################################################################################
# Install

install( FILES TestSuite${EXE_EXT}
  DESTINATION bin
)
