#!/bin/bash
set -e

THIS_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
REPO_DIR=$(cd ${THIS_DIR}/.. && pwd)
THIRDPARTY_DIR=${REPO_DIR}/thirdparty
INSTALL_PREFIX=${REPO_DIR}/local

PLATFORM=$(uname -s)
if [ "$PLATFORM" == "Linux" ]; then
    echo "Linux environment detected"
elif [[ "$PLATFORM" == *"Windows"* ]]; then
    echo "Windows environment detected"
else
    echo "Unknown platform: $PLATFORM"
    exit 1
fi

get_repo()
{
    REPO_BRANCH="$1"
    REPO_URL="$2"
    REPO_NAME=$(basename "$REPO_URL" .git)
    [ ! -d "${THIRDPARTY_DIR}/${REPO_NAME}" ] && \
        git clone --depth 1 -b ${REPO_BRANCH} "${REPO_URL}" "${THIRDPARTY_DIR}/${REPO_NAME}"
    echo "${THIRDPARTY_DIR}/${REPO_NAME}"
}

build_assimp()
{
    cd $(get_repo v6.0.5 https://github.com/assimp/assimp.git)

    cd ${THIRDPARTY_DIR}/assimp
    cmake CMakeLists.txt \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DASSIMP_NO_EXPORT=ON \
        -DASSIMP_BUILD_TESTS=OFF \
        -DASSIMP_BUILD_ZLIB=ON \
        -DASSIMP_USE_HUNTER=ON
    cmake --build . -j $(nproc) && cmake --install .
}

build_glm()
{
    cd $(get_repo master https://github.com/g-truc/glm.git)
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DGLM_BUILD_TESTS=OFF -DBUILD_SHARED_LIBS=OFF
    cmake --build build -- all
    cmake --build build -- install
}

build_imgui()
{
    cd $(get_repo docking https://github.com/IDKGameEngine/imgui.git)
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Release
    cmake --build build --config Release
    cmake --install build --config Release
}

build_jolt()
{
    cd $(get_repo v5.6.0 https://github.com/jrouwe/JoltPhysics.git)/Build

    ./cmake_linux_clang_gcc.sh \
        Release g++ \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DJPH_USE_VK=OFF \
        -DJPH_USE_DX12=OFF \
        -DJPH_USE_MTL=OFF
    cd Linux_Release && make -j$(nproc) && make install
}

build_steamworks-sdk()
{
    cd $(get_repo main https://github.com/IDKGameEngine/steamworks-sdk.git)
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
    cmake --build build && cmake --install build
}

build_vulkan-sdk()
{
    cd $(get_repo main https://github.com/IDKGameEngine/vulkan-sdk.git)
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
    cmake --build build && cmake --install build
}

build_repos()
{
    for REPO_NAME in "$@"; do
        printf "\n\n-------------------------------- Building ${REPO_NAME} --------------------------------\n"
        build_$REPO_NAME
    done
}

build_repos assimp glm imgui jolt steamworks-sdk # vulkan-sdk
