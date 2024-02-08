#!/bin/bash
# Bamboo CI script to only build documentation for the C++ HLI
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
    # Python for documentation
    Python/3.8.6-GCCcore-10.2.0
    # Scipy/numpy
    SciPy-bundle/2020.11-intel-2020b
)
module load "${MODULES[@]}"

# Debuggging:
echo "Done loading modules"
set -x


# Ensure the build directory is clean:
rm -rf build

# CMake configuration:
CMAKE_ARGS=(
    # Disable all backends
    -D AL_BACKEND_HDF5=OFF
    -D AL_BACKEND_MDSPLUS=OFF
    -D AL_BACKEND_UDA=OFF
    # "Download" dependencies from repos checked out by Bamboo in the repos/ folder:
    -D AL_DOWNLOAD_DEPENDENCIES=ON
    -D "AL_COMMON_GIT_REPOSITORY=$(pwd)/../al-common/"
    -D "AL_LOWLEVEL_GIT_REPOSITORY=$(pwd)/../al-lowlevel/"
    -D "AL_PLUGINS_GIT_REPOSITORY=$(pwd)/../al-plugins/"
    -D "DD_GIT_REPOSITORY=$(pwd)/../data-dictionary/"
    # DD version: can be set with DD_VERSION env variable, otherwise use latest master/3
    -D DD_VERSION=${DD_VERSION:-master/3}
    # HLI options
    -D AL_EXAMPLES=OFF
    -D AL_TESTS=OFF
    -D AL_PLUGINS=ON
    # Build documentation
    -D AL_HLI_DOCS=ON
)
# Note: compilers are set as environment variables in the Bamboo config
cmake -B build "${CMAKE_ARGS[@]}"

# Build documentation
make -C build al-cpp-docs
