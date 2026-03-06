#!/bin/bash

THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PATH="${PATH}:${THIS_DIR}/../bin"
LD_LIBRARY_PATH="${PATH}:${THIS_DIR}/../lib"


slang_to_target()
{
    target="$1"
    filepath="$2"

    if grep -q "vertmain" "$filepath"; then
        slangc -matrix-layout-column-major -profile glsl_460 -target $target \
               "${filepath}" -entry vertmain -o "${filepath%.*}".vert
    fi

    if grep -q "fragmain" "$filepath"; then
        slangc -matrix-layout-column-major -profile glsl_460 -target $target \
               "${filepath}" -entry fragmain -o "${filepath%.*}".frag
    fi

    if grep -q "compmain" "$filepath"; then
        slangc -matrix-layout-column-major -profile glsl_460 -target $target \
               "${filepath}" -entry compmain -o "${filepath%.*}".comp
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

