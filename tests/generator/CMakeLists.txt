# Sources
################################################################################

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/TestSuite.cpp
  # Generate with xsltproc
  COMMAND
    ${_VENV_PYTHON} "${AL_LOCAL_XSLTPROC_SCRIPT}"
      -xsl ${CMAKE_CURRENT_SOURCE_DIR}/TestSuite.xsl
      -s ${IDSDEF}
      -o TestSuite.cpp
      test_memory_backend=not-implemented
      test_ascii_backend=not-implemented
      test_mdsplus_backend=$<IF:$<BOOL:${AL_BACKEND_MDSPLUS}>,yes,no>
      test_hdf5_backend=not-implemented
      test_uda_backend=not-implemented
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
  if( TARGET al-mdsplus-model )
    get_target_property( MDSPLUS_MODEL_DIR al-mdsplus-model BINARY_DIR )
  else()
    if( DEFINED ENV{MDSPLUS_MODELS_PATH} )
      set( MDSPLUS_MODEL_DIR "$ENV{MDSPLUS_MODELS_PATH}" )
    else()
      set( MDSPLUS_MODEL_DIR "$ENV{ids_path}" )
    endif()
  endif()
  # Note: added ids_path for backward compatibility with IMAS-Core<5.6
  set_tests_properties( cpp-TestSuite PROPERTIES
    ENVIRONMENT "IMAS_AL_DISABLE_OBSOLESCENT_WARNING=1;IMAS_AL_DISABLE_VALIDATE=1;IMAS_VERSION=${DD_VERSION};ids_path=${MDSPLUS_MODEL_DIR};MDSPLUS_MODELS_PATH=${MDSPLUS_MODEL_DIR}" )
endif()
