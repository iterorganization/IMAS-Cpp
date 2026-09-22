# CMake build configuration for the Access Layer C++ HLI
cmake_minimum_required( VERSION 3.16 )

# Configuration options for common assets
################################################################################
include(${CMAKE_CURRENT_SOURCE_DIR}/common/cmake/ALLocalPaths.cmake)

option( AL_DOWNLOAD_DEPENDENCIES "Automatically download assets from the AL git repository" ON )
option( AL_DEVELOPMENT_LAYOUT "Use development repositories from sibling directory" OFF )
option( AL_USE_MULTIVERSION_SHIM "Route C++ Access Layer calls through IMAS-Multiversion-DD-Loader" OFF )
if( AL_DEVELOPMENT_LAYOUT AND AL_DOWNLOAD_DEPENDENCIES )
    message( STATUS "AL_DEVELOPMENT_LAYOUT=ON: setting AL_DOWNLOAD_DEPENDENCIES=OFF" )
    set( AL_DOWNLOAD_DEPENDENCIES OFF CACHE BOOL "Automatically download assets from the AL git
    repository" FORCE )
endif()
set( AL_CORE_GIT_REPOSITORY_DEFAULT "https://github.com/iterorganization/IMAS-Core.git" )
set( AL_CORE_VERSION_DEFAULT "main" )
set( AL_CORE_GIT_REPOSITORY "${AL_CORE_GIT_REPOSITORY_DEFAULT}" CACHE STRING "Git repository of AL-core" )
set( AL_CORE_VERSION "${AL_CORE_VERSION_DEFAULT}" CACHE STRING "Git commit/tag/branch of AL-core" )

if( AL_USE_MULTIVERSION_SHIM AND AL_DOWNLOAD_DEPENDENCIES )
  # Pin IMAS-Core to a revision carrying the path-aware HDF5 delete fix, by
  # commit rather than by branch. Without it, the first delete a full put
  # issues destroys the whole occurrence instead of the targeted candidate,
  # no conversion is armed afterwards, and a later shim conformance scenario
  # (tests/shim, see docs/SHIM_SUITE_CONVENTION.md F6.4) is red for a reason
  # in neither this repository nor the shim.
  #
  # The fix (IMAS-Core #63, merged into a fork as #64:
  # fix/63-hdf5-delete-data-path) has not been merged into
  # iterorganization/IMAS-Core, so this pin necessarily points at that fork
  # rather than upstream until it is. IMAS-Multiversion-DD-Loader pins the
  # same commit (its IMAS_CORE_REF) for the same reason.
  #
  # Return to upstream (AL_CORE_GIT_REPOSITORY's default) once the fix lands
  # there, by removing this block rather than editing the values below.
  #
  # The pin applies only while both variables still hold either their defaults
  # (a first configure) or the pinned values themselves (a re-configure of a
  # tree this block already pinned). A user who passed
  # -D AL_CORE_GIT_REPOSITORY or -D AL_CORE_VERSION named the Core they want
  # built against; overriding that with FORCE would silently build something
  # other than what they asked for.
  set( AL_CORE_SHIM_PIN_REPOSITORY "https://github.com/yohannmarguier/IMAS-Core.git" )
  set( AL_CORE_SHIM_PIN_VERSION "dae4abdd9428bd28f47063f8f575bdc8abd915f2" )

  if( ( "${AL_CORE_GIT_REPOSITORY}" STREQUAL "${AL_CORE_GIT_REPOSITORY_DEFAULT}"
        OR "${AL_CORE_GIT_REPOSITORY}" STREQUAL "${AL_CORE_SHIM_PIN_REPOSITORY}" )
      AND ( "${AL_CORE_VERSION}" STREQUAL "${AL_CORE_VERSION_DEFAULT}"
            OR "${AL_CORE_VERSION}" STREQUAL "${AL_CORE_SHIM_PIN_VERSION}" ) )
    message( STATUS
      "AL_USE_MULTIVERSION_SHIM=ON: pinning AL-core to the path-aware HDF5 "
      "delete fix (${AL_CORE_SHIM_PIN_VERSION})" )
    set( AL_CORE_GIT_REPOSITORY "${AL_CORE_SHIM_PIN_REPOSITORY}" CACHE STRING
      "Git repository of AL-core" FORCE )
    set( AL_CORE_VERSION "${AL_CORE_SHIM_PIN_VERSION}" CACHE STRING
      "Git commit/tag/branch of AL-core" FORCE )
  else()
    message( STATUS
      "AL_USE_MULTIVERSION_SHIM=ON: keeping the requested AL-core "
      "(${AL_CORE_GIT_REPOSITORY}@${AL_CORE_VERSION}) instead of the "
      "path-aware HDF5 delete fix pin. Without that fix, the tests/shim "
      "full-put scenario (F6.4) is expected to be red." )
  endif()
endif()

include(FetchContent)

if( ${AL_DOWNLOAD_DEPENDENCIES} )
  # Download common assets from the ITER git:
  FetchContent_Declare(
    al-core
    GIT_REPOSITORY "${AL_CORE_GIT_REPOSITORY}"
    GIT_TAG "${AL_CORE_VERSION}"
  )
  FetchContent_MakeAvailable( al-core )
elseif ( ${AL_DEVELOPMENT_LAYOUT} )
  FetchContent_Declare(
    al-core
    SOURCE_DIR      "${CMAKE_CURRENT_SOURCE_DIR}/../IMAS-Core"
  )
  FetchContent_MakeAvailable( al-core )
endif()


# Define project
################################################################################

# Set VERSION and FULL_VERSION from `git describe`:
set( GIT_ARCHIVE_DESCRIBE [[$Format:%(describe)$]] )
include( ALDetermineVersion )
project( al-cpp
  VERSION ${VERSION}
  DESCRIPTION "C++ High Level Interface of the IMAS Access Layer"
  HOMEPAGE_URL "https://imas.iter.org/"
  LANGUAGES C CXX
)
if( NOT PROJECT_VERSION_TWEAK EQUAL 0 )
  message( "Building a development version of the Access Layer C++ HLI" )
endif()

# Compiler settings
include( ALSetCompilerFlags )
# Common HLI options
include( ALCommonConfig )
# Data dictionary
include( ALBuildDataDictionary )
# AL core, plugins and documentation
include( ALCore )

# Stop processing when only building documentation
if( AL_DOCS_ONLY )
  return()
endif()


# Dependencies
################################################################################
find_package( Python3 REQUIRED COMPONENTS Interpreter )
find_package( PkgConfig )
# Find Blitz through pkg-config
pkg_check_modules( blitz REQUIRED IMPORTED_TARGET blitz )


# Generate sources
################################################################################

set( GENERATED_SRC_DIR "${CMAKE_CURRENT_BINARY_DIR}/src" )

# Generated header files by IDSDef2CPPClasses.xsl
set( GENERATED_HEADERS "${GENERATED_SRC_DIR}/ALClasses.h" )
# Generated source files by IDSDef2CPPMethods.xsl
set( GENERATED_SOURCES "${GENERATED_SRC_DIR}/ALMethods.cpp" )
foreach( IDS_NAME IN LISTS IDS_NAMES )
  list( APPEND GENERATED_HEADERS "${GENERATED_SRC_DIR}/ids/${IDS_NAME}_IDSBase.h" )
  list( APPEND GENERATED_SOURCES "${GENERATED_SRC_DIR}/ids/${IDS_NAME}_IDSBase.cpp" )
endforeach()

add_custom_command(
  # Use a dummy output file: when listing all actual output files (which are
  # source files of target `al-cpp`), they would be re-created with every build.
  OUTPUT ${GENERATED_SRC_DIR}/dummy.txt
  # Generate headers with xsltproc
  COMMAND
    ${_VENV_PYTHON} "${AL_LOCAL_XSLTPROC_SCRIPT}"
      -xsl ${CMAKE_CURRENT_SOURCE_DIR}/IDSDef2CPPClasses.xsl
      -s ${IDSDEF}
      -o ${GENERATED_SRC_DIR}/ALClasses.h
      DD_GIT_DESCRIBE=${DD_VERSION}
      AL_GIT_DESCRIBE=${FULL_VERSION}
  # Generate source files with xsltproc
  COMMAND
    ${_VENV_PYTHON} "${AL_LOCAL_XSLTPROC_SCRIPT}"
      -xsl ${CMAKE_CURRENT_SOURCE_DIR}/IDSDef2CPPMethods.xsl
      -s ${IDSDEF}
      -o ${GENERATED_SRC_DIR}/ALMethods.cpp
      DD_GIT_DESCRIBE=${DD_VERSION}
      AL_GIT_DESCRIBE=${FULL_VERSION}
  # Create/update our dummy file
  COMMAND ${CMAKE_COMMAND} -E touch ${GENERATED_SRC_DIR}/dummy.txt
  DEPENDS IDSDef2CPPClasses.xsl IDSDef2CPPMethods.xsl ${IDSDEF}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
add_custom_target( al-cpp-sources
  COMMAND ${CMAKE_COMMAND} -E echo ""
  DEPENDS ${GENERATED_SRC_DIR}/dummy.txt
  # Actually these are results of the custom_command above, but with this trick
  # we don't rebuild it always (only when IDSDef.xml or the xslts have changed)
  BYPRODUCTS ${GENERATED_SOURCES} ${GENERATED_HEADERS}
)

set( SOURCES ${GENERATED_SOURCES} )
list( APPEND SOURCES 
  src/IdsDef.cpp
)


# Generate sources (identifiers)
################################################################################

# Note: identifiers.xsl tries to import identifiers.common.xsl
# Unfortunately, xsl:include doesn't support parameters, so we need to put them together
# in the build folder:
file( CREATE_LINK
  "${CMAKE_CURRENT_SOURCE_DIR}/common/identifiers.common.xsl" 
  "${CMAKE_CURRENT_BINARY_DIR}/identifiers.common.xsl"
  SYMBOLIC COPY_ON_ERROR
)
file( CREATE_LINK
  "${CMAKE_CURRENT_SOURCE_DIR}/identifiers.xsl" 
  "${CMAKE_CURRENT_BINARY_DIR}/identifiers.xsl"
  SYMBOLIC COPY_ON_ERROR
)
set( IDENTIFIER_SRC_DIR ${CMAKE_CURRENT_BINARY_DIR}/identifiers/src/ )

set( IDENTIFIER_SOURCES )
set( IDENTIFIER_HEADERS )
foreach( ID_FILE IN LISTS DD_IDENTIFIER_FILES )
  # cmake_path( GET ID_FILE STEM ID_NAME)
  string( REGEX REPLACE "(^.*[/\\]|[.]xml$)" "" ID_NAME ${ID_FILE} )
  set( SOURCE_NAME "${IDENTIFIER_SRC_DIR}/${ID_NAME}.cpp" )
  set( HEADER_NAME "${IDENTIFIER_SRC_DIR}/${ID_NAME}.h" )
  add_custom_command(
    OUTPUT ${SOURCE_NAME} ${HEADER_NAME}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${IDENTIFIER_SRC_DIR}
    COMMAND ${_VENV_PYTHON} "${AL_LOCAL_XSLTPROC_SCRIPT}"
      -xsl ${CMAKE_CURRENT_BINARY_DIR}/identifiers.xsl
      -s ${ID_FILE}
      name=${ID_NAME}
      prefix=${IDENTIFIER_SRC_DIR}
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/identifiers.xsl
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )
  list( APPEND IDENTIFIER_SOURCES ${SOURCE_NAME} )
  list( APPEND IDENTIFIER_HEADERS ${HEADER_NAME} )
endforeach()


# Targets
################################################################################

add_library( al-cpp ${SOURCES} )
# Ensure sources are generated before building al-cpp:
add_dependencies( al-cpp al-cpp-sources )
# Set target output library name to include the DD version
set_target_properties( al-cpp PROPERTIES LIBRARY_OUTPUT_NAME "al-cpp-${DD_VERSION}" )

include( ${CMAKE_CURRENT_SOURCE_DIR}/cmake/ALCppCoreLinkage.cmake )
target_link_libraries( al-cpp PUBLIC ${AL_CPP_CORE_TARGET} PkgConfig::blitz )
# Blitz requires pthread, but doesn't advertize it in it's package config :(
target_compile_options( al-cpp PUBLIC -pthread )
target_link_options( al-cpp PUBLIC -pthread )

# Build the CPP interface without optimizations!
# Optimizing the code takes too long and too much memory...
# The -O0 option is added on the command line after the default -O option (from
# CMAKE_BUILD_TYPE) and takes precedence
target_compile_options( al-cpp PRIVATE -O0 )

target_include_directories( al-cpp PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/src>
  $<INSTALL_INTERFACE:include>  # <prefix>/include
)

add_library( al-identifiers-cpp ${IDENTIFIER_SOURCES} )
target_include_directories( al-identifiers-cpp PUBLIC
  $<BUILD_INTERFACE:${IDENTIFIER_SRC_DIR}>
  $<INSTALL_INTERFACE:include>  # <prefix>/include
)


# Install
################################################################################

install( TARGETS al-cpp al-identifiers-cpp )

# Identifier headers
install( FILES ${IDENTIFIER_HEADERS} DESTINATION include/cpp )

# Headers installed in include/
set( BASE_HEADERS ${GENERATED_HEADERS} )
list( FILTER BASE_HEADERS EXCLUDE REGEX "src/ids" )
install( FILES ${BASE_HEADERS} DESTINATION include )
# Install non-generated headers
install( FILES src/ALDef.h src/IdsDef.h DESTINATION include )

# Headers installed in include/ids
set( IDS_HEADERS ${GENERATED_HEADERS} )
list( FILTER IDS_HEADERS INCLUDE REGEX "src/ids" )
install( FILES ${IDS_HEADERS} DESTINATION include/ids )

# Generate and install .pc files
configure_file( pkgconfig/al-cpp.pc.in al-cpp.pc @ONLY )
configure_file( pkgconfig/al-cpp-DD_VERSION.pc.in al-cpp-${DD_VERSION}.pc @ONLY )
configure_file( pkgconfig/al-identifiers-cpp.pc.in al-identifiers-cpp.pc @ONLY )
install( FILES
    ${CMAKE_CURRENT_BINARY_DIR}/al-cpp.pc
    ${CMAKE_CURRENT_BINARY_DIR}/al-cpp-${DD_VERSION}.pc
    ${CMAKE_CURRENT_BINARY_DIR}/al-identifiers-cpp.pc
  DESTINATION lib/pkgconfig
)

# Create backward compatibility symlinks (imas-* -> al-*)
install( CODE "
  execute_process( COMMAND \${CMAKE_COMMAND} -E create_symlink al-cpp.pc imas-cpp.pc
    WORKING_DIRECTORY \${CMAKE_INSTALL_PREFIX}/lib/pkgconfig )
  execute_process( COMMAND \${CMAKE_COMMAND} -E create_symlink al-cpp-${DD_VERSION}.pc imas-cpp-${DD_VERSION}.pc
    WORKING_DIRECTORY \${CMAKE_INSTALL_PREFIX}/lib/pkgconfig )
  execute_process( COMMAND \${CMAKE_COMMAND} -E create_symlink al-identifiers-cpp.pc imas-identifiers-cpp.pc
    WORKING_DIRECTORY \${CMAKE_INSTALL_PREFIX}/lib/pkgconfig )
" )

# Tests
################################################################################

if( AL_TESTS )
  add_subdirectory( tests/generator )
  if( AL_USE_MULTIVERSION_SHIM )
    add_subdirectory( tests/shim )
  endif()
endif()

if( AL_EXAMPLES )
  add_subdirectory( examples )
  add_subdirectory( doc/code_samples/tutorial )
endif()
