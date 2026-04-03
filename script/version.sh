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

gen_version_header()
{
    if [[ "$IDK_POLY_DIR" == "" ]]; then
        echo "IDK_POLY_DIR must be defined"
        exit 1
    fi

    outdir=$(cd ${1} && pwd)
    outfile="${outdir}/version.h"
    mkdir -p "${outdir}" && touch "${outfile}"

    printf "%s\n" \
        "#pragma once" \
        "" \
        "#ifndef IDK_VERSION_H" \
        "#define IDK_VERSION_H" \
        "" \
        > "${outfile}"

    dirty_repo="0"
    for path in $IDK_POLY_DIR/idk_*; do
        if [[ ! -d "$path" ]]; then
            continue
        fi
        cd $path
        name=$(basename "$PWD") && name="${name^^}"
        hash="$(git rev-parse HEAD)"
        porcelain="dirty"
        if [[ -z "$(git status --porcelain)" ]]; then
            porcelain="clean"
            dirty_repo="1"
        fi

        printf "%s\t%s\n" \
            "#define ${name}_REPO_VER" \
            "\"$hash\" // $porcelain" \
            >> "$outfile"
    done

    if [[ "$dirty_repo" == "1" ]]; then
        printf "\n#error woop" >> "$outfile"
    fi

    printf "%s\n" \
        "" \
        "#endif // IDK_VERSION_H" \
        >> "${outfile}"
}


gen_version_txt()
{
    if [[ "$IDK_POLY_DIR" == "" ]]; then
        echo "IDK_POLY_DIR must be defined"
        exit 1
    fi

    outdir=$(cd ${1} && pwd)
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
        if [[ -z "$(git status --porcelain)" ]]; then
            porcelain="clean"
        fi

        printf "%s \t%s\n" \
            "$name" "$hash $porcelain" \
            >> "$outfile"
    
    done
}


while [[ $# -gt 0 ]]; do
    case $1 in
        --header)
            res=$(gen_version_header "$2")
            if [[ "$res" == "1" ]]; then
                exit 1
            fi
            shift
            shift
            ;;
        --text)
            res=$(gen_version_txt "$2")
            if [[ "$res" == "1" ]]; then
                exit 1
            fi
            shift
            shift
            ;;
        *)
            echo "Unknown option $1" >&2
            exit 1
            ;;
    esac
done



