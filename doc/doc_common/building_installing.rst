Building and installing the IMAS C++ HLI
=========================================

This page describes how to build and install the IMAS C++ High Level Interface.

Documentation for developers wishing to contribute to the IMAS C++ HLI can be found in
the :doc:`dev_guide`. Please refer to that guide if you wish to set
up a development environment.

For more information about related components, see:

-   `IMAS Core Documentation <https://imas-core.readthedocs.io/en/latest/>`__
-   `IMAS Data Dictionary Documentation <https://imas-data-dictionary.readthedocs.io/en/latest/>`__


.. _`build prerequisites`:

Prerequisites
-------------

To build the IMAS C++ HLI you need:

-   Git
-   A C++11 compiler (tested with GCC and Intel compilers)
-   CMake (3.16 or newer)
-   Boost C++ libraries (1.66 or newer)
-   PkgConfig
-   Python 3.11 or newer (for XSLT processing with saxonche)
-   Saxon-HE (for XSLT 2.0 transformations)

The following dependencies are only required for some of the components:

-   Backends

    -   **HDF5 backend**: HDF5 C/C++ libraries (1.8.12 or newer)
    -   **MDSplus backend**: MDSplus libraries (7.84.8 or newer)
    -   **UDA backend**: `UDA <https://github.com/ukaea/UDA/>`__ libraries
	(2.7.5 or newer) [#uda_install]_

..  [#uda_install] When installing UDA, make sure you have 
    `Cap'n'Proto <https://github.com/capnproto/capnproto>`__ installed in your system
    and add its support by adding the CMake switch `-DENABLE_CAPNP=ON` when configuring UDA.




Standard environments:

.. md-tab-set::

    .. md-tab-item:: SDCC ``intel-2023b``

        The following modules provide all the requirements when using the
        ``intel-2023b`` toolchain:

        .. code-block:: bash

            module load intel-compilers/2023.2.1 CMake/3.27.6-GCCcore-13.2.0 Saxon-HE/12.4-Java-21 \
                Boost/1.83.0-iimpi-2023b HDF5/1.14.3-iimpi-2023b \
                MDSplus/7.132.0-GCCcore-13.2.0 \
                UDA/2.8.1-iimpi-2023b Blitz++/1.0.2-GCCcore-13.2.0 \
                SciPy-bundle/2023.11-intel-2023b

    .. md-tab-item:: SDCC ``foss-2023b``

        The following modules provide all the requirements when using the
        ``foss-2023b`` toolchain:

        .. code-block:: bash

            module load CMake/3.27.6-GCCcore-13.2.0 Saxon-HE/12.4-Java-21 \
                Boost/1.83.0-GCC-13.2.0 HDF5/1.14.3-gompi-2023b \
                MDSplus/7.132.0-GCCcore-13.2.0 \
                UDA/2.8.1-GCC-13.2.0 Blitz++/1.0.2-GCCcore-13.2.0 \
                SciPy-bundle/2023.11-gfbf-2023b

    .. md-tab-item:: Ubuntu 22.04

        The following packages provide most requirements when using Ubuntu 22.04:

        .. code-block:: bash

            apt install git build-essential cmake libsaxonhe-java libboost-all-dev \
                pkg-config libhdf5-dev xsltproc libblitz0-dev gfortran \
                default-jdk-headless python3-dev python3-venv python3-pip

        The following dependencies are not available from the package repository,
        you will need to install them yourself:

        -   MDSplus: see their `GitHub repository
            <https://github.com/MDSplus/mdsplus>`__ or `home page
            <https://mdsplus.org/>`__ for installation instructions.
        -   UDA: see their `GitHub repository <https://github.com/ukaea/UDA>`__ for more
            details.


Building and installing the C++ High Level Interface
-----------------------------------------------------

This section explains how to install the C++ High Level Interface. Please make sure you
have the :ref:`build prerequisites` installed.


Clone the repository
````````````````````

First you need to clone the repository:

.. code-block:: bash

    git clone git@github.com:iterorganization/IMAS-Cpp.git


Configuration
`````````````

Once you have cloned the repository, navigate your shell to the folder and run cmake.
You can pass configuration options with ``-D OPTION=VALUE``. See below list for an
overview of configuration options.

.. code-block:: bash

    cd IMAS-Cpp
    cmake -B build -D CMAKE_INSTALL_PREFIX=$HOME/al-install -D OPTION1=VALUE1 -D OPTION2=VALUE2 [...]

.. note:: 

    CMake will automatically fetch dependencies from other IMAS GIT repositories
    for you. You may need to provide credentials to clone the following repositories:

    -   `al-core (git@github.com:iterorganization/IMAS-Core.git)
        <https://github.com/iterorganization/IMAS-Core>`__
    -   `al-plugins (https://github.com/iterorganization/al-plugins.git)
        <https://github.com/iterorganization/al-plugins>`__
    -   `imas-data-dictionary (git@github.com:iterorganization/IMAS-Data-Dictionary.git)
        <https://github.com/iterorganization/IMAS-Data-Dictionary>`__

    If you need to change the git repositories, for example to point to a mirror of the
    repository or to use a HTTPS URL instead of the default SSH URLs, you can update the
    :ref:`configuration options`. For example, add the following options to your
    ``cmake`` command to download the repositories over HTTPS instead of SSH:
    
    .. code-block:: text
        :caption: Use explicit options to download dependent repositories over HTTPS

        cmake -B build \
            -D AL_CORE_GIT_REPOSITORY=git@github.com:iterorganization/IMAS-Core.git \
            -D AL_PLUGINS_GIT_REPOSITORY=git@github.com:iterorganization/al-plugins.git \
            -D DD_GIT_REPOSITORY=git@github.com:iterorganization/IMAS-Data-Dictionary.git

    If you use CMake 3.21 or newer, you can also use the ``https`` preset:

    .. code-block:: text
        :caption: Use CMake preset to set to download dependent repositories over HTTPS

        cmake -B build --preset=https


Choosing the compilers
''''''''''''''''''''''

You can instruct CMake to use compilers with the following environment variables:

-   ``CC``: C compiler, for example ``gcc`` or ``icc``.
-   ``CXX``: C++ compiler, for example ``g++`` or ``icpc``.

If you don't specify a compiler, CMake will take a default (usually from the Gnu
Compiler Collection).

.. important::

    These environment variables must be set before the first time you configure
    ``cmake``!

    If you have an existing ``build`` folder and want to use a different compiler, you
    should delete the ``build`` folder first, or use a differently named folder for the
    build tree.


Configuration options
'''''''''''''''''''''

For a complete list of available configuration options, please see the `IMAS Core Configuration Options <https://imas-core.readthedocs.io/en/latest/user_guide/installation.html#configuration-options>`__.


Build the High Level Interface
``````````````````````````````

Use ``make`` to build everything. You can speed things up by using parallel compiling
as shown with the ``-j`` option. Be careful with the amount of parallel processes
though: it's easy to exhaust your machine's available hardware (CPU or memory) which may
cause the build to fail. This is especially the case with the C++ High Level Interface.

.. code-block:: bash

    # Instruct make to build "all" in the "build" folder, using at most "8" parallel
    # processes:
    make -C build -j8 all

.. note::

    By default CMake on Linux will create ``Unix Makefiles`` for actually building
    everything, as assumed in this section.

    You can select different generators (such as Ninja) if you prefer, but these are not
    tested. See the `CMake documentation
    <https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html>`__ for more
    details.


Optional: Test the High Level Interface
```````````````````````````````````````

If you set either of the options ``AL_EXAMPLES`` or ``AL_TESTS`` to ``ON``, you can run
the corresponding test programs as follows:

.. code-block:: bash

    # Use make:
    make -C build test
    # Directly invoke ctest
    ctest --test-dir build

.. note::

    The `ids_path` environment variable used to locate MDSplus models has been renamed to
    `MDSPLUS_MODELS_PATH` in IMAS-Core 5.6.0 and later. Set it as follows:

    .. code-block:: bash

        export MDSPLUS_MODELS_PATH=/path/to/your/mdsplus/models


This executes ``ctest`` to run all test and example programs. Note that this may take a
long time to complete.


Install the High Level Interface
````````````````````````````````

Run ``make install`` to install the high level interface in the folder that you chose in
the configuration step above.


Use the High Level Interface
````````````````````````````

After installing the HLI, you need to ensure that your code can find the installed
IMAS C++ HLI. To help you with this, a file ``al_env.sh`` is installed. You can
``source`` this file to set all required environment variables:

.. code-block:: bash
    :caption: Set environment variables (replace ``<install_dir>`` with your install folder)

    source <install_dir>/bin/al_env.sh

You may want to add this to your ``$HOME/.bashrc`` file to automatically make the Access
Layer installation available for you.

.. note:: 

    To use a ``public`` dataset, you also need to set the ``IMAS_HOME`` environment
    variable. For example, on SDCC, this would be ``export IMAS_HOME=/work/imas``.

    Some programs may rely on an environment variable ``IMAS_VERSION`` to detect which
    version of the data dictionary is used in the current IMAS environment. You may set
    it manually with the DD version you've build the HLI with, for example: ``export
    IMAS_VERSION=3.41.0``.

Once you have set the required environment variables, you can start using the C++ HLI.
See :doc:`getting_started` for a quick introduction.


Troubleshooting
```````````````

**Problem:** ``Target Boost::log already has an imported location``
    This problem is known to occur with the ``2020b`` toolchain on SDCC. Add the CMake
    configuration option ``-D Boost_NO_BOOST_CMAKE=ON`` to work around the problem.

