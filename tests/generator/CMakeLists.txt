# Dependencies
################################################################################

# Find LibXslt for the xsltproc program
find_package( LibXslt )
if( NOT LIBXSLT_XSLTPROC_EXECUTABLE )
  message( FATAL_ERROR "Could not find xsltproc" )
endif()

# Sources
################################################################################

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/TestSuite.cpp
  # Generate with xsltproc
  COMMAND
    ${LIBXSLT_XSLTPROC_EXECUTABLE}
      --output TestSuite.cpp
      --stringparam test_memory_backend not-implemented
      --stringparam test_ascii_backend not-implemented
      --stringparam test_mdsplus_backend $<IF:$<BOOL:${AL_BACKEND_MDSPLUS}>,yes,no>
      --stringparam test_hdf5_backend not-implemented
      --stringparam test_uda_backend not-implemented
      ${CMAKE_CURRENT_SOURCE_DIR}/TestSuite.xsl
      ${IDSDEF}
  DEPENDS TestSuite.xsl ${IDSDEF}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

# Targets
################################################################################

# Override CMAKE_BUILD_TYPE for this test to empty:
# - Don't optimize
# - Don't add debug symbols
# The c++ file is so big that the compiler will run out of memory when
# attempting to optimize / add debug symbols...
set( CMAKE_BUILD_TYPE "" )

add_executable( cpp-TestSuite 
  helper.cpp
  TestSuite.cpp
)
target_include_directories( cpp-TestSuite PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} )
target_link_libraries( cpp-TestSuite al-cpp )
target_compile_options( cpp-TestSuite PRIVATE -O0 )

add_test( NAME cpp-TestSuite COMMAND cpp-TestSuite )
set_tests_properties( cpp-TestSuite PROPERTIES
  FAIL_REGULAR_EXPRESSION "[Ee][Rr][Rr][Oo][Rr]"
)

if( NOT AL_BACKEND_MDSPLUS )
  set_tests_properties( cpp-TestSuite PROPERTIES DISABLED ON )
else()
  get_target_property( MDSPLUS_MODEL_DIR al-mdsplus-model BINARY_DIR )
  set_tests_properties( cpp-TestSuite PROPERTIES
    ENVIRONMENT "IMAS_AL_DISABLE_OBSOLESCENT_WARNING=1;IMAS_AL_DISABLE_VALIDATE=1;IMAS_VERSION=${DD_VERSION};ids_path=${MDSPLUS_MODEL_DIR}" )
endif()
