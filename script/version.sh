#!/bin/bash

THIS_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
IDK_POLY_DIR=$(cd ${THIS_DIR}/../../ && pwd)
IDK_BUILD_DIR="${IDK_POLY_DIR}/${1}"

IDK_REPO_DIRS=(
    "${IDK_POLY_DIR}/idk_build"
    "${IDK_POLY_DIR}/idk_content"
    "${IDK_POLY_DIR}/idk_engine"
    "${IDK_POLY_DIR}/idk_game"
    "${IDK_POLY_DIR}/idk_gfx"
    "${IDK_POLY_DIR}/libidk"
)

if [[ "$IDK_POLY_DIR" == "" ]]; then
    echo "IDK_POLY_DIR must be defined"
    exit 1
elif [[ "$IDK_BUILD_DIR" == "" ]]; then
    echo "IDK_BUILD_DIR must be defined"
    exit 1
fi

outfile="${IDK_BUILD_DIR}/version.txt"
printf "" > "$outfile"

for path in "${IDK_REPO_DIRS[@]}"; do
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

    printf "%s %s\n" "$name" "$hash $porcelain" >> "$outfile"
done
