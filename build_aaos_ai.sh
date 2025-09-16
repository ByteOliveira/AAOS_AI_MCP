#!/bin/bash
#
# build_aaos_ai.sh
#
# This script checks out the Android Automotive OS source tree, integrates
# an AI MCP host app, and builds boot, system and vendor images.  It
# assumes you are running on a Linux machine with the standard AOSP
# build dependencies installed.
#
# Usage:
#   ./build_aaos_ai.sh [workdir]
#
# The optional `workdir` argument specifies where the AAOS sources
# should be synced.  If omitted, a `aaos_src` directory will be
# created next to this script.

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
WORKDIR=${1:-"${SCRIPT_DIR}/aaos_src"}

# Change these variables to point at the branch and lunch target you
# wish to build.  android-13.0.0_r35 corresponds to an AAOS release
# used by the community Raspberry Pi port【886674710982981†L90-L116】.  Other
# branches (for example, android-14.0.0_r1) may also work.
MANIFEST_URL="https://android.googlesource.com/platform/manifest"
AAOS_BRANCH="${AAOS_BRANCH:-android-13.0.0_r35}"
AAOS_TARGET="${AAOS_TARGET:-aosp_car_x86_64-userdebug}"

echo "==> Using branch: ${AAOS_BRANCH}"
echo "==> Using lunch target: ${AAOS_TARGET}"
echo "==> Working directory: ${WORKDIR}"

# Ensure the working directory exists.
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

###############################################################################
# Install or locate the `repo` tool.  Android source trees are composed of
# hundreds of Git repositories; the `repo` tool coordinates their checkout.
###############################################################################
if ! command -v repo >/dev/null 2>&1; then
  echo "==> Installing repo launcher into temporary directory"
  TMP_REPO="${WORKDIR}/tmp_repo"
  mkdir -p "${TMP_REPO}"
  curl -fsSL "https://storage.googleapis.com/git-repo-downloads/repo" -o "${TMP_REPO}/repo"
  chmod +x "${TMP_REPO}/repo"
  export PATH="${TMP_REPO}:${PATH}"
fi

###############################################################################
# Initialise the Android repository.  The --depth=1 flag performs a shallow
# clone to save time and space; remove it if you need full history.
###############################################################################
if [ ! -d .repo ]; then
  echo "==> Initialising the repo client"
  repo init -u "${MANIFEST_URL}" -b "${AAOS_BRANCH}" --depth=1
fi

###############################################################################
# Sync the sources.  Passing -c uses the manifest's current branch rather than
# checking out all history.  Adjust the -j value to match your CPU cores.
###############################################################################
echo "==> Syncing the Android source tree (this may take a while)"
repo sync -c -j$(nproc)

###############################################################################
# Integrate the AI MCP host.  We copy the local `ai_mcp_host` directory
# contained in this repository into the appropriate location within
# the source tree.  If you wish to maintain the AI host in its own
# repository, you can instead add it via a local manifest entry.
###############################################################################
AI_SRC_DIR="${SCRIPT_DIR}/ai_mcp_host"
TARGET_APP_DIR="${WORKDIR}/packages/apps/ai_mcp_host"

echo "==> Integrating AI MCP host app"
rm -rf "${TARGET_APP_DIR}"
mkdir -p "$(dirname "${TARGET_APP_DIR}")"
cp -r "${AI_SRC_DIR}" "${TARGET_APP_DIR}"

###############################################################################
# Build the OS.  The `build/envsetup.sh` script sets up the environment for
# building.  `lunch` selects the device configuration, and `make` performs
# the compilation.  We build boot, system and vendor images only.  If you
# need additional images (such as super or vbmeta), modify the make targets.
###############################################################################

echo "==> Setting up build environment"
source build/envsetup.sh
lunch "${AAOS_TARGET}"

echo "==> Starting the build (bootimage systemimage vendorimage)"
make bootimage systemimage vendorimage -j$(nproc)

echo "==> Build completed.  Images are located under out/target/product/$(basename "${AAOS_TARGET}" | cut -d- -f1)"
