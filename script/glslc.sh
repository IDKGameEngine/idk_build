#!/bin/bash

THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [[ "$#" == "0" ]]; then
    exit
fi

mode=$1
shift

if [[ "$mode" == "-C" ]]; then
    while [ $# -gt 0 ]; do
        glslc --target-env=opengl ${1} -o ${1}.spv
        shift
    done

elif [[ "$mode" == "-P" ]]; then
    while [ $# -gt 0 ]; do
        glslc -E ${1} > ${1}.p
        shift
    done
    # for stage in vert frag comp; do
    #     for file in *."$stage".pp; do
    #         mv -- "$file" "${file%.$stage.pp}.pp.$stage"
    #     done
    # done

fi
