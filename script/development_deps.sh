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

build_slang()
{
    cd ${THIRDPARTY_DIR}/slang
    git fetch https://github.com/shader-slang/slang.git 'refs/tags/*:refs/tags/*'
    cmake --preset default -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
    cmake --build . -j $(nproc) --preset release
    cmake --install build
}

build_vulkan()
{
    cd ${THIRDPARTY_DIR}/Vulkan-Headers
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
    cmake --build build && cmake --install build

    cd ${THIRDPARTY_DIR}/VulkanMemoryAllocator
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
    cmake --build build && cmake --install build

    cd ${THIRDPARTY_DIR}/volk
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" -DVOLK_INSTALL=ON
    cmake --build build && cmake --install build

    cd ${THIRDPARTY_DIR}/Vulkan-Hpp
    cmake -S . -B build -G Ninja \
    -DVULKAN_HPP_GENERATOR_BUILD=OFF \
    -DVULKAN_HPP_RUN_GENERATOR=OFF \
    -DVULKAN_HPP_SAMPLES_BUILD=OFF \
    -DVULKAN_HPP_TESTS_BUILD=OFF \
    -DVULKAN_HPP_INSTALL=ON \
    -DVULKAN_HPP_VULKAN_HEADERS_SRC_DIR="${THIRDPARTY_DIR}/Vulkan-Headers" \
    -DVulkanHeaders_INCLUDE_DIR="$(pwd)" \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
    cmake --build build -j $(nproc) && cmake --install build
}

build_steamworks()
{
    cd ${THIRDPARTY_DIR}/steamworks_sdk
    ./install.sh 165
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

build_repos assimp glm imgui jolt slang vulkan steamworks
