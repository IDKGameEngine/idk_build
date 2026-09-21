#!/bin/bash
set -e

THIS_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
REPO_DIR=$(cd ${THIS_DIR}/.. && pwd)
THIRDPARTY_DIR=${REPO_DIR}/thirdparty

INSTALL_PREFIX=""
CMAKE_FLAGS=""
PLATFORM=$(uname -s)
if [ "$PLATFORM" == "Linux" ]; then
    echo "Linux environment detected"
    INSTALL_PREFIX=${REPO_DIR}/local
    CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}"
elif [[ "$PLATFORM" == *"Windows"* ]]; then
    echo "Windows environment detected"
    INSTALL_PREFIX=${REPO_DIR}/local-win
    CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DCMAKE_TOOLCHAIN_FILE=${REPO_DIR}/cmake/mingw-toolchain.cmake"
else
    echo "Unknown platform: $PLATFORM"
    exit 1
fi
echo "CMAKE_FLAGS: \"$CMAKE_FLAGS\""


build_assimp()
{
    cd ${THIRDPARTY_DIR}/assimp
    cmake CMakeLists.txt \
        ${CMAKE_FLAGS} \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DASSIMP_NO_EXPORT=ON \
        -DASSIMP_BUILD_TESTS=OFF \
        -DASSIMP_BUILD_ZLIB=ON \
        -DASSIMP_USE_HUNTER=ON
    cmake --build build -j $(nproc) && cmake --install build
}

build_jolt()
{
    cd $THIRDPARTY_DIR/JoltPhysics/Build
    ./cmake_linux_clang_gcc.sh \
        Release g++ \
        ${CMAKE_FLAGS} \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DJPH_USE_VK=OFF \
        -DJPH_USE_DX12=OFF \
        -DJPH_USE_MTL=OFF
    cd Linux_Release && make -j$(nproc) && make install
}

build_steamworks-sdk()
{
    cd $THIRDPARTY_DIR/steamworks-sdk
    cmake -S . -B build ${CMAKE_FLAGS}
    cmake --build build && cmake --install build
}

build_vulkan-sdk()
{
    cd $THIRDPARTY_DIR/vulkan-sdk
    cmake -S . -B build ${CMAKE_FLAGS}
    cmake --build build && cmake --install build
}

build_repos()
{
    for REPO_NAME in "$@"; do
        printf "\n\n-------------------------------- Building ${REPO_NAME} --------------------------------\n"
        build_$REPO_NAME
    done
}

build_repos assimp jolt steamworks-sdk vulkan-sdk
