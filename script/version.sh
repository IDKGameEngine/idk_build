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

    outdir="${1}"
    outfile="${outdir}/version.h"
    mkdir -p "${outdir}" && touch "${outfile}"

    echo "[gen_version_header] IDK_POLY_DIR=${IDK_POLY_DIR}"
    echo "[gen_version_header] OUTPUT_FILE=${outfile}"

    cvar_list=()
    cdef_list=()

    for path in $IDK_POLY_DIR/idk_*; do
        if [[ "${path}" == "${IDK_POLY_DIR}/idk_build" ]]; then
            continue
        elif [[ ! -d "$path" ]]; then
            continue
        fi

        echo "found repo: ${path}"

        cd $path
        name=$(basename "$PWD") && NAME="${name^^}"
        hash="$(git rev-parse HEAD)"

        cvar_name="${name}_hash"
        cvar_list+=("static const char $cvar_name[] = \"$hash\";")

        cdef_name="${NAME}_REPO_VERSION"
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

}
