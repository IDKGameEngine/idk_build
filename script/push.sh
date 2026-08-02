#!/bin/bash

THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
POLY_DIR=$(cd ${THIS_DIR}/../../ && pwd)

REPO_DIRS=(
    "${POLY_DIR}/libidk"
    "${POLY_DIR}/idk_build"
    "${POLY_DIR}/idk_engine"
    "${POLY_DIR}/idk_game"
    "${POLY_DIR}/idk_gfx"
)

for REPO_DIR in "${REPO_DIRS[@]}"; do
    cd $REPO_DIR
    if [ -n "$(git status --porcelain)" ]; then
        git add . && git commit -m "Automated commit" && git push
    fi
done
