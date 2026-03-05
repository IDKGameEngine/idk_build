#!/bin/bash

export VANE_SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
export VANE_ROOT_DIR=$(cd ${VANE_SCRIPT_DIR}/../ && pwd)
export VANE_THIRDPARTY_DIR="${VANE_ROOT_DIR}/external"
export VANE_BUILD_DIR="${VANE_ROOT_DIR}/build"
export VANE_OUTPUT_DIR="${VANE_ROOT_DIR}/output"

export THIRDPARTY_PREFIX="${VANE_THIRDPARTY_DIR}/install"

export THIRDPARTY_VK_VERSION="1.4.304.0"
# export THIRDPARTY_VK_VERSION="1.4.341.1"
# source "${VANE_THIRDPARTY_DIR}/repo/vulkan/${THIRDPARTY_VK_VERSION}/setup-env.sh"

export PATH="${PATH}:${THIRDPARTY_PREFIX}/bin"
