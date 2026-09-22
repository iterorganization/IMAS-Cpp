# F1.3 verdict-orientation (docs/SHIM_SUITE_CONVENTION.md S4.3): the
# residual hole no compiler can close.
#
# shim_comparator.h already makes a positionally-swapped Compare() call a
# compile error, because OracleReading and ConvertedReading are distinct
# types. What it cannot catch is a call that spells both keywords correctly
# but wraps the wrong reading in each -- an `oracle=` argument fed a
# cross-version reading -- since both wrapper types are equally
# constructible from the same vector<double>.
#
# The convention's answer is a source check: with the keyword comment
# adjacent to its value, "an oracle= argument holds a converted reading" is
# at least a pattern a human reviewer (or a sharper future check) can grep
# for. This check only proves the weaker, mechanical half of that: it counts
# how many named sides (`/*oracle=*/`, `/*converted=*/` comments) it finds
# across tests/shim/ and fails below a floor, so it cannot pass by matching
# nothing -- the failure mode of every grep-shaped test. The floor rises as
# later tickets add rule programs with their own Compare() call sites.
#
# Invoked by tests/shim/CMakeLists.txt.

foreach( _var SOURCE_DIR FLOOR )
  if( NOT DEFINED ${_var} )
    message( FATAL_ERROR "check_verdict_orientation.cmake: -D ${_var}=... is required" )
  endif()
endforeach()

file( GLOB _sources "${SOURCE_DIR}/*.cpp" "${SOURCE_DIR}/*.h" )

set( _oracle_sites 0 )
set( _converted_sites 0 )

foreach( _source ${_sources} )
  file( READ "${_source}" _content )
  string( REGEX MATCHALL "/\\*oracle=\\*/" _oracle_matches "${_content}" )
  string( REGEX MATCHALL "/\\*converted=\\*/" _converted_matches "${_content}" )
  list( LENGTH _oracle_matches _oracle_count )
  list( LENGTH _converted_matches _converted_count )
  math( EXPR _oracle_sites "${_oracle_sites} + ${_oracle_count}" )
  math( EXPR _converted_sites "${_converted_sites} + ${_converted_count}" )
endforeach()

# Every Compare() call names exactly one oracle= side and one converted=
# side, so the two counts drifting apart means a call was found with one
# comment but not the other -- itself worth failing on rather than silently
# folding into a single total.
if( NOT _oracle_sites EQUAL _converted_sites )
  message( FATAL_ERROR
    "VERDICT-ORIENTATION-FAILURE: found ${_oracle_sites} oracle= site(s) but "
    "${_converted_sites} converted= site(s) across ${SOURCE_DIR} -- every "
    "Compare() call must name exactly one of each"
  )
endif()

if( _oracle_sites LESS FLOOR )
  message( FATAL_ERROR
    "VERDICT-ORIENTATION-FAILURE: found only ${_oracle_sites} named side(s) "
    "across ${SOURCE_DIR}, below the floor of ${FLOOR} -- this check must "
    "not pass by finding nothing"
  )
endif()

message( STATUS "verdict-orientation: ${_oracle_sites} named side(s) found, floor ${FLOOR}" )
