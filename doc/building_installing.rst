.. include:: ./doc_common/building_installing.rst

Using the multiversion shim
--------------------------

To route the existing C ABI calls through IMAS-Multiversion-DD-Loader, configure
with its installation prefix::

    cmake -B build-shim \
      -DAL_USE_MULTIVERSION_SHIM=ON \
      -DCMAKE_PREFIX_PATH=/path/to/shim/prefix
    cmake --build build-shim --target al-cpp al-identifiers-cpp

``AL_USE_MULTIVERSION_SHIM`` defaults to ``OFF``. When enabled, ``al-cpp`` links
to the shim instead of IMAS-Core. The normal dependency options still select the
Data Dictionary and acquire IMAS-Core: C++ needs Core's headers, and the shim
loads its shared library at runtime. A Core built as part of this project is
also built by the ``al-cpp`` target. Use a shared Core library for this mode.
The installed C++ pkg-config file requires ``imas-mvdd-loader`` and does not
add Core to the link line.

Before running an application, select the real Core library and report the DD
version used to build the C++ HLI::

    export IMAS_CORE_LIBRARY=/path/to/real/core/lib/libal.so
    export IMAS_MVDD_HLI_DD_VERSION=4.1.1

On macOS the Core library is ``libal.dylib``. The first variable may be omitted
when Core is on the dynamic loader's search path. Set the second variable to
your actual build's DD version; without it the shim forwards calls unchanged
and does not perform DD conversion. Conversion support is determined by the
maps shipped with the shim. No new shim functions are wrapped by this option.

CTest sets both variables itself: when Core is built as part of this project it
lives in the build tree rather than on the loader's search path, so the test
environment names it explicitly. Without that, every mirrored call fails —
``getALVersion()`` returns ``NULL`` and ``al_begin_dataentry_action`` reports an
error. When Core comes from an installed prefix, only the DD version is set and
the library is expected on the loader's search path.

For an installed C++ library, also make the shim's ``lib`` directory available
to the dynamic loader and its ``lib/pkgconfig`` directory available through
``PKG_CONFIG_PATH``.

Refused writes and deletes
--------------------------

When the shim refuses an individual field while writing or deleting, ``put``,
``putSlice`` and ``deleteAll`` keep traversing the remaining fields. They return
``IdsNs::PARTIAL_PUT`` and expose each skipped path through
``getSkippedPaths()``; records are tagged as ``Write`` or ``Delete`` and are
cleared at the next root write or delete. The operation also prints one
``REFUSED WRITE:`` or ``REFUSED DELETE:`` line per skipped path.

This is intentionally best effort. In particular, a refusal partway through
``putSlice`` does not roll back earlier writes or the array-of-structures
resize; data already written remains on disk.
