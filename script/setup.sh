#!/bin/bash
set -e

THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd $THIS_DIR && source env.sh

INSTALL_PREFIX="${THIRDPARTY_PREFIX}"

mkdir -p $VANE_ROOT_DIR/external/repo
mkdir -p $INSTALL_PREFIX/{bin,include,lib,share}

# # GLM
# # ------------------------------------------------------------------
# cd $VANE_ROOT_DIR/external/repo

# if [[ ! -d "glad" ]]; then
#     git clone --depth=1 https://github.com/mellic03/glad.git
# fi

# mkdir -p glad/build && cd glad/build
# cmake .. -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
# make -j$(nproc) && make install
# # ------------------------------------------------------------------


# # GLM
# # ------------------------------------------------------------------
# cd $VANE_ROOT_DIR/external/repo

# if [[ ! -d "glm" ]]; then
#     git clone --depth=1 --branch 1.0.3 https://github.com/g-truc/glm.git
# fi

# mkdir -p $INSTALL_PREFIX/include/glm
# cp -r $VANE_ROOT_DIR/external/repo/glm/glm/* $INSTALL_PREFIX/include/glm/
# # ------------------------------------------------------------------

# Vulkan SDK
# # ------------------------------------------------------------------
# cd $VANE_ROOT_DIR/external/repo

# mkdir -p vulkan && cd vulkan
# VK_VERSION=$THIRDPARTY_VK_VERSION
# VK_CPUARCH="x86_64"
# VK_FILENAME="vulkansdk-linux-${VK_CPUARCH}-${VK_VERSION}.tar.xz"

# if [[ ! -f "$VK_FILENAME" ]]; then
#     wget "https://sdk.lunarg.com/sdk/download/${VK_VERSION}/linux/${VK_FILENAME}"
# fi
# tar -xvf $VK_FILENAME

# cd $VK_VERSION/$VK_CPUARCH
# cp -v -r ./bin/* $INSTALL_PREFIX/bin/
# cp -v -r ./include/* $INSTALL_PREFIX/include/
# cp -v -r ./lib/* $INSTALL_PREFIX/lib/
# cp -v -r ./share/* $INSTALL_PREFIX/share/

# cd $VANE_ROOT_DIR/external/repo
# rm -rf ./vulkan/$VK_VERSION/$VK_CPUARCH
# ------------------------------------------------------------------


# # Jolt Physics
# # ------------------------------------------------------------------
# cd $VANE_ROOT_DIR/external/repo

# if [[ ! -d "JoltPhysics" ]]; then
#     git clone --depth=1 --branch v5.5.0 https://github.com/jrouwe/JoltPhysics.git
# fi

# cd JoltPhysics/Build
# ./cmake_linux_clang_gcc.sh Release g++ -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
# cd Linux_Release && make -j$(nproc) && ./UnitTests && make install
# # ------------------------------------------------------------------



# Assimp
# ------------------------------------------------------------------
cd $VANE_ROOT_DIR/external/repo
if [[ ! -d "assimp" ]]; then
    git clone --depth=1 --branch v6.0.4 https://github.com/assimp/assimp.git
fi

cd assimp
cmake CMakeLists.txt -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX="${THIRDPARTY_PREFIX}"
cmake --build .

cp -r ./lib/* $THIRDPARTY_PREFIX/lib/
cp -r ./include/* $THIRDPARTY_PREFIX/include/
# ------------------------------------------------------------------
