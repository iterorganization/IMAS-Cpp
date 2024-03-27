#!/bin/bash
# Bamboo CI script to build and run tests for the C++ HLI
#
# This script expects to be run from the repository root directory

# Debuggging:
set -e -o pipefail
echo "Loading modules..."

# Set up environment such that module files can be loaded
. /usr/share/Modules/init/sh
module purge
# Load modules:
MODULES=(
    CMake/3.24.3-GCCcore-10.2.0
    # Required for building the lowlevel and backends
    Boost/1.74.0-GCC-10.2.0
    HDF5/1.10.7-GCCcore-10.2.0-serial
    MDSplus/7.131.6-GCCcore-10.2.0
    UDA/2.7.5-GCC-10.2.0
    # Required for building MDSplus models
    Saxon-HE/11.4-Java-11
    MDSplus-Java/7.131.6-GCCcore-10.2.0-Java-11
    # Python for documentation
    Python/3.8.6-GCCcore-10.2.0
    # C++ compilers
    intel/2020b
    # Blitz
    Blitz++/1.0.2-GCCcore-10.2.0
)
module load "${MODULES[@]}"

# Debuggging:
echo "Done loading modules"
set -x

# Create a local git configuration with our access token
if [ "x$bamboo_HTTP_AUTH_BEARER_PASSWORD" != "x" ]; then
    mkdir -p git
    echo "[http \"https://git.iter.org/\"]
        extraheader = Authorization: Bearer $bamboo_HTTP_AUTH_BEARER_PASSWORD" > git/config
    export XDG_CONFIG_HOME=$PWD
    git config -l
fi

# Ensure the build directory is clean:
rm -rf build

# CMake configuration:
CMAKE_ARGS=(
    -D "CMAKE_INSTALL_PREFIX=$(pwd)/test-install/"
    # Enable all backends
    -D AL_BACKEND_HDF5=ON
    -D AL_BACKEND_MDSPLUS=ON
    -D AL_BACKEND_UDA=ON
    # Build MDSplus models
    -D AL_BUILD_MDSPLUS_MODELS=ON
    # Download dependencies from HTTPS (using an access token):
    -D AL_DOWNLOAD_DEPENDENCIES=ON
    -D AL_COMMON_GIT_REPOSITORY=https://git.iter.org/scm/imas/al-common.git
    -D AL_LOWLEVEL_GIT_REPOSITORY=https://git.iter.org/scm/imas/al-lowlevel.git
    -D AL_PLUGINS_GIT_REPOSITORY=https://git.iter.org/scm/imas/al-plugins.git
    -D DD_GIT_REPOSITORY=https://git.iter.org/scm/imas/data-dictionary.git
    # DD version: can be set with DD_VERSION env variable, otherwise use latest master/3
    -D DD_VERSION=${DD_VERSION:-master/3}
    # HLI options
    -D AL_EXAMPLES=ON
    -D AL_TESTS=ON
    -D AL_PLUGINS=ON
    # Build documentation
    -D AL_HLI_DOCS=ON
    # Work around Boost linker issues on 2020b toolchain
    -D Boost_NO_BOOST_CMAKE=ON
)
# Note: compilers are set as environment variables in the Bamboo config
cmake -B build "${CMAKE_ARGS[@]}"

# Build
make -C build -j8 al-cpp al-identifiers-cpp al-plugins
# Note: building tests consumes too much memory to have -j8
# cpp-TestSuite is especially large, so compile it without parallelism 
make -C build cpp-TestSuite
# Build anything remaining
make -C build -j4 all

# Create test database, point USER env variable to the test database
rm -rf testdb
export USER="$(pwd)/testdb"
# Test
export ARGS="--output-on-failure --output-junit ctest.xml"
make -C build test

# Test install
make -C build install

# List installed files
ls -lR test-install
