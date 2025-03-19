#!/bin/bash
# Bamboo CI script to only build documentation for the C++ HLI
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
# Load modules:
MODULES=(
    CMake/3.27.6-GCCcore-13.2.0
    # Python for documentation
    Python/3.11.5-GCCcore-13.2.0
    # Scipy/numpy
    SciPy-bundle/2023.11-gfbf-2023b
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
    -D AL_DOWNLOAD_DEPENDENCIES=${AL_DOWNLOAD_DEPENDENCIES:-ON}
    -D AL_CORE_GIT_REPOSITORY=${AL_CORE_GIT_REPOSITORY:-https://git.iter.org/scm/imas/al-core.git}
    -D AL_PLUGINS_GIT_REPOSITORY=${AL_PLUGINS_GIT_REPOSITORY:-https://git.iter.org/scm/imas/al-plugins.git}
    -D DD_GIT_REPOSITORY=${DD_GIT_REPOSITORY:-https://git.iter.org/scm/imas/data-dictionary.git}
    # Build only documentation
    -D AL_HLI_DOCS=${AL_HLI_DOCS:-ON}
    -D AL_DOCS_ONLY=${AL_DOCS_ONLY:-ON}
)
# Note: compilers are set as environment variables in the Bamboo config
cmake -B build "${CMAKE_ARGS[@]}"

# Build documentation
make -C build al-cpp-docs
