#!/bin/bash
set -e

THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
THIRDPARTY_DIR="${THIS_DIR}/repo"
INSTALL_PREFIX="${THIS_DIR}"

mkdir -p $THIRDPARTY_DIR
mkdir -p $INSTALL_PREFIX/{bin,include,lib,share}


PLATFORM=$(uname -s)

if [ "$PLATFORM" == "Linux" ]; then
    echo "Running on Linux"
elif [[ "$PLATFORM" == *"Windows"* ]]; then
    echo "Running on Windows environment"
else
    echo "Unknown platform: $PLATFORM"
    exit 1
fi


build_glm()
{
    cd $THIRDPARTY_DIR
    if [[ ! -d "glm" ]]; then
        git clone --depth=1 --branch 1.0.3 https://github.com/g-truc/glm.git
    fi

    mkdir -p $INSTALL_PREFIX/include/glm
    cp -r $THIRDPARTY_DIR/glm/glm/* $INSTALL_PREFIX/include/glm/
}


build_vulkan()
{
    VK_VERSION="1.4.304.0"
    VK_CPUARCH="x86_64"
    VK_FILENAME="vulkansdk-linux-${VK_CPUARCH}-${VK_VERSION}.tar.xz"

    mkdir -p $THIRDPARTY_DIR/vulkan
    cd $THIRDPARTY_DIR/vulkan
    if [[ ! -f "$VK_FILENAME" ]]; then
        wget "https://sdk.lunarg.com/sdk/download/${VK_VERSION}/linux/${VK_FILENAME}"
    fi
    tar -xvf $VK_FILENAME

    cd ./$VK_VERSION/$VK_CPUARCH
    cp -v -r ./bin/* $INSTALL_PREFIX/bin/
    cp -v -r ./include/* $INSTALL_PREFIX/include/
    cp -v -r ./lib/* $INSTALL_PREFIX/lib/
    cp -v -r ./share/* $INSTALL_PREFIX/share/

    rm -rf $THIRDPARTY_DIR/vulkan/$VK_VERSION
}


build_jolt()
{
    cd $THIRDPARTY_DIR
    if [[ ! -d "JoltPhysics" ]]; then
        git clone --depth=1 --branch v5.5.0 https://github.com/jrouwe/JoltPhysics.git
    fi

    cd JoltPhysics/Build
    ./cmake_linux_clang_gcc.sh Release g++ -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
    cd Linux_Release && make -j$(nproc) && ./UnitTests && make install
}


build_assimp()
{
    cd $THIRDPARTY_DIR
    if [[ ! -d "assimp" ]]; then
        git clone --depth=1 --branch v6.0.4 https://github.com/assimp/assimp.git
    fi

    cd assimp
    cmake CMakeLists.txt -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
        -DBUILD_SHARED_LIBS=ON \
        -DASSIMP_NO_EXPORT=ON \
        -DASSIMP_BUILD_TESTS=OFF \
        -DASSIMP_BUILD_ZLIB=ON \
        -DASSIMP_USE_HUNTER=ON
    cmake --build . && cmake --install .

    # cp -r ./lib/* $INSTALL_PREFIX/lib/
    # cp -r ./include/* $INSTALL_PREFIX/include/
}


opt_glm=""
opt_vulkan=""
opt_jolt=""
opt_assimp=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            opt_glm=1
            opt_vulkan=1
            opt_jolt=1
            opt_assimp=1
            shift
            ;;
        --glm)
            opt_glm=1
            shift
            ;;
        --vulkan)
            opt_vulkan=1
            shift
            ;;
        --jolt)
            opt_jolt=1
            shift
            ;;
        --assimp)
            opt_assimp=1
            shift
            ;;
        *)
            echo "Unknown option $1" >&2
            exit 1
            ;;
    esac
done


if [[ "$opt_glm" == "1" ]]; then
    build_glm
fi

if [[ "$opt_vulkan" == "1" ]]; then
    build_vulkan
fi

if [[ "$opt_jolt" == "1" ]]; then
    build_jolt
fi

if [[ "$opt_assimp" == "1" ]]; then
    build_assimp
fi

