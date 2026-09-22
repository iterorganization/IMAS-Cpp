# Self-test of copy_fixture.cmake, from a synthetic directory -- no pulse, no
# HLI, no shim.
#
# Two properties docs/SHIM_SUITE_CONVENTION.md S3.3 asks of a write
# scenario's private copy:
#   1. the copy is independent of its source -- mutating the copy must not
#      touch the checked-in fixture a read scenario relies on being
#      immutable;
#   2. the copy is *fresh* per run -- a leftover mutation from a previous,
#      failed run must not still be there the next time the copy is made, so
#      "a failed run leaves no poison" is something this script does, not
#      something a scenario has to remember to clean up first.
set( _work_dir "${CMAKE_CURRENT_BINARY_DIR}/fixture-copy-self-test" )
file( REMOVE_RECURSE "${_work_dir}" )
file( MAKE_DIRECTORY "${_work_dir}/source" )
file( WRITE "${_work_dir}/source/leaf.txt" "original\n" )

execute_process(
  COMMAND "${CMAKE_COMMAND}" -D "SOURCE=${_work_dir}/source"
    -D "DESTINATION=${_work_dir}/copy"
    -P "${CMAKE_CURRENT_LIST_DIR}/copy_fixture.cmake"
  RESULT_VARIABLE _first_result
)
if( NOT _first_result EQUAL 0 )
  message( FATAL_ERROR "FIXTURE-COPY-FAILURE: the first copy failed" )
endif()
if( NOT EXISTS "${_work_dir}/copy/leaf.txt" )
  message( FATAL_ERROR "FIXTURE-COPY-FAILURE: the copy does not contain the source's file" )
endif()

# --- property 1: isolation --------------------------------------------------
file( WRITE "${_work_dir}/copy/leaf.txt" "mutated by the write scenario\n" )
file( READ "${_work_dir}/source/leaf.txt" _source_after_mutation )
if( NOT _source_after_mutation STREQUAL "original\n" )
  message( FATAL_ERROR "FIXTURE-COPY-FAILURE: mutating the copy changed the source fixture" )
endif()

# --- property 2: freshness --------------------------------------------------
# Simulate a "poisoned" leftover from a prior run: a file the source never
# had, sitting in what a next run's private copy directory would be.
file( WRITE "${_work_dir}/copy/leftover-from-failed-run.txt" "poison\n" )
execute_process(
  COMMAND "${CMAKE_COMMAND}" -D "SOURCE=${_work_dir}/source"
    -D "DESTINATION=${_work_dir}/copy"
    -P "${CMAKE_CURRENT_LIST_DIR}/copy_fixture.cmake"
  RESULT_VARIABLE _second_result
)
if( NOT _second_result EQUAL 0 )
  message( FATAL_ERROR "FIXTURE-COPY-FAILURE: the second copy failed" )
endif()
if( EXISTS "${_work_dir}/copy/leftover-from-failed-run.txt" )
  message( FATAL_ERROR "FIXTURE-COPY-FAILURE: a leftover file from a prior run survived a fresh copy" )
endif()
file( READ "${_work_dir}/copy/leaf.txt" _copy_after_second_run )
if( NOT _copy_after_second_run STREQUAL "original\n" )
  message( FATAL_ERROR "FIXTURE-COPY-FAILURE: the fresh copy does not match the source; the mutation from the first run survived" )
endif()

file( REMOVE_RECURSE "${_work_dir}" )
message( STATUS "cpp-test-shim-fixture-copy: 2/2 properties held" )
