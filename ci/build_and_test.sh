#!/bin/bash
# Bamboo CI script to build and run tests for the C++ HLI
#
# This script expects to be run from the repository root directory

# Debuggging:
set -e -o pipefail
echo "Loading modules..."

# Set up environment such that module files can be loaded
if test -f /etc/profile.d/modules.sh ;then
. /etc/profile.d/modules.sh
else
. /usr/share/Modules/init/sh
fi
module purge

# Check for TOOLCHAIN
TOOLCHAIN=${TOOLCHAIN:-foss-2023b}
# Load modules that correspond to toolchain
case "$TOOLCHAIN" in
  *-2023b)
echo "... 2023b"
MODULES=(
    CMake/3.27.6-GCCcore-13.2.0
    Blitz++/1.0.2-GCCcore-13.2.0
    libxml2/2.11.5-GCCcore-13.2.0  # AL-Core
    MDSplus/7.153.3-GCCcore-13.2.0  # backend
    Python/3.11.5-GCCcore-13.2.0  # for docs
)
  ;;&
  *foss-2023b)
echo "... foss-2023b"
MODULES=(${MODULES[@]}
    HDF5/1.14.4.3-gompi-2023b  # backend
    Boost/1.83.0-GCC-13.2.0  # AL-Core
    UDA/2.9.3-GCC-13.2.0  # backend
)
CMAKE_ARGS=(${CMAKE_ARGS[@]}
    -DCMAKE_C_COMPILER=${CC:-gcc}
    -DCMAKE_CXX_COMPILER=${CXX:-g++}
)
  ;;&
  *intel-2023b)
echo "... intel-2023b"
MODULES=(${MODULES[@]}
    HDF5/1.14.3-iimpi-2023b  # backend
    Boost/1.83.0-intel-compilers-2023.2.1  # AL-Core
    UDA/2.9.3-intel-compilers-2023.2.1  # backend
)
CMAKE_ARGS=(${CMAKE_ARGS[@]}
    -DCMAKE_C_COMPILER=${CC:-icx}
    -DCMAKE_CXX_COMPILER=${CXX:-icpx}
)
  ;;
esac
echo "${MODULES[@]}" | tr " " "\n"

module load "${MODULES[@]}"

# Debuggging:
echo "Done loading modules:"
module list
set -x

# Ensure the build directory is clean:
rm -rf build

# CMake configuration:
CMAKE_ARGS=(${CMAKE_ARGS[@]}
  -D "CMAKE_INSTALL_PREFIX=$(pwd)/test-install/"
  # Enable all backends
  -D AL_BACKEND_HDF5=${AL_BACKEND_HDF5:-ON}
  -D AL_BACKEND_MDSPLUS=${AL_BACKEND_MDSPLUS:-ON}
  -D AL_BACKEND_UDA=${AL_BACKEND_UDA:-ON}
  # Build MDSplus models
  -D AL_BUILD_MDSPLUS_MODELS=${AL_BUILD_MDSPLUS_MODELS:-ON}
  # Download dependencies from HTTPS (using an access token):
  -D AL_DOWNLOAD_DEPENDENCIES=${AL_DOWNLOAD_DEPENDENCIES:-ON}
  -D AL_CORE_GIT_REPOSITORY=${AL_CORE_GIT_REPOSITORY:-https://github.com/iterorganization/IMAS-Core.git}
  -D AL_PLUGINS_GIT_REPOSITORY=${AL_PLUGINS_GIT_REPOSITORY:-https://github.com/iterorganization/IMAS-Core-Plugins.git}
  # AL_PLUGINS version: can be set with AL_PLUGINS_VERSION env variable, otherwise use latest develop
  -D AL_PLUGINS_VERSION=${AL_PLUGINS_VERSION:-develop}
  -D DD_GIT_REPOSITORY=${DD_GIT_REPOSITORY:-https://github.com/iterorganization/IMAS-Data-Dictionary.git}
  # DD version: can be set with DD_VERSION env variable, otherwise use latest main
  -D DD_VERSION=${DD_VERSION:-main}
  # AL Core version: can be set with AL_CORE_VERSION env variable, otherwise use latest main
  -D AL_CORE_VERSION=${AL_CORE_VERSION:-main}
  # HLI options
  -D AL_EXAMPLES=${AL_EXAMPLES:-ON}
  -D AL_TESTS=${AL_TESTS:-ON}
  -D AL_PLUGINS=${AL_PLUGINS:-ON}
  # Build documentation
  -D AL_HLI_DOCS=${AL_HLI_DOCS:-ON}
  # Work around Boost linker issues on 2020b toolchain
  -D Boost_NO_BOOST_CMAKE=${Boost_NO_BOOST_CMAKE:-ON}
  -D CMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD:-17}
)
# Note: compilers are set as environment variables in the Bamboo config
cmake -B build "${CMAKE_ARGS[@]}"

# Build
make -C build -j8 al-cpp al-identifiers-cpp al-plugins
# Note: building tests consumes too much memory to have -j8
# cpp-TestSuite is especially large, so compile it without parallelism 
make -C build cpp-TestSuite
# Build anything remaining
make -C build -j2 all

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
