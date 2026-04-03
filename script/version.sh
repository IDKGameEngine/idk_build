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


skip_names=()

__should_skip()
{
    found=0
    for name in "${skip_names[@]}"; do
        if [[ "$name" == "$1" ]]; then
            found=1
            break
        fi
    done
    echo $found
}

gen_version_header()
{
    if [[ "$IDK_POLY_DIR" == "" ]]; then
        echo "IDK_POLY_DIR must be defined"
        exit 1
    fi

    outdir=""
    while [[ $# -gt 0 ]]; do
        case $1 in
            --outpath)
                outdir="${2}"
                shift
                shift
                ;;
            --skip)
                skip_names+=("${2}")
                shift
                shift
                ;;
            *)
                echo "Unknown option $1" >&2
                exit 1
                ;;
        esac
    done

    if [[ "$outdir" == "" ]]; then
        echo "Must supply --outpath"
        exit 1
    fi

    outfile="${outdir}/version.h"
    mkdir -p "${outdir}" && touch "${outfile}"

    echo "[gen_version_header] IDK_POLY_DIR=${IDK_POLY_DIR}"
    echo "[gen_version_header] OUTPUT_FILE=${outfile}"

    cvar_list=()
    cdef_list=()

    for path in $IDK_POLY_DIR/idk_*; do
        cd $path
        name=$(basename "$PWD") && NAME="${name^^}"
        skip=$(__should_skip "${name}")
        if [[ "$skip" == "1" ]]; then
            continue
        elif [[ ! -d "$path" ]]; then
            continue
        fi

        hash="$(git rev-parse HEAD)"

        if [[ "$name" == "$skip_name" ]]; then
            continue
        fi

        cvar_name="${name}_hash"
        cvar_list+=("static const char $cvar_name[] = \"$hash\";")

        cdef_name="${NAME}_REPO_VER"
        cdef_list+=("#define $cdef_name \"$hash\"")

    done


    printf "%s\n" \
        "#pragma once" \
        "" \
        "#ifndef IDK_VERSION_H" \
        "#define IDK_VERSION_H" \
        "" \
        > "${outfile}"

    for cdef in "${cdef_list[@]}"; do
        echo "${cdef}" >> "${outfile}"
    done

    printf "%s\n" \
        "" \
        "#endif // IDK_VERSION_H" \
        >> "${outfile}"

    # printf "%s\n" \
    #     "" \
    #     "namespace idk::version" \
    #     "{" \
    #     >> "${outfile}"
    # for cvar in "${cvar_list[@]}"; do
    #     echo "    ${cvar}" >> "${outfile}"
    # done
    # echo "}" >> "${outfile}"

    printf "\n\n"
}
