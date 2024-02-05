#!/bin/bash
# Bamboo CI script to build and run tests for all lowlevel components
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
    Boost/1.74.0-GCCcore-10.2.0
    HDF5/1.10.7-GCCcore-10.2.0-serial
    MDSplus/7.96.17-GCCcore-10.2.0
    UDA/2.7.4-GCCcore-10.2.0
    # Required for building MDSplus models
    Saxon-HE/11.4-Java-11
    MDSplus-Java/7.96.17-GCCcore-10.2.0-Java-11
    # C++ compilers
    intel/2020b
    # Blitz
    Blitz++/1.0.2-GCCcore-10.2.0
)
module load "${MODULES[@]}"

# Debuggging:
echo "Done loading modules"
set -x


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
    # "Download" dependencies from repos checked out by Bamboo in the repos/ folder:
    -D AL_DOWNLOAD_DEPENDENCIES=ON
    -D "AL_COMMON_GIT_REPOSITORY=$(pwd)/repos/al-common/"
    -D "AL_LOWLEVEL_GIT_REPOSITORY=$(pwd)/repos/al-lowlevel/"
    -D "AL_PLUGINS_GIT_REPOSITORY=$(pwd)/repos/al-plugins/"
    -D "DD_GIT_REPOSITORY=$(pwd)/repos/data-dictionary/"
    # DD version: can be set with DD_VERSION env variable, otherwise use latest master/3
    -D DD_VERSION=${DD_VERSION:-master/3}
    # HLI options
    -D AL_EXAMPLES=ON
    -D AL_TESTS=ON
    -D AL_PLUGINS=ON
)
# Note: compilers are set as environment variables in the Bamboo config
cmake -B build "${CMAKE_ARGS[@]}"

# Build
# Note: building tests consumes too much memory to have -j8
make -C build -j6 all

# Test
export ARGS="--output-on-failure --output-junit ctest.xml"
make -C build test

# Test install
make -C build install

# List installed files
ls -lR test-install
