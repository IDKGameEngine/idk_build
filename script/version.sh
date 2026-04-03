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
    if [[ "$#" != "1" ]]; then
        echo "Usage: gen_version_header [IDK_ROOT_DIR]"
        exit 1
    fi

    search_path="${1}"

    cvar_list=()
    cdef_list=()

    for path in $search_path/idk_*; do
        if [[ ! -d "$path" ]]; then
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

}
