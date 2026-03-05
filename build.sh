#!/bin/bash
set -e

THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

opt_clean=0
opt_debug=0
opt_release=0
opt_run=0

while [[ $# -gt 0 ]]; do
    case $1 in
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



build_idk()
{
    build_type="$1"
    build_clean="$2"

    export IDK_ROOT_DIR=$(cd ${THIS_DIR}/../ && pwd)
    export IDK_BUILD_DIR="${IDK_ROOT_DIR}/build-${build_type,,}/cmake"
    export IDK_OUTPUT_DIR="${IDK_ROOT_DIR}/build-${build_type,,}"

    echo "IDK_ROOT_DIR=${IDK_ROOT_DIR}"
    echo "IDK_BUILD_DIR=${IDK_BUILD_DIR}"
    echo "IDK_OUTPUT_DIR=${IDK_OUTPUT_DIR}"
    echo ""

    if [[ "$build_clean" == "1" ]]; then
        rm -rf "${IDK_BUILD_DIR}"
    fi

    mkdir -p "${IDK_BUILD_DIR}" && cd "${IDK_BUILD_DIR}"
    cmake "${IDK_ROOT_DIR}" -DCMAKE_BUILD_TYPE="${build_type}"
    make -j$(nproc)

    mkdir -p "${IDK_OUTPUT_DIR}"
    mv  "${IDK_BUILD_DIR}/idk_game" "${IDK_OUTPUT_DIR}/"
}


if [[ "$opt_debug" == "0" && "$opt_release" == "0" ]]; then
    opt_release=1
fi

if [[ "$opt_debug" == "1" ]]; then
    build_idk "Debug" "$opt_clean"
fi

if [[ "$opt_release" == "1" ]]; then
    build_idk "Release" "$opt_clean"
fi


# mkdir -p $IDK_OUTPUT_DIR/data
# cp -r $IDK_ROOT_DIR/vane/data/* $IDK_OUTPUT_DIR/data/

# cd $IDK_OUTPUT_DIR/data/shader
# $VANE_SCRIPT_DIR/glslc.sh -C *.vert *.frag *.comp

