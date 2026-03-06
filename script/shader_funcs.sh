#!/bin/bash

THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export PATH="${PATH}:${THIS_DIR}/../bin"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/home/michael/devel/idk/idk_build/lib"


slang_to_target()
{
    target="$1"
    filepath="$2"

    if grep -q "vertmain" "$filepath"; then
        slangc -matrix-layout-column-major -profile glsl_460 -target $target \
               "${filepath}" -entry vertmain -o "${filepath%.*}".vert
        sed -i 's/gl_VertexIndex/gl_VertexID/g' "${filepath%.*}".vert
    fi

    if grep -q "fragmain" "$filepath"; then
        slangc -matrix-layout-column-major -profile glsl_460 -target $target \
               "${filepath}" -entry fragmain -o "${filepath%.*}".frag
        sed -i 's/gl_VertexIndex/gl_VertexID/g' "${filepath%.*}".frag
    fi

    if grep -q "compmain" "$filepath"; then
        slangc -matrix-layout-column-major -profile glsl_460 -target $target \
               "${filepath}" -entry compmain -o "${filepath%.*}".comp
        sed -i 's/gl_VertexIndex/gl_VertexID/g' "${filepath%.*}".comp
    fi
}

slang_to_glsl()
{
    while [ $# -gt 0 ]; do
        slang_to_target glsl "${1}"
        shift
    done
}

slang_to_spirv()
{
    while [ $# -gt 0 ]; do
        slang_to_target spirv "${1}"
        shift
    done
}


# slang_to_glsl_comp()
# {
#     filepath="$1"
#     target="glsl"

#     slangc \
#         -matrix-layout-column-major \
#         -profile glsl_460 -target $target \
#         "${filepath}" -entry compmain -o "${filepath%.*}".comp
# }

