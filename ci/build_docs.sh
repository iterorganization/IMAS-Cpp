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
    # Download dependencies from HTTPS (using an access token):
    -D AL_DOWNLOAD_DEPENDENCIES=ON
    -D AL_COMMON_GIT_REPOSITORY=https://git.iter.org/scm/imas/al-common.git
    -D AL_CORE_GIT_REPOSITORY=https://git.iter.org/scm/imas/al-core.git
    -D AL_PLUGINS_GIT_REPOSITORY=https://git.iter.org/scm/imas/al-plugins.git
    -D DD_GIT_REPOSITORY=https://git.iter.org/scm/imas/data-dictionary.git
    # Build only documentation
    -D AL_HLI_DOCS=ON
    -D AL_DOCS_ONLY=ON
)
# Note: compilers are set as environment variables in the Bamboo config
cmake -B build "${CMAKE_ARGS[@]}"

# Build documentation
make -C build al-cpp-docs
