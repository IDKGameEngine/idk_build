#!/bin/bash

# if [[ "$#" != "2" ]]; then
#     echo "Usage: version.sh [REPO_HASH] [OUTPUT_FILEPATH]"
#     exit 1
# fi

# printf "%s\n" \
#     "#pragma once" \
#     "" \
#     "#ifdef IDK_REPO_VERSION" \
#     "    #error woopsie" \
#     "#endif" \
#     "" \
#     "#define IDK_REPO_VERSION \"${1}\"" \
#     > "${2}"

IDK_REPO_DIRS=(
    "${IDK_POLY_DIR}/idk_build"
    "${IDK_POLY_DIR}/idk_engine"
    "${IDK_POLY_DIR}/idk_game"
    "${IDK_POLY_DIR}/idk_gfx"
    "${IDK_POLY_DIR}/libidk"
)


gen_version_header()
{
    if [[ "$IDK_POLY_DIR" == "" ]]; then
        echo "IDK_POLY_DIR must be defined"
        exit 1
    elif [[ "$IDK_ROOT_DIR" == "" ]]; then
        echo "IDK_ROOT_DIR must be defined"
        exit 1
    fi

    # outdir=$(cd ${1} && pwd)
    outdir="${IDK_ROOT_DIR}/include/idk"
    outfile="${outdir}/version.h"
    mkdir -p "${outdir}" && touch "${outfile}"

    printf "%s\n" \
        "#pragma once" \
        "" \
        > "${outfile}"

    porcelain_fail="0"
    for path in "${IDK_REPO_DIRS[@]}"; do
        cd $path

        name=$(basename "$PWD") && name="${name^^}"
        hash="$(git rev-parse HEAD)"
        porcelain="clean"
    
        if [[ ! -z "$(git status --porcelain)" ]]; then
            porcelain="dirty"
            porcelain_fail="1"
        fi

        printf "%-26s %32s\n" \
            "#define ${name}_VERSION" \
            "\"$hash\" // $porcelain" \
            >> "$outfile"
    done

    if [[ "$porcelain_fail" == "1" ]]; then
        printf "\n// #error All repositories must pass git porcelain check!\n" >> "$outfile"
    fi

    printf "%s" >> "${outfile}"
}


gen_version_txt()
{
    if [[ "$IDK_POLY_DIR" == "" ]]; then
        echo "IDK_POLY_DIR must be defined"
        exit 1
    elif [[ "$IDK_OUTPUT_DIR" == "" ]]; then
        echo "IDK_OUTPUT_DIR must be defined"
        exit 1
    fi

    # outdir=$(cd ${1} && pwd)
    outdir="$IDK_OUTPUT_DIR"
    outfile="${outdir}/version.txt"
    mkdir -p "${outdir}" && touch "${outfile}"

    printf "" > "$outfile"
    for path in $IDK_POLY_DIR/idk_*; do
        if [[ ! -d "$path" ]]; then
            continue
        fi
    
        cd $path
        name=$(basename "$PWD")
        hash="$(git rev-parse HEAD)"
        porcelain="dirty"
        if [[ -z "$(git status --porcelain -- . ':!$IDK_POLY_DIR/idk_build/version.txt')" ]]; then
            porcelain="clean"
        fi

        printf "%s %s\n" \
            "$name" "$hash $porcelain" \
            >> "$outfile"
    done
}

gen_version_thirdparty_txt()
{
    if [[ "$IDK_POLY_DIR" == "" ]]; then
        echo "IDK_POLY_DIR must be defined"
        exit 1
    elif [[ "$IDK_OUTPUT_DIR" == "" ]]; then
        echo "IDK_OUTPUT_DIR must be defined"
        exit 1
    fi

    thirdparty_repo_names=(
        "assimp"
        "glm"
        "JoltPhysics"
        "SDL"
        "SDL_image"
        "SDL_mixer"
        "SDL_net"
        "slang"
    )
    outdir="$IDK_OUTPUT_DIR"
    outfile="${outdir}/version.txt"

    printf "" >> "$outfile"
    for name in "${thirdparty_repo_names[@]}"; do
        cd $IDK_POLY_DIR/idk_build/thirdparty/$name

        hash="$(git rev-parse HEAD)"
        porcelain="dirty"
        if [[ -z "$(git status --porcelain)" ]]; then
            porcelain="clean"
        fi

        printf "%s %s\n" \
            "$name" "$hash $porcelain" \
            >> "$outfile"
    done
}


while [[ $# -gt 0 ]]; do
    case $1 in
        --header)
            gen_version_header
            shift
            ;;
        --text)
            gen_version_txt
            gen_version_thirdparty_txt
            shift
            ;;
        *)
            echo "Unknown option $1" >&2
            exit 1
            ;;
    esac
done

