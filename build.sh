#!/bin/bash
set -e

THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

opt_target=""
opt_clean=0
opt_debug=0
opt_release=0
opt_run=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --target)
            opt_target="$2"
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


export IDK_ROOT_DIR=$(cd ${THIS_DIR}/../ && pwd)

if [[ "${opt_target}" == "" ]]; then
    echo "Must supply --target"
    exit
fi

if [[ ! -d "${IDK_ROOT_DIR}/${opt_target}" ]]; then
    echo "No such target: ${IDK_ROOT_DIR}/${opt_target}"
    exit
fi



build_idk()
{
    target_name="$1"
    build_type="$2"
    build_clean="$3"

    IDK_TARGET_NAME="${target_name}"
    IDK_TARGET_DIR="${IDK_ROOT_DIR}/${IDK_TARGET_NAME}"
    IDK_BUILD_DIR="${IDK_ROOT_DIR}/build-${build_type,,}/cmake"
    IDK_OUTPUT_DIR="${IDK_ROOT_DIR}/build-${build_type,,}"

    if [[ "$build_clean" == "1" ]]; then
        rm -rf "${IDK_OUTPUT_DIR}"
    fi

    mkdir -p "${IDK_BUILD_DIR}" && cd "${IDK_BUILD_DIR}"
    cmake "${IDK_ROOT_DIR}/idk_build" \
        -DCMAKE_BUILD_TYPE="${build_type}" \
        -DIDK_ROOT_DIR="${IDK_ROOT_DIR}" \
        -DIDK_BUILD_DIR="${IDK_BUILD_DIR}" \
        -DIDK_OUTPUT_DIR="${IDK_OUTPUT_DIR}" \
        -DIDK_TARGET_NAME="${IDK_TARGET_NAME}"
    make -j$(nproc)

    cd $IDK_OUTPUT_DIR/assets/gfx/shader
    PATH="${PATH}:${THIS_DIR}/install/bin"
    $THIS_DIR/script/glslc.sh -C *.vert *.frag *.comp

    for stage in vert frag comp; do
        for file in *."$stage"; do
            rm "${file}"
        done
    done
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


# mkdir -p $IDK_OUTPUT_DIR/data
# cp -r $IDK_ROOT_DIR/vane/data/* $IDK_OUTPUT_DIR/data/

# cd $IDK_OUTPUT_DIR/data/shader
# $VANE_SCRIPT_DIR/glslc.sh -C *.vert *.frag *.comp

