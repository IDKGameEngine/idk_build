#!/bin/bash

if [[ "$#" != "1" ]]; then
    echo "Usage: shader_build.sh [SHADER_DIR]"
    exit 1
fi

THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IDK_POLY_DIR=$(cd ${THIS_DIR}/../.. && pwd)
IDK_ROOT_DIR="${IDK_POLY_DIR}/idk"
SHADER_DIR=$1


__slang_to_spirv()
{
    export PATH="${PATH}:${IDK_ROOT_DIR}/bin"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${IDK_ROOT_DIR}/lib"

    stage="$1"
    srcpath="$2"
    dstpath="${srcpath%.*}"."${stage}"
    entryname="${stage}main"

    if grep -q "$entryname" "$srcpath"; then
            # -D__SLANG__ \
        slangc "${srcpath}" \
            -I "${IDK_POLY_DIR}/idk_gfx/h" \
            -O3 \
            -matrix-layout-column-major \
            -fvk-use-gl-layout -fspv-reflect \
            -emit-spirv-directly \
            -target spirv \
            -profile glsl_460 \
            -entry $entryname \
            -o $dstpath

        # sed -i 's/gl_VertexIndex/gl_VertexID/g' $dstpath

        # -O3 -matrix-layout-column-major \
        # -fvk-use-gl-layout -fspv-reflect
    fi

}

slang_to_spirv()
{
    while [ $# -gt 0 ]; do
        __slang_to_spirv "vert" "${1}"
        __slang_to_spirv "frag" "${1}"
        __slang_to_spirv "comp" "${1}"
        shift
    done
}


cd $SHADER_DIR && slang_to_spirv *.slang && rm *.slang

# source $THIS_DIR/script/shader_funcs.sh
# cd $IDK_OUTPUT_DIR/assets/shader
# slang_to_spirv ./*.slang
# rm $IDK_OUTPUT_DIR/assets/shader/*.slang



