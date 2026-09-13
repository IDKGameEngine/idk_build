#!/bin/bash
set -e

THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(cd ${THIS_DIR}/.. && pwd)
THIRDPARTY_DIR=${REPO_DIR}/thirdparty
INSTALL_PREFIX=${THIRDPARTY_DIR}/.prefix

PLATFORM=$(uname -s)
if [ "$PLATFORM" == "Linux" ]; then
    echo "Linux environment detected"
elif [[ "$PLATFORM" == *"Windows"* ]]; then
    echo "Windows environment detected"
else
    echo "Unknown platform: $PLATFORM"
    exit 1
fi

build_repos()
{
    for REPO_NAME in "$@"; do
        printf "\n\n-------------------------------- Building ${REPO_NAME} --------------------------------\n"
        build_$REPO_NAME
    done
}

build_assimp()
{
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
    cd ${THIRDPARTY_DIR}/glm
    cmake -B build . -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DGLM_BUILD_TESTS=OFF -DBUILD_SHARED_LIBS=OFF
    cmake --build build -- all
    cmake --build build -- install
}

build_imgui()
{
    cd ${THIRDPARTY_DIR}/imgui
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Release
    cmake --build build --config Release
    cmake --install build --config Release
}

build_jolt()
{
    cd ${THIRDPARTY_DIR}/JoltPhysics/Build
    ./cmake_linux_clang_gcc.sh \
        Release g++ \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DJPH_USE_VK=OFF \
        -DJPH_USE_DX12=OFF \
        -DJPH_USE_MTL=OFF
    cd Linux_Release && make -j$(nproc) && ./UnitTests && make install
}

build_steamworks-sdk()
{
    cd ${THIRDPARTY_DIR}/steamworks-sdk
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
    cmake --build build && cmake --install build
}

build_vulkan-sdk()
{
    cd $THIRDPARTY_DIR/vulkan-sdk
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
    cmake --build build && cmake --install build
}

build_repos assimp glm imgui jolt steamworks-sdk vulkan-sdk
