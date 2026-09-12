#!/bin/bash
set -e

THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export IDK_POLY_DIR=$(cd ${THIS_DIR}/../../ && pwd)
export IDK_SYSROOT_DIR="${IDK_POLY_DIR}/idk"

opt_appname=""
opt_gfxmodel="3D"
opt_platform="SDL3GL"
opt_c_compiler=gcc
opt_cxx_compiler=g++
opt_clean=0
opt_build_type="debug"
opt_run=0
cmake_opts=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --appname=*)
            opt_appname="${1#*=}"
            shift
            ;;
        --gfxmodel=*)
            opt_gfxmodel="${1#*=}"
            shift
            ;;
        --platform=*)
            opt_platform="${1#*=}"
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
        --build_type=*)
            opt_build_type="${1#*=}"
            shift
            ;;
        --run)
            opt_run=1
            shift
            ;;
        --cmakeopts)
            shift
            cmake_opts=("$@")
            shift $#
            ;;
        *)
            echo "Unknown option $1" >&2
            exit 1
            ;;
    esac
done

if [[ "${opt_appname}" == "" ]]; then
    echo "Must specify --appname"
    exit
fi

build_idk()
{
    build_type="$1"
    build_clean="$2"

    IDK_GFX_MODEL="${opt_gfxmodel}"
    IDK_PLATFORM="${opt_platform}"
    export IDK_BUILD_DIR="${IDK_POLY_DIR}/build-${build_type,,}"
    export IDK_CMAKE_DIR="${IDK_BUILD_DIR}/cmake"
    export IDK_OUTPUT_DIR="${IDK_BUILD_DIR}"
    export IDK_ASSETS_DIRNAME="data"

    if [[ "$build_clean" == "1" ]]; then
        rm -rf "${IDK_BUILD_DIR}"
    fi

    mkdir -p "$IDK_CMAKE_DIR" "$IDK_OUTPUT_DIR"
    ${THIS_DIR}/version.sh --header --text

    cd "$IDK_CMAKE_DIR"
    cmake -G Ninja "$IDK_POLY_DIR/idk_build" \
        -DCMAKE_C_COMPILER=$opt_c_compiler \
        -DCMAKE_CXX_COMPILER=$opt_cxx_compiler \
        -DCMAKE_BUILD_TYPE="$build_type" \
        -DCMAKE_PREFIX_PATH="$IDK_SYSROOT_DIR" \
        -DCMAKE_INSTALL_PREFIX="$IDK_OUTPUT_DIR/install" \
        -DIDK_APP_NAME="$opt_appname" \
        -DIDK_POLY_DIR="$IDK_POLY_DIR" \
        -DIDK_CMAKE_DIR="$IDK_CMAKE_DIR" \
        -DIDK_OUTPUT_DIR="$IDK_OUTPUT_DIR" \
        -DIDK_ASSETS_DIRNAME="$IDK_ASSETS_DIRNAME" \
        -DIDK_GFX_MODEL="$IDK_GFX_MODEL" \
        -DIDK_PLATFORM="$IDK_PLATFORM" $cmake_opts
    cmake --build . && cmake --install .
}

if [[ "$opt_build_type" == "debug" ]]; then
    build_idk "Debug" "$opt_clean"
elif [[ "$opt_build_type" == "release" ]]; then
    build_idk "Release" "$opt_clean"
else
    echo "Must specify --build_type=<debug|release>"
fi
