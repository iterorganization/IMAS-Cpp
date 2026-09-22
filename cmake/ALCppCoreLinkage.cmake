# Core is still acquired for its C++ headers and for the shim to load at runtime.
# Do not propagate its link interface in shim mode: linking both libraries can
# bind the mirrored C ABI symbols directly to Core and bypass conversion.
set( AL_CPP_CORE_TARGET al )
set( AL_CPP_CORE_PC_REQUIRES "al-core >= ${AL_CORE_VERSION}" )
set( AL_CPP_CORE_PC_CFLAGS "" )
# Extra environment the tests and examples need in shim mode (see below).
set( AL_CPP_SHIM_TEST_ENVIRONMENT "" )

if( AL_USE_MULTIVERSION_SHIM )
  find_package( imas-mvdd-loader REQUIRED CONFIG )
  set( AL_CPP_CORE_TARGET imas-mvdd-loader::imas-mvdd-loader )
  set( AL_CPP_CORE_PC_REQUIRES "imas-mvdd-loader" )
  # File name of the shim's library, without prefix or suffix -- what a
  # dependency listing of the built al-cpp library spells. tests/shim's
  # linkage test asserts on it.
  set( AL_SHIM_LIBRARY_NAME imas_mvdd_loader )
  target_include_directories( al-cpp PUBLIC
    "$<BUILD_INTERFACE:$<TARGET_PROPERTY:al,INTERFACE_INCLUDE_DIRECTORIES>>"
  )

  if( AL_DOWNLOAD_DEPENDENCIES OR AL_DEVELOPMENT_LAYOUT )
    # Build Core for runtime use even when building only the al-cpp target.
    # Its headers are installed alongside the C++ headers by the Core subproject.
    add_dependencies( al-cpp al )
    # The shim dlopen()s Core; a Core built into our own build tree is not on
    # the loader search path, so tests must name it explicitly. Without this
    # every mirrored call returns a null/failure result: getALVersion() hands
    # back NULL and al_begin_dataentry_action() errors out.
    list( APPEND AL_CPP_SHIM_TEST_ENVIRONMENT "IMAS_CORE_LIBRARY=$<TARGET_FILE:al>" )
  else()
    # Installed Core may live in a different prefix. Export only its compiler
    # flags, not its libraries, to downstream pkg-config consumers.
    string( JOIN " " AL_CPP_CORE_PC_CFLAGS ${al_CFLAGS} )
  endif()

  # Report the DD version this HLI was generated against, so the shim can
  # convert between it and the DD version of the data entry.
  list( APPEND AL_CPP_SHIM_TEST_ENVIRONMENT "IMAS_MVDD_HLI_DD_VERSION=${DD_VERSION}" )

  message( STATUS "C++ Access Layer calls use the multiversion shim (${imas-mvdd-loader_DIR})" )
endif()
