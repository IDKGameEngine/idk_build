#!/bin/bash
set -e

THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(cd ${THIS_DIR}/.. && pwd)
INSTALL_PREFIX=${REPO_DIR}/install

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
    cd ${REPO_DIR}/submodule/assimp
    cmake CMakeLists.txt \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DASSIMP_NO_EXPORT=ON \
        -DASSIMP_BUILD_TESTS=OFF \
        -DASSIMP_BUILD_ZLIB=ON \
        -DASSIMP_USE_HUNTER=ON
    cmake --build . && cmake --install .
}

build_glm()
{
    cd ${REPO_DIR}/submodule/glm
    cmake -B build . -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DGLM_BUILD_TESTS=OFF -DBUILD_SHARED_LIBS=OFF
    cmake --build build -- all
    cmake --build build -- install
}

build_imgui()
{
    cd ${REPO_DIR}/submodule/imgui
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Release
    cmake --build build --config Release
    cmake --install build --config Release
}

build_jolt()
{
    cd ${REPO_DIR}/submodule/JoltPhysics/Build
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
    cd ${REPO_DIR}/submodule/slang
    git fetch https://github.com/shader-slang/slang.git 'refs/tags/*:refs/tags/*'
    cmake --preset default -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
    cmake --build . --preset release
    cmake --install build
}

build_vulkan()
{
    cd ${REPO_DIR}/submodule/Vulkan-Headers
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
    cmake --build build && cmake --install build

    cd ${REPO_DIR}/submodule/VulkanMemoryAllocator
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
    cmake --build build && cmake --install build

    cd ${REPO_DIR}/submodule/volk
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" -DVOLK_INSTALL=ON
    cmake --build build && cmake --install build

    cd ${REPO_DIR}/submodule/Vulkan-Hpp
    cmake -S . -B build \
    -DVULKAN_HPP_GENERATOR_BUILD=OFF \
    -DVULKAN_HPP_RUN_GENERATOR=OFF \
    -DVULKAN_HPP_SAMPLES_BUILD=OFF \
    -DVULKAN_HPP_TESTS_BUILD=OFF \
    -DVULKAN_HPP_INSTALL=ON \
    -DVULKAN_HPP_VULKAN_HEADERS_SRC_DIR="${REPO_DIR}/submodule/Vulkan-Headers" \
    -DVulkanHeaders_INCLUDE_DIR="$(pwd)" \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
    cmake --build build && cmake --install build
}

# build_assimp
# build_glm
# build_imgui
# build_jolt
# build_slang
build_vulkan
