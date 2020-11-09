project( cppinterface )

include( ListSharedLibDependencies )


########################################################################################################################
# Dependencies

find_package( blitz REQUIRED )


########################################################################################################################
# Sources

set( SRC_FILES src/IdsDef.cpp src/UALMethods.cpp )
file( GLOB SRC_IDS src/ids/*.cpp )

set( HEADER_FILES src/IdsDef.h src/UALDef.h src/UALClasses.h )
file( GLOB HEADER_IDS src/ids/*.h )

include_directories(
  ${blitz_INCLUDE_DIRS}
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  ${CMAKE_SOURCE_DIR}/lowlevel
)


########################################################################################################################
# Targets

add_library( cppinterface-objects OBJECT ${SRC_FILES} ${HEADER_FILES} ${SRC_IDS} ${HEADER_IDS} )

set( CPPHLI_OBJS
  $<TARGET_OBJECTS:cppinterface-objects>
)


add_library( cppinterface-static STATIC ${CPPHLI_OBJS} )
if( BUILD_SHARED_LIBS )
  add_library( cppinterface-shared SHARED ${CPPHLI_OBJS} )
endif()

if( BUILD_SHARED_LIBS )
  set( CPPHLI_LINK ${blitz_LIBRARIES} lowlevel-shared )
else()
  set( CPPHLI_LINK ${blitz_LIBRARIES} lowlevel-static )
endif()

target_link_libraries( cppinterface-static PRIVATE ${CPPHLI_LINK} )
if( BUILD_SHARED_LIBS )
  target_link_libraries( cppinterface-shared PRIVATE ${CPPHLI_LINK} )
endif()


########################################################################################################################
# Set library properties

set_target_properties( cppinterface-static
  PROPERTIES
    OUTPUT_NAME libal-cpp
)

if( BUILD_SHARED_LIBS )
  set_target_properties( cppinterface-shared
    PROPERTIES
      OUTPUT_NAME libal-cpp
      VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}
	  IMPORT_SUFFIX ".dll.lib"
  )
  
  ExportBinDef( cppinterface-shared ${CMAKE_CURRENT_BINARY_DIR} cppinterface )
endif()


########################################################################################################################
# Install

install( TARGETS cppinterface-static
  DESTINATION lib
)

if( BUILD_SHARED_LIBS )
  install( TARGETS cppinterface-shared
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
  )
endif()

install( FILES ${HEADER_FILES} 
  DESTINATION include/cppinterface
)

install( FILES ${HEADER_IDS} 
  DESTINATION include/cppinterface/ids
)

if( BUILD_SHARED_LIBS )
  # Extract Release target path to get all dependent libraries for installation
  #get_target_property( MY_BINARY_LOCATION cppinterface::cppinterface-shared IMPORTED_LOCATION_RELEASE )
  #ListDependencies( ${MY_BINARY_LOCATION} OFF cppinterface-shared_lists )
  
  # Install Blitz runtime libraries
  foreach( BLITZ_DLL ${blitz_RUNTIME_LIB} )
    ResolveDependencyPath( "${BLITZ_DLL}" BLITZ_PATH "" )
    
    install( FILES ${BLITZ_PATH}
      DESTINATION bin
    )
  endforeach()
endif()


########################################################################################################################
# Tests

if( IMAS_TESTS )
  add_subdirectory( tests/generator )
endif()
