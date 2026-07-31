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

for DIR in "${REPO_DIRS[@]}"; do
    echo "cd $DIR && git pull"
    cd $DIR && git pull
done
