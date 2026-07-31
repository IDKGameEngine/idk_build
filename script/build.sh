#!/bin/bash
set -e

THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export IDK_POLY_DIR=$(cd ${THIS_DIR}/../../ && pwd)
export IDK_ROOT_DIR="${IDK_POLY_DIR}/idk"

opt_target=""
opt_gfxmodel="3D"
opt_c_compiler=gcc
opt_cxx_compiler=g++
opt_clean=0
opt_debug=0
opt_release=0
opt_run=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --target=*)
            opt_target="${1#*=}"
            shift
            ;;
        --gfxmodel=*)
            opt_gfxmodel="${1#*=}"
            shift
            ;;
        --c_compiler)
            opt_c_compiler=$2
            shift
            shift
            ;;
        --cxx_compiler)
            opt_cxx_compiler=$2
            shift
            shift
            ;;
        --clean)
            opt_clean=1
            shift
            ;;
        --debug)
            opt_debug=1
            shift
            ;;
        --release)
            opt_release=1
            shift
            ;;
        --run)
            opt_run=1
            shift
            ;;
        *)
            echo "Unknown option $1" >&2
            exit 1
            ;;
    esac
done

if [[ "${opt_target}" == "" ]]; then
    echo "Must supply --target"
    exit
fi

if [[ ! -d "${IDK_POLY_DIR}/${opt_target}" ]]; then
    echo "No such target: ${IDK_POLY_DIR}/${opt_target}"
    exit
fi

build_idk()
{
    target_name="$1"
    build_type="$2"
    build_clean="$3"

    IDK_TARGET_NAME="${target_name}"
    IDK_TARGET_DIR="${IDK_POLY_DIR}/${IDK_TARGET_NAME}"
    IDK_GFX_MODEL="${opt_gfxmodel}"
    export IDK_BUILD_DIR="${IDK_POLY_DIR}/build-${build_type,,}"
    export IDK_CMAKE_DIR="${IDK_BUILD_DIR}/cmake"
    export IDK_OUTPUT_DIR="${IDK_BUILD_DIR}"
    export IDK_ASSETS_DIRNAME="assets"

    if [[ "$build_clean" == "1" ]]; then
        rm -rf "${IDK_BUILD_DIR}"
    fi

    mkdir -p "$IDK_CMAKE_DIR" "$IDK_OUTPUT_DIR"
    cd "$IDK_CMAKE_DIR"

    cmake -G Ninja "$IDK_POLY_DIR/idk_build" \
        -DCMAKE_C_COMPILER=$opt_c_compiler \
        -DCMAKE_CXX_COMPILER=$opt_cxx_compiler \
        -DCMAKE_BUILD_TYPE="$build_type" \
        -DCMAKE_PREFIX_PATH="$IDK_ROOT_DIR" \
        -DCMAKE_INSTALL_PREFIX="$IDK_OUTPUT_DIR/install" \
        -DIDK_POLY_DIR="$IDK_POLY_DIR" \
        -DIDK_CMAKE_DIR="$IDK_CMAKE_DIR" \
        -DIDK_OUTPUT_DIR="$IDK_OUTPUT_DIR" \
        -DIDK_ASSETS_DIRNAME="$IDK_ASSETS_DIRNAME" \
        -DIDK_TARGET_NAME="$IDK_TARGET_NAME" \
        -DIDK_GFX_MODEL="$IDK_GFX_MODEL"
    cmake --build . && cmake --install .

    cp $IDK_OUTPUT_DIR/version.txt $IDK_POLY_DIR/idk_build/version.txt
}

if [[ "$opt_debug" == "0" && "$opt_release" == "0" ]]; then
    opt_release=1
fi

if [[ "$opt_debug" == "1" ]]; then
    build_idk "$opt_target" "Debug" "$opt_clean"
fi

if [[ "$opt_release" == "1" ]]; then
    build_idk "$opt_target" "Release" "$opt_clean"
fi

