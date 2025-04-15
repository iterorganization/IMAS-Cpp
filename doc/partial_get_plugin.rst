.. _partial_get_plugin:

Partial Get Plugin Documentation for Access Layer 5 (AL5)
=========================================================

Overview
--------
The **Partial Get Plugin** is a C++ plugin for the Access Layer 5 (AL5) framework, designed to selectively retrieve data from an IMAS IDS (Interface Data Structure) based on user-defined ``includes`` and ``excludes`` queries. This document provides instructions for setup, compilation, and usage, along with detailed examples and syntax for query construction. The plugin operates on the ``core_profiles`` IDS in the provided example but can be adapted to other IDS structures.

For a comprehensive understanding of the AL5 plugin mechanism, refer to the official `AL5 documentation`.

Environment Setup
-----------------
To build and configure the C++ High Level Interface, please refer to :doc:`index`.

Some important points regarding configuration and compilation for using plugins are recalled below.

To enable and use the Partial Get Plugin, set the following environment variables before running the examples:

.. code-block:: bash

   export IMAS_AL_ENABLE_PLUGINS=TRUE
   export IMAS_AL_PLUGINS=$HOME/AL_repos/al-cpp/build/_deps/al-plugins-build/

* **``IMAS_AL_ENABLE_PLUGINS``**: Must be set to ``TRUE`` to activate plugin support.
* **``IMAS_AL_PLUGINS``**: Must point to the directory containing the compiled plugin shared library (e.g., ``partial_get_plugin.so``), typically located in ``$HOME/AL_repos/al-cpp/build/_deps/al-plugins-build/`` after compilation.

Compilation Instructions
------------------------
To compile the C++ High-Level Interface (HLI) with plugin support, use for example the following ``cmake`` command:

.. code-block:: bash

   cmake -B build \
     -DAL_DOWNLOAD_DEPENDENCIES=OFF \
     -DAL_PLUGINS=ON \
     -DCMAKE_INSTALL_PREFIX=~/al-install/ \
     -DAL_DEVELOPMENT_LAYOUT=ON \
     -DCMAKE_BUILD_TYPE=Debug

* **Key Flag**: ``-DAL_PLUGINS=ON`` enables plugin support. Ensure this is set when building the project.

Using the C++ HLI
~~~~~~~~~~~~~~~~~
The C++ HLI offers two API functions for getting partial data according to user queries:

.. code-block:: cpp

   int partialGet(const std::string &includes, const std::string &excludes, bool debug=false);
   int partialGet(int occ, const std::string &includes, const std::string &excludes, bool debug=false);

The first version applies on occurrence 0. The second version applies on any occurrence ``occ`` of the IDS.
The ``partialGet()`` operation populates an IDS instance with partial data filtered by the ``includes`` and ``excludes`` queries.
A boolean ``debug`` argument allows to debug queries. The debug messages are written to the standard error output.

.. admonition:: Technical note

    The partialGet implementation registers the ``partial-get plugin``, executes the ``get()`` operation, then unregisters the plugin.

    **Plugin Registration and Configuration** 
    .. code-block:: c++
        al_status_t status = al_register_plugin(PARTIAL_GET); // Register the plugin

        std::string includes = "ids_properties;profiles_1d(1:5:2)/ion(1:4:2)"; // Define include and exclude queries
        std::string excludes = "profiles_1d(1)";

        int size = includes.size();

        status = al_setvalue_parameter_plugin("includes", CHAR_DATA, 1, &size, (void*)includes.data(), PARTIAL_GET); // Pass the includes queries to the plugin

        size = excludes.size();

        status = al_setvalue_parameter_plugin("excludes", CHAR_DATA, 1, &size, (void*)excludes.data(), PARTIAL_GET); // Pass excludes queries to the plugin

        status = al_bind_plugin("core_profiles:0/*", PARTIAL_GET);  // Bind the plugin to the 'core_profiles' IDS, occurrence 0, all nodes

    * **Registration**: ``al_register_plugin(PARTIAL_GET)`` registers the plugin with the AL5 framework.
    * **Query Configuration**: ``includes`` and ``excludes`` queries are passed as parameters using ``al_setvalue_parameter_plugin``. These define which data to retrieve or exclude.
    * **Binding**: ``al_bind_plugin("core_profiles:0/*", PARTIAL_GET)`` applies the plugin to all nodes under the ``core_profiles`` IDS, occurrence 0.

    **Data Retrieval**
    .. code-block:: c++
        cp.get();    // calls get() operation to retrieve partial data based on the plugin's queries

        status = al_unregister_plugin(PARTIAL_GET); //unregisters the plugin

        * **Execution**: The ``get()`` operation populates the ``cp`` IDS instance with partial data filtered by the ``includes`` and ``excludes`` queries.

Using partialGet, C++ Code Example
----------------------------------
.. code-block:: c++

   // Define include and exclude queries
   std::string includes = "ids_properties;profiles_1d(1:5:2)/ion(1:4:2)";
   std::string excludes = "";

   IDS::core_profiles cp = data_entry._core_profiles; // Declare the IDS instance
   cp.partialGet(includes, excludes);

* **Execution**: The ``partialGet()`` operation populates the ``cp`` instance with partial data filtered by the ``includes`` and ``excludes`` queries.

Query Syntax and Examples
-------------------------
Queries for ``includes`` and ``excludes`` follow a specific syntax based on the IMAS Data Dictionary (DD) paths. They are semicolon-separated (``;``) lists of paths that can target arrays of structures (AOS) or individual structures or individual fields.

Syntax Rules
~~~~~~~~~~~~
1. **Array of Structures (AOS) Queries**:
   - **Format**: ``aos_name(mi:ma:k)``
     - ``mi``: Minimum index (≥ 1).
     - ``ma``: Maximum index (≥ 1).
     - ``k``: Increment (≥ 0).
     - Selects indices ``mi, mi+k, mi+2*k, ..., mi+n*k`` where ``mi+n*k ≤ ma``.

   - **Example**: ``profiles_1d(1:3:1)`` → Selects indices ``{1, 2, 3}``.
   - **All Elements**: ``aos_name(:)`` (e.g., ``profiles_1d(:)``).
   - **Nested AOS**: Use ``/`` to separate levels (e.g., ``profiles_1d(1:5:2)/ion(1:4:2)``).
   - **Effect**:
     - In ``includes``: Returns all data under ``aos_name(i)/`` for each selected index ``i``.
     - In ``excludes``: Excludes all data under ``aos_name(i)/`` for each selected index ``i``.

2. **Structure Queries**:
   - **Format**: ``structure_name`` or ``parent_structure/structure_name``.
   - **Example**: ``ids_properties`` or ``profiles_1d(:)/grid``.
   - **Effect**:
     - In ``includes``: Returns all data under ``structure_name/``.
     - In ``excludes``: Excludes all data under ``structure_name/``.

3. **Field Queries**:
   - **Format**: ``field_name`` or ``parent_structure/field_name``.
   - **Example**: ``time`` or ``profiles_1d(:)/time``.
   - **Effect**:
     - In ``includes``: Returns only the field data from ``field_name``.
     - In ``excludes``: Excludes only the field data from ``field_name``.

4. **Notes**:
   - Indices follow Fortran convention (start at 1).
   - The plugin does not validate paths against the DD but requires correct AOS syntax (e.g., indices must be specified).
   - ``excludes`` must be a subset of ``includes``.
   - If ``includes`` is empty, all data are returned by default (except data excluded by ``excludes`` queries).

Examples for ``core_profiles`` IDS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.. list-table::
   :widths: 40 60
   :header-rows: 1

   * - Query
     - Description
   * - ``"ids_properties"``
     - Returns all data in the ``ids_properties`` structure.
   * - ``"profiles_1d(1:3:1)"``
     - Returns data for ``profiles_1d`` elements at indices 1, 2, and 3 (i.e., ``profiles_1d(1)/``, etc.).
   * - ``"profiles_1d(1:3)"``
     - Same effect as ``"profiles_1d(1:3:1)"``.
   * - ``"profiles_1d(3:)"``
     - Returns data for ``profiles_1d`` elements for indices >=3.
   * - ``"profiles_1d(::10)"``
     - Returns data for ``profiles_1d`` elements for indices >=1 with step 10 (i.e., ``profiles_1d(1)/``, ``profiles_1d(11)/``, ``profiles_1d(21)/``, etc.).
   * - ``"ids_properties;profiles_1d(1:3:1)"``
     - Combines the above: includes ``ids_properties`` and ``profiles_1d`` at indices 1, 2, and 3.
   * - ``"ids_properties;profiles_1d(:)/ion(1:4:2)"``
     - Includes ``ids_properties`` and ``ion`` elements at indices 1 and 3 for all ``profiles_1d`` elements.
   * - ``"ids_properties;profiles_1d(1:5:2)/ion(1:4:2)"``
     - Includes ``ids_properties`` and ``ion`` at indices 1 and 3 for ``profiles_1d`` at indices 1, 3, 5.
   * - ``"ids_properties;profiles_1d(1:5:2)/ion(1:4:2);profiles_1d"``
     - Adds all ``profiles_1d`` data (0D-6D datasets and structures) beyond the specific ``ion`` elements.
   * - ``"ids_properties;profiles_1d(:)/grid"``
     - Includes ``ids_properties`` and the ``grid`` structure for all ``profiles_1d`` elements.
   * - ``"ids_properties;profiles_1d(1:5:2)/ion(1:4:2);profiles_1d(1:5:2)/grid"``
     - Combines ``ion`` at indices 1 and 3, ``grid`` for ``profiles_1d`` at indices 1, 3, 5, and ``ids_properties``.

.. note::

   The shapes of (included) arrays of structures (AOS) are never modified. However, the AOS elements not included by the user queries are not set.

Technical Notes
---------------
1. **Query Concatenation**: Multiple paths in ``includes`` or ``excludes`` are separated by ``;``. Each path must align with DD conventions since the plugin does not perform validation against the Data Dictionary.
2. **AOS Requirement**: For AOS queries, indices must always be specified (e.g., ``profiles_1d(:)`` for all elements). Invalid queries like ``profiles_1d/ion(1:4:2)`` (missing ``profiles_1d`` indices) are not supported.
3. **Excludes Subset**: Data in ``excludes`` must be a subset of ``includes`` to be effective.
4. **PathManager component**: Internally, the plugin uses ``PathManager`` to evaluate paths:

   - ``isInSet``: Checks if a specific path is in the included set ``E``.
   - ``is_included``: Verifies if an AOS has at least one element in ``E``.

   Definition of the ``E`` space:
   The ``E`` space represents the set of all valid paths as defined by the "includes" queries
   minus the paths explicitly removed by the "excludes" queries. A path is considered
   to be in ``E`` if it matches at least one include query and does not match any exclude
   query. This concept is used to determine whether a specific path
   or AOS is included in the managed set of paths.

Troubleshooting
---------------
- **Plugin Not Loading**: Verify ``IMAS_AL_PLUGINS`` points to the correct directory and that ``partial_get_plugin.so`` exists.
- **No Data Returned**: Check query syntax. Enable ``debug`` mode to check if the field is excluded by the plugin.

   .. code-block:: cpp

      // Define include and exclude queries
      std::string includes = "ids_properties;profiles_1d(1:5:2)/ion(1:4:2)";
      std::string excludes = "";

      IDS::core_profiles cp = data_entry._core_profiles; // Declare the IDS instance
      cp.partialGet(includes, excludes, true); // debug is enabled