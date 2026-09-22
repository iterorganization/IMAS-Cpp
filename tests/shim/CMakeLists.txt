# The shim conformance suite scaffold (issue #10), plus the harness-integrity
# comparator (issue #11).
#
# Registration order below follows docs/SHIM_SUITE_CONVENTION.md S5.1's
# Family 1 (harness integrity): linkage, then the comparator's own truth
# table, then the source check that covers what the comparator's type system
# cannot. Until linkage passes, nothing else the suite will ever say means
# anything: every functional test in this repository's own suite passes just
# as well against a build that resolved its symbols straight to IMAS-Core and
# converted nothing. See tests/shim/README.md for what is and is not covered
# so far.
#
# The whole file is registered only in a shim build: with
# AL_USE_MULTIVERSION_SHIM off there is nothing to assert and the test list
# stays exactly what it was.

if( WIN32 )
  # The shim resolves AL core through dlopen/dlsym, so a shim build is
  # POSIX-only.
  message( STATUS "Not registering the shim test suite: not supported on Windows" )
  return()
endif()

# otool and objdump report a shared library's dependencies in different
# formats, but both spell the dependency's file name, which is all the
# linkage test looks for.
if( APPLE )
  find_program( AL_SHIM_INSPECT_TOOL otool )
  set( AL_SHIM_INSPECT_ARGS -L )
elseif( CMAKE_OBJDUMP )
  # What CMake itself uses for dependency inspection.
  set( AL_SHIM_INSPECT_TOOL ${CMAKE_OBJDUMP} )
  set( AL_SHIM_INSPECT_ARGS -p )
else()
  find_program( AL_SHIM_INSPECT_TOOL objdump )
  set( AL_SHIM_INSPECT_ARGS -p )
endif()

if( NOT AL_SHIM_INSPECT_TOOL )
  # This return() skips the whole suite, not only the linkage test, because
  # every test below is registered after it. A missing prerequisite must
  # skip registration, never register a test that would pass without
  # checking anything.
  message( STATUS "Not registering the shim test suite: no dependency inspection tool found" )
  return()
endif()

# F1.1 linkage (docs/SHIM_SUITE_CONVENTION.md S5.1): inspect the built al-cpp
# library's dynamic dependencies and require the shim's library name to
# appear. Functional tests pass against a build that never loaded the shim;
# a dependency listing is the only honest check.
add_test( NAME cpp-test-shim-linkage
  COMMAND ${CMAKE_COMMAND}
    -D "LIBRARY=$<TARGET_FILE:al-cpp>"
    -D "INSPECT_TOOL=${AL_SHIM_INSPECT_TOOL}"
    -D "INSPECT_ARGS=${AL_SHIM_INSPECT_ARGS}"
    -D "SHIM_LIBRARY_NAME=${AL_SHIM_LIBRARY_NAME}"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/check_shim_linkage.cmake"
)
set_tests_properties( cpp-test-shim-linkage PROPERTIES
  LABELS "shim;harness"
)

# The shared run guard every later contract-assertion / behaviour-pin
# program in this suite is expected to use (docs/SHIM_SUITE_CONVENTION.md
# D6, shim_run_guard.h): it counts the assertions a program actually ran and
# fails if that differs from a number the program states up front, so a
# check lost in a later edit fails the run instead of quietly shrinking it.
# Tested here in isolation, from literals -- a pulse-based test can never
# prove its own guard right, the same reasoning S4.4 applies to the
# comparison oracle.
add_executable( cpp-test-shim-run-guard test_shim_run_guard.cpp )
add_test( NAME cpp-test-shim-run-guard COMMAND cpp-test-shim-run-guard )
set_tests_properties( cpp-test-shim-run-guard PROPERTIES
  LABELS "shim;harness"
  FAIL_REGULAR_EXPRESSION "RUN-GUARD-FAILURE"
)

# F1.2 comparison (docs/SHIM_SUITE_CONVENTION.md S4.4, S5.1): the shared
# comparator's own synthetic truth table, driven from literals -- no rule
# table, no fixture, no pulse, because a pulse-based test can never prove
# its own oracle right.
add_executable( cpp-test-shim-comparator test_shim_comparator.cpp )
add_test( NAME cpp-test-shim-comparison COMMAND cpp-test-shim-comparator )
set_tests_properties( cpp-test-shim-comparison PROPERTIES
  LABELS "shim;harness"
  FAIL_REGULAR_EXPRESSION "COMPARATOR-FAILURE"
)

# F1.3 verdict-orientation (docs/SHIM_SUITE_CONVENTION.md S4.3, S5.1): the
# residual hole the comparator's distinct wrapper types cannot close on
# their own -- a call that spells both `oracle=`/`converted=` comments but
# wraps the wrong reading in each. Counts the named sides this ticket's own
# comparator test contributes; later tickets' rule programs raise the floor
# as they add Compare() call sites of their own.
# Eleven sides are contributed by the comparator self-test; F4.1, F4.2 and
# F4.3 add their own fixture-driven comparison call sites on top of that.
set( AL_SHIM_VERDICT_ORIENTATION_FLOOR 62 )
add_test( NAME cpp-test-shim-verdict-orientation
  COMMAND ${CMAKE_COMMAND}
    -D "SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
    -D "FLOOR=${AL_SHIM_VERDICT_ORIENTATION_FLOOR}"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/check_verdict_orientation.cmake"
)
set_tests_properties( cpp-test-shim-verdict-orientation PROPERTIES
  LABELS "shim;harness"
)

# F1.4 fixture-provenance (docs/SHIM_SUITE_CONVENTION.md S3.2, S5.1): the
# checked-in equilibrium pulses must be what imas-python-fixtures/ produces,
# or every rule-table assertion this suite will ever make (issues #13--15,
# #21, #24) is against numbers nobody can re-derive. verify_fixtures.sh
# regenerates them outside the checkout and compares every HDF5 dataset with
# h5diff -- registering it here is what turns that from a script somebody
# may remember to run into a criterion the suite enforces.
#
# It needs the fixtures' own virtualenv (imas-python-fixtures/README.md) and
# h5diff, neither of which this project builds, so it registers only when
# both are present -- the same pattern as the linkage test above. A missing
# venv means the check is skipped, never that it silently passes.
set( AL_SHIM_FIXTURE_VENV_PYTHON "${CMAKE_SOURCE_DIR}/imas-python-fixtures/.venv/bin/python" )
find_program( AL_SHIM_H5DIFF h5diff )
if( EXISTS "${AL_SHIM_FIXTURE_VENV_PYTHON}" AND AL_SHIM_H5DIFF )
  add_test( NAME cpp-test-shim-fixture-provenance
    COMMAND "${CMAKE_SOURCE_DIR}/imas-python-fixtures/verify_fixtures.sh"
  )
  set_tests_properties( cpp-test-shim-fixture-provenance PROPERTIES
    LABELS "shim;harness"
  )
else()
  message( STATUS
    "Not registering cpp-test-shim-fixture-provenance: needs "
    "imas-python-fixtures/.venv (see its README) and h5diff" )
endif()

# The root every fixture-driven family in this suite (issues #13--15, #21,
# #24)
# reads from.
set( AL_SHIM_FIXTURE_ROOT "${CMAKE_SOURCE_DIR}/imas-python-fixtures/fixtures" )

# Two harness self-tests for helpers this ticket adds and later tickets rely
# on: a content-digest check that a read scenario's fixture is unchanged
# afterwards (docs/SHIM_SUITE_CONVENTION.md S3.3), and a private, freshly
# made copy for a write scenario (S3.3, S6). Both are exercised here against
# a synthetic directory, not a pulse -- a pulse-based test can never prove
# its own harness right, the same reasoning S4.4 gives the comparator.
add_test( NAME cpp-test-shim-fixture-digest
  COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/check_fixture_digest.cmake"
)
set_tests_properties( cpp-test-shim-fixture-digest PROPERTIES
  LABELS "shim;harness"
  FAIL_REGULAR_EXPRESSION "FIXTURE-DIGEST-FAILURE"
)

add_test( NAME cpp-test-shim-fixture-copy
  COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/check_fixture_copy.cmake"
)
set_tests_properties( cpp-test-shim-fixture-copy PROPERTIES
  LABELS "shim;harness"
  FAIL_REGULAR_EXPRESSION "FIXTURE-COPY-FAILURE"
)

# Give one test a private, empty loss-log directory.
#
# Leaving IMAS_MVDD_LOSS_LOG_DIR unset is not neutral: docs/
# SHIM_INTEGRATION_CONTRACT.md section 7 says the shim then writes into the
# current working directory, which for a ctest run is the build tree, where
# the file is left for whichever test globs there next. Every test whose
# read can be non-exact therefore needs a directory of its own -- see
# docs/SHIM_SUITE_CONVENTION.md S3.4 -- whether or not it asserts on it.
#
# None of the tests registered above call into the shim's runtime (linkage
# only inspects the built library; run-guard and the comparator tests make
# no AL call), so nothing here calls this function yet. It is part of this
# ticket's scaffold anyway: the convention sets this rule "once, relied on
# by every later ticket", and the contract-assertion and behaviour-pin
# families (issues #12--15, #21, #24) need it from their first test.
function( al_cpp_shim_private_loss_log test_name out_var )
  set( _dir "${CMAKE_CURRENT_BINARY_DIR}/${test_name}-loss-log" )
  add_test( NAME ${test_name}-loss-log-clean
    COMMAND ${CMAKE_COMMAND}
      -D "LOSS_LOG_DIR=${_dir}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/clean_loss_log_dir.cmake"
  )
  # `harness`: this is FIXTURES_SETUP plumbing that runs ahead of the test it
  # serves, not itself a statement about the shim. The convention (S5, S6) is
  # unconditional -- every registered test carries `shim` plus exactly one of
  # contract-assertion/behaviour-pin/harness -- and `harness` is the kind that
  # means "not a statement about the agreement", so `-L contract-assertion`
  # still selects only those statements.
  set_tests_properties( ${test_name}-loss-log-clean PROPERTIES
    FIXTURES_SETUP ${test_name}-loss-log
    LABELS "shim;harness"
  )
  set( ${out_var} "${_dir}" PARENT_SCOPE )
endfunction()

# A write scenario's private fixture copy (docs/SHIM_SUITE_CONVENTION.md
# S3.3): "A write test MUST run against a private copy made fresh before
# each run, so scenarios can run in parallel and a failed run leaves no
# poison." The round-trip pair below uses it; torn-write (#22) and
# full-put-stamp (#23) reuse it in turn. The helper ships with this ticket
# for the same reason al_cpp_shim_private_loss_log did with #10: the family
# that needs it should need nothing else from the scaffold.
function( al_cpp_shim_private_fixture_copy test_name source out_var )
  set( _dir "${CMAKE_CURRENT_BINARY_DIR}/${test_name}-fixture" )
  add_test( NAME ${test_name}-fixture-copy
    COMMAND ${CMAKE_COMMAND}
      -D "SOURCE=${source}"
      -D "DESTINATION=${_dir}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/copy_fixture.cmake"
  )
  # `harness`, for the same reason as the loss-log setup test above: this is
  # FIXTURES_SETUP plumbing, not itself a statement about the shim.
  set_tests_properties( ${test_name}-fixture-copy PROPERTIES
    FIXTURES_SETUP ${test_name}-fixture
    LABELS "shim;harness"
  )
  set( ${out_var} "${_dir}" PARENT_SCOPE )
endfunction()

# F3.1's program has no fixture-generation dependency at compile time. Keep
# the target available to typecheck in every shim build; registration below is
# still gated on the tooling that derives its malformed-stamp input.
add_executable( cpp-test-shim-stamp-malformed test_shim_stamp_malformed.cpp )
target_link_libraries( cpp-test-shim-stamp-malformed PRIVATE al-cpp )

# Stamp-state variants (docs/SHIM_SUITE_CONVENTION.md S3.3): three fixture
# states the passthrough and occurrence-open-refusal families (issues #13,
# #14) read while opening an occurrence, so they must exist before those
# tests' programs begin. Derived at build time from the checked-in DD
# 3.39.0 pulse -- absent (the stamp dataset deleted), malformed (a value
# that fails the version grammar), and mismatched with no artifact (a
# grammar-valid known release that is neither this suite's HLI version nor
# DD 3.39.0) -- and never committed: a ~40-line script copying the pulse and
# editing one dataset is enough; three more HDF5 pulses in the repository is
# not.
#
# Gated on the same fixtures venv as F1.4 above, plus h5py specifically:
# regenerating the pair only needs imas-python, but editing one dataset in a
# copy needs h5py, and the two are not the same dependency set.
set( AL_SHIM_STAMP_VARIANT_TOOLING_AVAILABLE FALSE )
if( EXISTS "${AL_SHIM_FIXTURE_VENV_PYTHON}" )
  execute_process(
    COMMAND "${AL_SHIM_FIXTURE_VENV_PYTHON}" -c "import h5py"
    RESULT_VARIABLE AL_SHIM_STAMP_VARIANT_H5PY_RESULT
    OUTPUT_QUIET
    ERROR_QUIET
  )
  if( AL_SHIM_STAMP_VARIANT_H5PY_RESULT EQUAL 0 )
    set( AL_SHIM_STAMP_VARIANT_TOOLING_AVAILABLE TRUE )
  endif()
endif()

if( NOT AL_SHIM_STAMP_VARIANT_TOOLING_AVAILABLE )
  message( STATUS
    "Not registering shim stamp-variant tests: needs imas-python-fixtures/.venv with h5py" )
else()
  set( AL_SHIM_STAMP_VARIANT_SOURCE "${AL_SHIM_FIXTURE_ROOT}/dd-3.39.0" )
  set( AL_SHIM_STAMP_ABSENT_FIXTURE "${CMAKE_CURRENT_BINARY_DIR}/stamp-absent-fixture" )
  set( AL_SHIM_STAMP_MALFORMED_FIXTURE "${CMAKE_CURRENT_BINARY_DIR}/stamp-malformed-fixture" )
  set( AL_SHIM_STAMP_MISMATCH_FIXTURE "${CMAKE_CURRENT_BINARY_DIR}/stamp-mismatch-fixture" )

  add_custom_command(
    OUTPUT
      "${AL_SHIM_STAMP_ABSENT_FIXTURE}/equilibrium.h5"
      "${AL_SHIM_STAMP_MALFORMED_FIXTURE}/equilibrium.h5"
      "${AL_SHIM_STAMP_MISMATCH_FIXTURE}/equilibrium.h5"
    COMMAND "${AL_SHIM_FIXTURE_VENV_PYTHON}" "${CMAKE_CURRENT_SOURCE_DIR}/derive_stamp_variant.py"
      "${AL_SHIM_STAMP_VARIANT_SOURCE}" "${AL_SHIM_STAMP_ABSENT_FIXTURE}" absent
    COMMAND "${AL_SHIM_FIXTURE_VENV_PYTHON}" "${CMAKE_CURRENT_SOURCE_DIR}/derive_stamp_variant.py"
      "${AL_SHIM_STAMP_VARIANT_SOURCE}" "${AL_SHIM_STAMP_MALFORMED_FIXTURE}" malformed
    COMMAND "${AL_SHIM_FIXTURE_VENV_PYTHON}" "${CMAKE_CURRENT_SOURCE_DIR}/derive_stamp_variant.py"
      "${AL_SHIM_STAMP_VARIANT_SOURCE}" "${AL_SHIM_STAMP_MISMATCH_FIXTURE}" mismatch
    DEPENDS
      "${CMAKE_CURRENT_SOURCE_DIR}/derive_stamp_variant.py"
      "${AL_SHIM_STAMP_VARIANT_SOURCE}/equilibrium.h5"
      "${AL_SHIM_STAMP_VARIANT_SOURCE}/master.h5"
    VERBATIM
  )
  # Named without the cpp-test-shim- prefix used everywhere else in this
  # file: this is a build target, not a registered CTest test, and `ctest
  # -N` should not suggest otherwise.
  add_custom_target( cpp-shim-stamp-fixtures ALL DEPENDS
    "${AL_SHIM_STAMP_ABSENT_FIXTURE}/equilibrium.h5"
    "${AL_SHIM_STAMP_MALFORMED_FIXTURE}/equilibrium.h5"
    "${AL_SHIM_STAMP_MISMATCH_FIXTURE}/equilibrium.h5"
  )

  # Prove the three variants keep the states F2.3 and F3.1 need distinct,
  # rather than trusting the derivation script did -- see
  # verify_stamp_variants.py's own docstring for the failure this would
  # catch.
  add_test( NAME cpp-test-shim-stamp-variants
    COMMAND "${AL_SHIM_FIXTURE_VENV_PYTHON}" "${CMAKE_CURRENT_SOURCE_DIR}/verify_stamp_variants.py"
      "${AL_SHIM_STAMP_ABSENT_FIXTURE}" "${AL_SHIM_STAMP_MALFORMED_FIXTURE}" "${AL_SHIM_STAMP_MISMATCH_FIXTURE}"
  )
  set_tests_properties( cpp-test-shim-stamp-variants PROPERTIES
    LABELS "shim;harness"
    FAIL_REGULAR_EXPRESSION "STAMP-VARIANT-FAILURE"
  )

  # F3.1 (docs/SHIM_SUITE_CONVENTION.md S5.3): a present but malformed
  # DD-version stamp belongs to the occurrence, not its enclosing data entry.
  # IDS::open therefore forwards, while equilibrium.get reaches the occurrence
  # open and returns the shim's refusal before any data seam is served.
  add_dependencies( cpp-test-shim-stamp-malformed cpp-shim-stamp-fixtures )

  # Gated on the HDF5 backend like every other fixture-reading scenario: the
  # program opens imas:hdf5?path=..., so without that backend it would
  # register and fail rather than skip, and a missing prerequisite must print
  # what is missing and skip registration.
  if( NOT AL_BACKEND_HDF5 )
    message( STATUS
      "Not registering shim occurrence-open refusal scenario: HDF5 backend is disabled" )
  else()
    al_cpp_shim_private_loss_log( cpp-test-shim-stamp-malformed
      AL_SHIM_STAMP_MALFORMED_LOSS_LOG_DIR )

    # The program verifies every returned public status and the untouched IDS.
    # Its generated get() prints the frozen reason rather than returning it, so
    # the read-fixture wrapper checks program success first, then captures the
    # message from standard output. This is F3.1's named diagnostic exception;
    # a PASS_REGULAR_EXPRESSION would be unsound because it can accept matching
    # output from a program that exited unsuccessfully.
    #
    # EXPECTED_STDOUT_SUBSTRING is the head of the frozen reason
    # `malformed DD-version stamp at
    # 'ids_properties/version_put/data_dictionary'`, cited from
    # docs/SHIM_INTEGRATION_CONTRACT.md S8.5 ("Version-latch and stamp
    # reasons"), whose own entry attributes it to the occurrence-open refusal
    # of S3's last row. Matched as a substring because S8.1 forbids asserting
    # a whole message: it is truncated to MAX_ERR_MSG_LEN, the path cut from
    # the left.
    add_test( NAME cpp-test-shim-stamp-malformed
      COMMAND ${CMAKE_COMMAND}
        -D "FIXTURE_ROOT=${AL_SHIM_STAMP_MALFORMED_FIXTURE}"
        -D "COMMAND_TO_RUN=$<TARGET_FILE:cpp-test-shim-stamp-malformed>;${AL_SHIM_STAMP_MALFORMED_FIXTURE}"
        -D "EXPECTED_STDOUT_SUBSTRING=malformed DD-version stamp"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/verify_fixture_unchanged.cmake"
    )
    set_tests_properties( cpp-test-shim-stamp-malformed PROPERTIES
      ENVIRONMENT "${AL_CPP_SHIM_TEST_ENVIRONMENT};IMAS_MVDD_LOSS_LOG_DIR=${AL_SHIM_STAMP_MALFORMED_LOSS_LOG_DIR}"
      FIXTURES_REQUIRED cpp-test-shim-stamp-malformed-loss-log
      LABELS "shim;contract-assertion"
      FAIL_REGULAR_EXPRESSION "REFUSAL-FAILURE;SCENARIO-FAILURE"
    )
  endif()

  # Family 2 (docs/SHIM_SUITE_CONVENTION.md S5.2, issue #13): all four
  # passthrough states read an HDF5 equilibrium fixture. They share one
  # binary but are four CTest commands, hence four processes; that isolation
  # matters because the shim latches an HLI DD version once per process.
  if( NOT AL_BACKEND_HDF5 )
    message( STATUS "Not registering shim passthrough scenarios: HDF5 backend is disabled" )
  else()
    add_executable( cpp-test-shim-passthrough test_shim_passthrough.cpp )
    target_include_directories( cpp-test-shim-passthrough PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} )
    target_link_libraries( cpp-test-shim-passthrough al-cpp )
    add_dependencies( cpp-test-shim-passthrough cpp-shim-stamp-fixtures )

    function( al_cpp_shim_add_passthrough_scenario test_name scenario fixture use_hli_version )
      al_cpp_shim_private_loss_log( ${test_name} _loss_log_dir )

      # The version-unset process gets a newly composed CTest environment that
      # contains the Core loader location but never contains the injected HLI
      # version. Do not launch it with a version and unset it in a wrapper:
      # absence, not an empty value or a late mutation, is F2.1's contract.
      set( _environment ${AL_CPP_SHIM_TEST_ENVIRONMENT}
        "IMAS_MVDD_LOSS_LOG_DIR=${_loss_log_dir}" )
      if( NOT use_hli_version )
        list( FILTER _environment EXCLUDE REGEX "^IMAS_MVDD_HLI_DD_VERSION=" )
      endif()

      add_test( NAME ${test_name}
        COMMAND ${CMAKE_COMMAND}
          -D "FIXTURE_ROOT=${fixture}"
          -D "LOSS_LOG_DIR=${_loss_log_dir}"
          -D "COMMAND_TO_RUN=$<TARGET_FILE:cpp-test-shim-passthrough>;${scenario};${fixture}"
          -P "${CMAKE_CURRENT_SOURCE_DIR}/verify_fixture_unchanged.cmake"
      )
      set_tests_properties( ${test_name} PROPERTIES
        FIXTURES_REQUIRED "${test_name}-loss-log"
        LABELS "shim;contract-assertion"
        ENVIRONMENT "${_environment}"
        FAIL_REGULAR_EXPRESSION "PASSTHROUGH-FAILURE;SCENARIO-FAILURE"
      )
    endfunction()

    al_cpp_shim_add_passthrough_scenario(
      cpp-test-shim-version-unset version-unset
      "${AL_SHIM_FIXTURE_ROOT}/dd-3.39.0" FALSE )
    al_cpp_shim_add_passthrough_scenario(
      cpp-test-shim-stamp-equal stamp-equal
      "${AL_SHIM_FIXTURE_ROOT}/dd-4.1.1" TRUE )
    al_cpp_shim_add_passthrough_scenario(
      cpp-test-shim-stamp-absent stamp-absent
      "${AL_SHIM_STAMP_ABSENT_FIXTURE}" TRUE )
    al_cpp_shim_add_passthrough_scenario(
      cpp-test-shim-stamp-mismatch-no-artifact stamp-mismatch-no-artifact
      "${AL_SHIM_STAMP_MISMATCH_FIXTURE}" TRUE )

  endif()
endif()

# Family 4.1 (docs/SHIM_SUITE_CONVENTION.md S5.4, issue #15): compare each
# structural conversion rule against the same equilibrium read from the DD
# 4.1.1 oracle fixture.  This read-only family needs HDF5, but not the optional
# Python/h5py tooling used solely to derive stamp variants above.
if( AL_BACKEND_HDF5 )
  add_executable( cpp-test-shim-structural-rules test_shim_structural_rules.cpp )
  target_include_directories( cpp-test-shim-structural-rules PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} )
  target_link_libraries( cpp-test-shim-structural-rules PRIVATE al-cpp )
  al_cpp_shim_private_loss_log( cpp-test-shim-structural-rules
    AL_SHIM_STRUCTURAL_LOSS_LOG_DIR )
  add_test( NAME cpp-test-shim-structural-rules
    COMMAND ${CMAKE_COMMAND}
      -D "FIXTURE_ROOT=${AL_SHIM_FIXTURE_ROOT}"
      -D "COMMAND_TO_RUN=$<TARGET_FILE:cpp-test-shim-structural-rules>;${AL_SHIM_FIXTURE_ROOT}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/verify_fixture_unchanged.cmake"
  )
  set_tests_properties( cpp-test-shim-structural-rules PROPERTIES
    ENVIRONMENT "${AL_CPP_SHIM_TEST_ENVIRONMENT};IMAS_MVDD_LOSS_LOG_DIR=${AL_SHIM_STRUCTURAL_LOSS_LOG_DIR}"
    FIXTURES_REQUIRED cpp-test-shim-structural-rules-loss-log
    LABELS "shim;contract-assertion"
    FAIL_REGULAR_EXPRESSION "STRUCTURAL-FAILURE;SCENARIO-FAILURE"
  )
else()
  message( STATUS "Not registering shim structural rules: HDF5 backend is disabled" )
endif()

# Family 4.2 (docs/SHIM_SUITE_CONVENTION.md S5.4, issue #16): check every
# map-declared COCOS sign flip through the public HLI.
if( AL_BACKEND_HDF5 )
  add_executable( cpp-test-shim-cocos-rules test_shim_cocos_rules.cpp )
  target_include_directories( cpp-test-shim-cocos-rules PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} )
  target_link_libraries( cpp-test-shim-cocos-rules PRIVATE al-cpp )
  al_cpp_shim_private_loss_log( cpp-test-shim-cocos-rules AL_SHIM_COCOS_LOSS_LOG_DIR )
  add_test( NAME cpp-test-shim-cocos-rules
    COMMAND ${CMAKE_COMMAND}
      -D "FIXTURE_ROOT=${AL_SHIM_FIXTURE_ROOT}"
      -D "COMMAND_TO_RUN=$<TARGET_FILE:cpp-test-shim-cocos-rules>;${AL_SHIM_FIXTURE_ROOT}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/verify_fixture_unchanged.cmake"
  )
  set_tests_properties( cpp-test-shim-cocos-rules PROPERTIES
    ENVIRONMENT "${AL_CPP_SHIM_TEST_ENVIRONMENT};IMAS_MVDD_LOSS_LOG_DIR=${AL_SHIM_COCOS_LOSS_LOG_DIR}"
    FIXTURES_REQUIRED cpp-test-shim-cocos-rules-loss-log
    LABELS "shim;contract-assertion"
    FAIL_REGULAR_EXPRESSION "COCOS-FAILURE;SCENARIO-FAILURE"
  )
else()
  message( STATUS "Not registering shim COCOS rules: HDF5 backend is disabled" )
endif()

# Family 4.3 (docs/SHIM_SUITE_CONVENTION.md S5.4, issue #17): the 13 paths the
# newer dictionary introduced. Expects ONLY_ORACLE per rule -- the shim
# correctly serves nothing, and the oracle holds a real value proving the
# comparison is not vacuous -- plus the D6 vacuity demonstration required of
# this family: a served-nothing reading must fail a real structural rule's own
# agreement expectation, or a shim that served nothing at all would satisfy
# every right-only rule for the wrong reason. Shares the same two-read shape
# and HDF5-only gating as F4.1.
if( AL_BACKEND_HDF5 )
  add_executable( cpp-test-shim-right-only-rules test_shim_right_only.cpp )
  target_include_directories( cpp-test-shim-right-only-rules PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} )
  target_link_libraries( cpp-test-shim-right-only-rules PRIVATE al-cpp )
  al_cpp_shim_private_loss_log( cpp-test-shim-right-only-rules
    AL_SHIM_RIGHT_ONLY_LOSS_LOG_DIR )
  add_test( NAME cpp-test-shim-right-only-rules
    COMMAND ${CMAKE_COMMAND}
      -D "FIXTURE_ROOT=${AL_SHIM_FIXTURE_ROOT}"
      -D "COMMAND_TO_RUN=$<TARGET_FILE:cpp-test-shim-right-only-rules>;${AL_SHIM_FIXTURE_ROOT}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/verify_fixture_unchanged.cmake"
  )
  set_tests_properties( cpp-test-shim-right-only-rules PROPERTIES
    ENVIRONMENT "${AL_CPP_SHIM_TEST_ENVIRONMENT};IMAS_MVDD_LOSS_LOG_DIR=${AL_SHIM_RIGHT_ONLY_LOSS_LOG_DIR}"
    FIXTURES_REQUIRED cpp-test-shim-right-only-rules-loss-log
    LABELS "shim;contract-assertion"
    FAIL_REGULAR_EXPRESSION "RIGHT-ONLY-FAILURE;SCENARIO-FAILURE"
  )
else()
  message( STATUS "Not registering shim right-only rules: HDF5 backend is disabled" )
endif()

# Family 4.4 (docs/SHIM_SUITE_CONVENTION.md S5.4, issue #18): the map's one
# `retyped` rule -- grids_ggd/grid/space/coordinates_type -- must be reported
# on all three channels (value, refused-path record, status), not merely
# survived. Same two reads as F4.1, read-only, so it needs HDF5 for the same
# reason.
if( AL_BACKEND_HDF5 )
  add_executable( cpp-test-shim-refusal-channels test_shim_refusal_channels.cpp )
  target_include_directories( cpp-test-shim-refusal-channels PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} )
  target_link_libraries( cpp-test-shim-refusal-channels PRIVATE al-cpp )
  al_cpp_shim_private_loss_log( cpp-test-shim-refusal-channels
    AL_SHIM_REFUSAL_CHANNELS_LOSS_LOG_DIR )
  add_test( NAME cpp-test-shim-refusal-channels
    COMMAND ${CMAKE_COMMAND}
      -D "FIXTURE_ROOT=${AL_SHIM_FIXTURE_ROOT}"
      -D "COMMAND_TO_RUN=$<TARGET_FILE:cpp-test-shim-refusal-channels>;${AL_SHIM_FIXTURE_ROOT}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/verify_fixture_unchanged.cmake"
  )
  set_tests_properties( cpp-test-shim-refusal-channels PROPERTIES
    ENVIRONMENT "${AL_CPP_SHIM_TEST_ENVIRONMENT};IMAS_MVDD_LOSS_LOG_DIR=${AL_SHIM_REFUSAL_CHANNELS_LOSS_LOG_DIR}"
    FIXTURES_REQUIRED cpp-test-shim-refusal-channels-loss-log
    LABELS "shim;contract-assertion"
    FAIL_REGULAR_EXPRESSION "REFUSAL-CHANNELS-FAILURE;SCENARIO-FAILURE"
  )
else()
  message( STATUS "Not registering shim refusal channels: HDF5 backend is disabled" )
endif()

# Family 5.1 (issue #20): require both a partial read and the exact public
# loss-log set, with the historical redefinition defects reported separately.
add_test( NAME cpp-test-shim-loss-log-harness
  COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/check_nested_loss_harness.cmake"
)
set_tests_properties( cpp-test-shim-loss-log-harness PROPERTIES
  LABELS "shim;harness"
  FAIL_REGULAR_EXPRESSION "LOSS-HARNESS-FAILURE"
)
if( AL_BACKEND_HDF5 )
  add_executable( cpp-test-shim-nested-loss test_shim_nested_loss.cpp )
  target_link_libraries( cpp-test-shim-nested-loss PRIVATE al-cpp )
  al_cpp_shim_private_loss_log( cpp-test-shim-nested-loss AL_SHIM_NESTED_LOSS_LOG_DIR )
  add_test( NAME cpp-test-shim-nested-loss
    COMMAND ${CMAKE_COMMAND}
      -D "FIXTURE_ROOT=${AL_SHIM_FIXTURE_ROOT}/dd-3.39.0"
      -D "LOSS_LOG_DIR=${AL_SHIM_NESTED_LOSS_LOG_DIR}"
      -D "COMMAND_TO_RUN=$<TARGET_FILE:cpp-test-shim-nested-loss>;${AL_SHIM_FIXTURE_ROOT}/dd-3.39.0"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/check_nested_loss_log.cmake"
  )
  set_tests_properties( cpp-test-shim-nested-loss PROPERTIES
    ENVIRONMENT "${AL_CPP_SHIM_TEST_ENVIRONMENT};IMAS_MVDD_LOSS_LOG_DIR=${AL_SHIM_NESTED_LOSS_LOG_DIR}"
    FIXTURES_REQUIRED cpp-test-shim-nested-loss-loss-log
    LABELS "shim;contract-assertion"
    FAIL_REGULAR_EXPRESSION "NESTED-LOSS-FAILURE;LOSS-LOG-FAILURE;LOSS-LOG-REDEFINITION-FAILURE;SCENARIO-FAILURE"
  )
else()
  message( STATUS "Not registering shim nested loss: HDF5 backend is disabled" )
endif()

# Family 6 (docs/SHIM_SUITE_CONVENTION.md S5.6, issue #21): one program
# exercises the slice-append round trip both across DD versions and against a
# same-version control. Keep registration in one parameterless function:
# these two executions are one argument, and neither may be independently
# selected out of the suite.
if( NOT AL_BACKEND_HDF5 )
  message( STATUS "Not registering shim round-trip scenarios: HDF5 backend is disabled" )
else()
  add_executable( cpp-test-shim-roundtrip test_shim_roundtrip.cpp )
  target_include_directories( cpp-test-shim-roundtrip PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} )
  target_link_libraries( cpp-test-shim-roundtrip PRIVATE al-cpp )

  function( al_cpp_shim_add_roundtrip_pair )
    set( _cross_test cpp-test-shim-roundtrip-cross-dd )
    set( _same_test cpp-test-shim-roundtrip-same-dd )
    set( _pair_test cpp-test-shim-roundtrip-pair )

    # The paired fixture owns the only two executable invocations.  The named
    # CTest cases consume its per-control result markers, so selection of
    # either case still runs both controls without duplicating either one.
    al_cpp_shim_private_fixture_copy( ${_pair_test}-cross
      "${AL_SHIM_FIXTURE_ROOT}/dd-3.39.0" _pair_cross_fixture )
    al_cpp_shim_private_fixture_copy( ${_pair_test}-same
      "${AL_SHIM_FIXTURE_ROOT}/dd-4.1.1" _pair_same_fixture )
    al_cpp_shim_private_loss_log( ${_pair_test}-cross _pair_cross_loss_log_dir )
    al_cpp_shim_private_loss_log( ${_pair_test}-same _pair_same_loss_log_dir )

    add_test( NAME ${_pair_test}
      COMMAND ${CMAKE_COMMAND}
        -D "PROGRAM=$<TARGET_FILE:cpp-test-shim-roundtrip>"
        -D "CROSS_FIXTURE=${_pair_cross_fixture}"
        -D "CROSS_LOSS_LOG_DIR=${_pair_cross_loss_log_dir}"
        -D "CROSS_RESULT_FILE=${_pair_cross_loss_log_dir}/roundtrip-passed"
        -D "SAME_FIXTURE=${_pair_same_fixture}"
        -D "SAME_LOSS_LOG_DIR=${_pair_same_loss_log_dir}"
        -D "SAME_RESULT_FILE=${_pair_same_loss_log_dir}/roundtrip-passed"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/run_roundtrip_pair.cmake"
    )
    # `harness`, not `contract-assertion`: this registration is the runner that
    # owns the two program invocations, and F6.1/F6.2 below are the statements
    # about the agreement. Labelling it contract-assertion too would make
    # `-L contract-assertion` return three tests for two catalogue rows and
    # report a single round-trip failure three times over.
    set_tests_properties( ${_pair_test} PROPERTIES
      FIXTURES_SETUP ${_pair_test}
      FIXTURES_REQUIRED "${_pair_test}-cross-fixture;${_pair_test}-same-fixture;${_pair_test}-cross-loss-log;${_pair_test}-same-loss-log"
      LABELS "shim;harness"
      ENVIRONMENT "${AL_CPP_SHIM_TEST_ENVIRONMENT}"
      FAIL_REGULAR_EXPRESSION "ROUNDTRIP-FAILURE"
    )

    add_test( NAME ${_cross_test}
      COMMAND ${CMAKE_COMMAND}
        -D "RESULT_FILE=${_pair_cross_loss_log_dir}/roundtrip-passed"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/check_roundtrip_result.cmake"
    )
    set_tests_properties( ${_cross_test} PROPERTIES
      FIXTURES_REQUIRED "${_pair_test}"
      LABELS "shim;contract-assertion"
      FAIL_REGULAR_EXPRESSION "ROUNDTRIP-FAILURE"
    )

    add_test( NAME ${_same_test}
      COMMAND ${CMAKE_COMMAND}
        -D "RESULT_FILE=${_pair_same_loss_log_dir}/roundtrip-passed"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/check_roundtrip_result.cmake"
    )
    set_tests_properties( ${_same_test} PROPERTIES
      FIXTURES_REQUIRED "${_pair_test}"
      LABELS "shim;contract-assertion"
      FAIL_REGULAR_EXPRESSION "ROUNDTRIP-FAILURE"
    )
  endfunction()

  al_cpp_shim_add_roundtrip_pair()

  # F6.3 `torn-write` (docs/SHIM_SUITE_CONVENTION.md S5.6, issue #22): a
  # `behaviour-pin`, not a `contract-assertion` -- it preserves an accepted
  # limitation (no rollback on a refused write) rather than asserting a
  # requirement of the shim.
  add_executable( cpp-test-shim-torn-write test_shim_torn_write.cpp )
  target_include_directories( cpp-test-shim-torn-write PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} )
  target_link_libraries( cpp-test-shim-torn-write PRIVATE al-cpp )

  al_cpp_shim_private_fixture_copy( cpp-test-shim-torn-write
    "${AL_SHIM_FIXTURE_ROOT}/dd-3.39.0" _torn_write_fixture )
  al_cpp_shim_private_loss_log( cpp-test-shim-torn-write _torn_write_loss_log_dir )

  add_test( NAME cpp-test-shim-torn-write
    COMMAND ${CMAKE_COMMAND}
      -D "COMMAND_TO_RUN=$<TARGET_FILE:cpp-test-shim-torn-write>;${_torn_write_fixture}"
      -D "EXPECTED_STDOUT_SUBSTRING=REFUSED WRITE: global_quantities/rho_tor_boundary"
      -D "LOSS_LOG_DIR=${_torn_write_loss_log_dir}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/verify_torn_write.cmake"
  )
  set_tests_properties( cpp-test-shim-torn-write PROPERTIES
    FIXTURES_REQUIRED "cpp-test-shim-torn-write-fixture;cpp-test-shim-torn-write-loss-log"
    LABELS "shim;behaviour-pin"
    ENVIRONMENT "${AL_CPP_SHIM_TEST_ENVIRONMENT};IMAS_MVDD_LOSS_LOG_DIR=${_torn_write_loss_log_dir}"
    FAIL_REGULAR_EXPRESSION "TORN-WRITE-FAILURE;SCENARIO-FAILURE"
  )

  # F6.4 `full-put-stamp` (docs/SHIM_SUITE_CONVENTION.md S5.6, issue #23): a
  # `contract-assertion` -- unlike F6.3, this pins a requirement of the shim
  # (the stored DD-version stamp MUST survive a mismatched full put), not an
  # accepted limitation.
  add_executable( cpp-test-shim-full-put-stamp test_shim_full_put_stamp.cpp )
  target_include_directories( cpp-test-shim-full-put-stamp PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} )
  target_link_libraries( cpp-test-shim-full-put-stamp PRIVATE al-cpp )

  al_cpp_shim_private_fixture_copy( cpp-test-shim-full-put-stamp
    "${AL_SHIM_FIXTURE_ROOT}/dd-3.39.0" _full_put_stamp_fixture )
  al_cpp_shim_private_loss_log( cpp-test-shim-full-put-stamp _full_put_stamp_loss_log_dir )

  add_test( NAME cpp-test-shim-full-put-stamp
    COMMAND ${CMAKE_COMMAND}
      -D "COMMAND_TO_RUN=$<TARGET_FILE:cpp-test-shim-full-put-stamp>;${_full_put_stamp_fixture}"
      -D "EXPECTED_STDOUT_SUBSTRINGS=REFUSED DELETE: ids_properties/version_put/data_dictionary;REFUSED WRITE: ids_properties/version_put/data_dictionary"
      -D "LOSS_LOG_DIR=${_full_put_stamp_loss_log_dir}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/verify_full_put_stamp.cmake"
  )
  set_tests_properties( cpp-test-shim-full-put-stamp PROPERTIES
    FIXTURES_REQUIRED "cpp-test-shim-full-put-stamp-fixture;cpp-test-shim-full-put-stamp-loss-log"
    LABELS "shim;contract-assertion"
    ENVIRONMENT "${AL_CPP_SHIM_TEST_ENVIRONMENT};IMAS_MVDD_LOSS_LOG_DIR=${_full_put_stamp_loss_log_dir}"
    FAIL_REGULAR_EXPRESSION "FULL-PUT-STAMP-FAILURE;SCENARIO-FAILURE"
  )
endif()
