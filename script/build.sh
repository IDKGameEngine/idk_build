#!/bin/bash
set -e

THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IDK_ROOT_DIR=$(cd ${THIS_DIR}/../../ && pwd)

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
    IDK_OUTPUT_DIR="${IDK_ROOT_DIR}/build-${build_type,,}"
    IDK_BUILD_DIR="${IDK_OUTPUT_DIR}/cmake"

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

    SHADER_DIR="${IDK_OUTPUT_DIR}/assets/shader"
    $THIS_DIR/shader_build.sh "${SHADER_DIR}"
}


if [[ "$opt_debug" == "0" && "$opt_release" == "0" ]]; then
    opt_release=1
fi


cvar_list=()
cdef_list=()

for path in $IDK_ROOT_DIR/idk_*; do
    if [[ "${path}" == "${IDK_ROOT_DIR}/idk_build" ]]; then
        continue
    elif [[ ! -d "$path" ]]; then
        continue
    fi

    cd $path
    name=$(basename "$PWD") && NAME="${name^^}"
    hash="$(git rev-parse HEAD)"

    cvar_name="${name}_hash"
    cvar_list+=("static const char $cvar_name[] = \"$hash\";")

    cdef_name="${NAME}_REPO_VERSION"
    cdef_list+=("#define $cdef_name \"$hash\"")

done

# echo "repo_list: ${repo_list[*]}"
version_path="${THIS_DIR}/../src/h/idk/version/version.h"

printf "%s\n" \
    "#pragma once" \
    "" \
    "#ifndef IDK_VERSION_H" \
    "    #define IDK_VERSION_H" \
    "#endif" \
    "" \
    > "${version_path}"

for cdef in "${cdef_list[@]}"; do
    echo "${cdef}" >> "${version_path}"
done

# printf "%s\n" \
#     "" \
#     "namespace idk::version" \
#     "{" \
#     >> "${version_path}"
# for cvar in "${cvar_list[@]}"; do
#     echo "    ${cvar}" >> "${version_path}"
# done
# echo "}" >> "${version_path}"

exit



if [[ "$opt_debug" == "1" ]]; then
    build_idk "$opt_target" "Debug" "$opt_clean"
fi

if [[ "$opt_release" == "1" ]]; then
    build_idk "$opt_target" "Release" "$opt_clean"
fi

