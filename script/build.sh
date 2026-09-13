#!/bin/bash
set -e

THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export IDK_POLY_DIR=$(cd ${THIS_DIR}/../../ && pwd)
# export IDK_SYSROOT_DIR="${IDK_POLY_DIR}/idk"

opt_appname=""
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

    export IDK_ASSETS_DIRNAME="data"

    cd ${IDK_POLY_DIR}/idk_build

    cmake --preset native-debug

    cmake -S . -B  -G Ninja . \
        -DCMAKE_PREFIX_PATH="$IDK_POLY_DIR/idk_build/install" \
        -DIDK_APP_NAME="$opt_appname" \
        -DIDK_POLY_DIR="$IDK_POLY_DIR" \
        -DIDK_CMAKE_DIR="$IDK_CMAKE_DIR" \
        -DIDK_OUTPUT_DIR="$IDK_OUTPUT_DIR" \
        -DIDK_ASSETS_DIRNAME="$IDK_ASSETS_DIRNAME" $cmake_opts
    cmake --build .
    cmake --install .
}

if [[ "$opt_build_type" == "debug" ]]; then
    build_idk "Debug" "$opt_clean"
elif [[ "$opt_build_type" == "release" ]]; then
    build_idk "Release" "$opt_clean"
else
    echo "Must specify --build_type=<debug|release>"
fi
