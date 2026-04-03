#!/bin/bash
set -e

PLATFORM=$(uname -s)

if [ "$PLATFORM" == "Linux" ]; then
    echo "Running on Linux"
elif [[ "$PLATFORM" == *"Windows"* ]]; then
    echo "Running on Windows environment"
else
    echo "Unknown platform: $PLATFORM"
    exit 1
fi

opt_glm=""
opt_vulkan=""
opt_jolt=""
opt_assimp=""
opt_sdl3=""
build_type="Release"

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            opt_glm=1
            opt_vulkan=1
            opt_jolt=1
            opt_assimp=1
            opt_sdl3=1
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
        --sdl3)
            opt_sdl3=1
            shift
            ;;
        --type)
            build_type="${2}"
            shift
            shift
            ;;
        *)
            echo "Unknown option $1" >&2
            exit 1
            ;;
    esac
done


THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IDK_POLY_DIR=$(cd ${THIS_DIR}/../.. && pwd)
IDK_ROOT_DIR=""

case "$build_type" in
    Release)
        IDK_ROOT_DIR="${IDK_POLY_DIR}/idk"
        ;;
    Debug)
        IDK_ROOT_DIR="${IDK_POLY_DIR}/idk_d"
        ;;
    *)
        echo "--type must be either \"Debug\" or \"Release\""
        exit 1
        ;;
esac

INSTALL_PREFIX=$IDK_ROOT_DIR
THIRDPARTY_DIR="${IDK_POLY_DIR}/idk_build/repo"

mkdir -p $INSTALL_PREFIX/{bin,include,lib,share}
mkdir -p $THIRDPARTY_DIR


build_glm()
{
    cd $THIRDPARTY_DIR
    if [[ ! -d "glm" ]]; then
        git clone --depth=1 --branch 1.0.3 https://github.com/g-truc/glm.git
    fi

    # mkdir -p $INSTALL_PREFIX/include/glm
    # cp -r $THIRDPARTY_DIR/glm/glm/* $INSTALL_PREFIX/include/glm/

    cd glm

    cmake \
        -DGLM_BUILD_TESTS=OFF \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
        -B build .

    cmake --build build -- all
    cmake --build build -- install
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


build_sdl3()
{
    cd $THIRDPARTY_DIR
    if [[ ! -d "SDL" ]]; then
        git clone --depth=1 --branch release-3.4.0 --single-branch https://github.com/libsdl-org/SDL.git
    fi
    if [[ ! -d "SDL_image" ]]; then
        git clone --depth=1 --branch release-3.4.0 --single-branch https://github.com/libsdl-org/SDL_image.git
    fi
    if [[ ! -d "SDL_mixer" ]]; then
        git clone --depth=1 --branch release-3.2.0 --single-branch https://github.com/libsdl-org/SDL_mixer.git
    fi

    cd SDL
    cmake -S . -B build -DCMAKE_BUILD_TYPE=$build_type
    cmake --build build --config $build_type
    cmake --install build --prefix "$INSTALL_PREFIX"

    cd ../SDL_image
    cmake -S . -B build -DCMAKE_BUILD_TYPE=$build_type
    cmake --build build --config $build_type
    cmake --install build --prefix "$INSTALL_PREFIX"

    cd ../SDL_mixer
    cmake -S . -B build -DCMAKE_BUILD_TYPE=$build_type
    cmake --build build --config $build_type
    cmake --install build --prefix "$INSTALL_PREFIX"
}


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

if [[ "$opt_sdl3" == "1" ]]; then
    build_sdl3
fi
