# #!/bin/bash

# THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# export PATH="${PATH}:${THIS_DIR}/../bin"
# export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/home/michael/devel/idk/idk_build/lib"


# __slang_to_target()
# {
#     target="$1"
#     stage="$2"
#     srcpath="$3"
#     dstpath="${srcpath%.*}"."${stage}"
#     entryname="${stage}main"
#     # if grep -q "$entryname" "$srcpath"; then
#     #     slangc -O3 -matrix-layout-column-major -profile glsl_460 -target $target \
#     #            "${srcpath}" -entry $entryname -o $dstpath
#     #     sed -i 's/gl_VertexIndex/gl_VertexID/g' $dstpath
#     # fi

#     if grep -q "$entryname" "$srcpath"; then
#         slangc "${srcpath}" \
#                -target glsl \
#                -profile glsl_460 \
#                -entry $entryname \
#                -o $dstpath

#         # slangc -O3 -matrix-layout-column-major \
#         #        -profile glsl_460 -target spirv \
#         #        -fvk-use-gl-layout -fspv-reflect \
#         #        "${srcpath}" -entry $entryname -o $dstpath
#     fi

# }

# slang_to_target()
# {
#     target="$1"
#     filepath="$2"
#     __slang_to_target "${target}" "vert" "${filepath}"
#     __slang_to_target "${target}" "frag" "${filepath}"
#     __slang_to_target "${target}" "comp" "${filepath}"
# }

# slang_to_glsl()
# {
#     while [ $# -gt 0 ]; do
#         slang_to_target "glsl" "${1}"
#         shift
#     done
# }

# slang_to_spirv()
# {
#     while [ $# -gt 0 ]; do
#         slang_to_target "spirv" "${1}"
#         shift
#     done
# }

