#!/bin/bash

if [[ "$#" != "2" ]]; then
    echo "Usage: version.sh [REPO_HASH] [OUTPUT_FILEPATH]"
    exit 1
fi

printf "%s\n" \
    "#pragma once" \
    "" \
    "#ifdef IDK_REPO_VERSION" \
    "    #error woopsie" \
    "#endif" \
    "" \
    "#define IDK_REPO_VERSION \"${1}\"" \
    > "${2}"
