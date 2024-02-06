# CMake build configuration for the Access Layer C++ HLI
cmake_minimum_required( VERSION 3.16 )

# Configuration options for common assets
################################################################################
option( AL_DOWNLOAD_DEPENDENCIES "Automatically download common assets from the AL git repository" OFF )
set( AL_COMMON_GIT_REPOSITORY "ssh://git@git.iter.org/imas/al-common.git" CACHE STRING "Git repository of AL-common" )
set( AL_COMMON_VERSION "8e0773a073ced83f3e7f79a726480e9ac0ed18b2" CACHE STRING "Git commit/tag/branch of AL-common" )

include(FetchContent)

# Load common assets
################################################################################
if( ${AL_DOWNLOAD_DEPENDENCIES} )
  # Download common assets from the ITER git:
  FetchContent_Declare(
    al-common
    GIT_REPOSITORY "${AL_COMMON_GIT_REPOSITORY}"
    GIT_TAG "${AL_COMMON_VERSION}"
  )
else()
  # Look in ../al-common for common files
  FetchContent_Declare(
    al-common
    SOURCE_DIR      ${CMAKE_CURRENT_SOURCE_DIR}/../al-common
  )
endif()
FetchContent_MakeAvailable( al-common )


# Define project
################################################################################

# Set VERSION and FULL_VERSION from `git describe`:
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
# AL lowlevel and plugins
include( ALLowlevel )


# Dependencies
################################################################################

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

find_package( SaxonHE )
add_custom_command(
  # Use a dummy output file: when listing all actual output files (which are
  # source files of target `al-cpp`), they would be re-created with every build.
  OUTPUT ${GENERATED_SRC_DIR}/dummy.txt
  # Generate headers with xsltproc
  COMMAND
    ${LIBXSLT_XSLTPROC_EXECUTABLE}
      ${CMAKE_CURRENT_SOURCE_DIR}/IDSDef2CPPClasses.xsl
      ${IDSDEF}
  # Generate source files with saxon
  COMMAND
    java 
      -cp ${SaxonHE_CLASSPATH}
      net.sf.saxon.Transform -t -warnings:fatal
      "-xsl:${CMAKE_CURRENT_SOURCE_DIR}/IDSDef2CPPMethods.xsl"
      "-s:${IDSDEF}"
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
  "${al-common_SOURCE_DIR}/identifiers.common.xsl" 
  "${CMAKE_CURRENT_BINARY_DIR}/identifiers.common.xsl"
  SYMBOLIC COPY_ON_ERROR
)
file( CREATE_LINK
  "${CMAKE_CURRENT_SOURCE_DIR}/identifiers.xsl" 
  "${CMAKE_CURRENT_BINARY_DIR}/identifiers.xsl"
  SYMBOLIC COPY_ON_ERROR
)
set( IDENTIFIER_SRC_DIR ${CMAKE_CURRENT_BINARY_DIR}/identifiers/src/ )
file( GLOB ID_FILES ${data-dictionary_SOURCE_DIR}/*/*_identifier.xml )

set( IDENTIFIER_SOURCES )
set( IDENTIFIER_HEADERS )
foreach( ID_FILE IN LISTS ID_FILES )
  # cmake_path( GET ID_FILE STEM ID_NAME)
  string( REGEX REPLACE "(^.*[/\\]|[.]xml$)" "" ID_NAME ${ID_FILE} )
  set( SOURCE_NAME "${IDENTIFIER_SRC_DIR}/${ID_NAME}.cpp" )
  set( HEADER_NAME "${IDENTIFIER_SRC_DIR}/${ID_NAME}.h" )
  add_custom_command(
    OUTPUT ${SOURCE_NAME} ${HEADER_NAME}
    COMMAND ${LIBXSLT_XSLTPROC_EXECUTABLE}
      --stringparam name ${ID_NAME}
      --stringparam prefix ${IDENTIFIER_SRC_DIR}
      ${CMAKE_CURRENT_BINARY_DIR}/identifiers.xsl
      ${ID_FILE}
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

target_link_libraries( al-cpp PUBLIC al PkgConfig::blitz )
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

# Tests
################################################################################

if( AL_TESTS )
  add_subdirectory( tests/generator )
endif()

if( AL_EXAMPLES )
  add_subdirectory( examples )
endif()
