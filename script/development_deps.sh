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

build_jolt()
{
    cd ${REPO_DIR}/submodule/JoltPhysics/Build
    ./cmake_linux_clang_gcc.sh \
        Release g++ \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
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
    git submodule update --init
    cmake --preset default -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
    cmake --build --preset release
    cmake --build . --target install
}

build_assimp
build_jolt
build_slang
