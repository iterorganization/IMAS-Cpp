# Content-digest of every file under a fixture directory.
#
# docs/SHIM_SUITE_CONVENTION.md S3.3: a read test's fixture "SHOULD be verified
# unchanged afterwards -- content digest, not mtime". HDF5 rewrites can leave a
# file's size alone, and a checkout sets timestamps arbitrarily, so mtime
# proves nothing; this hashes every file's content instead. If a converting
# read ever wrote back to the pulse it read, nothing else in this suite would
# notice, and every later comparison would be against a pulse the suite itself
# had modified.
function( al_cpp_shim_fixture_digest fixture_root out_var )
  if( NOT IS_DIRECTORY "${fixture_root}" )
    message( FATAL_ERROR "SCENARIO-FAILURE: no such fixture directory: ${fixture_root}" )
  endif()
  file( GLOB_RECURSE _al_cpp_shim_digest_files "${fixture_root}/*" )
  list( SORT _al_cpp_shim_digest_files )
  set( _al_cpp_shim_digest "" )
  foreach( _al_cpp_shim_digest_file IN LISTS _al_cpp_shim_digest_files )
    if( NOT IS_DIRECTORY "${_al_cpp_shim_digest_file}" )
      file( MD5 "${_al_cpp_shim_digest_file}" _al_cpp_shim_digest_hash )
      string( APPEND _al_cpp_shim_digest "${_al_cpp_shim_digest_file} ${_al_cpp_shim_digest_hash}\n" )
    endif()
  endforeach()
  if( _al_cpp_shim_digest STREQUAL "" )
    # An empty digest compares equal to itself no matter what runs in between,
    # so an unchanged check against an empty directory would pass vacuously.
    message( FATAL_ERROR "SCENARIO-FAILURE: no files found under ${fixture_root}: the unchanged check would pass vacuously" )
  endif()
  set( ${out_var} "${_al_cpp_shim_digest}" PARENT_SCOPE )
endfunction()
