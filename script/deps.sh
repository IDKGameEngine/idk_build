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

declare -A repo_opts=(
    # [asio]=0
    [assimp]=0
    # [glad]=0
    [glm]=0
    [jolt]=0
    [sdl3]=0
    [slang]=0
    [vulkan]=0
    [build_type]="Release"
)

while [[ $# -gt 0 ]]; do
    key="${1:2}"
    if [[ -v repo_opts[$key] ]]; then
        repo_opts[$key]=1
        shift
    elif [[ "$key" == "all" ]]; then
        repo_opts["assimp"]=1
        repo_opts["glad"]=1
        repo_opts["glm"]=1
        repo_opts["jolt"]=1
        repo_opts["sdl3"]=1
        repo_opts["slang"]=1
        repo_opts["vulkan"]=1
        shift
    else
        echo "Unknown option $1" >&2
        exit 1
    fi
done

THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IDK_POLY_DIR=$(cd ${THIS_DIR}/../.. && pwd)
IDK_ROOT_DIR=""

case "${repo_opts[build_type]}" in
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
THIRDPARTY_DIR="${IDK_POLY_DIR}/idk_build/thirdparty"
COMMON_CMAKE_DEFS="-DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=${IDK_ROOT_DIR} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}"

mkdir -p $INSTALL_PREFIX/{bin,include,lib,share}
mkdir -p $THIRDPARTY_DIR

# build_asio()
# {
#     cd $THIRDPARTY_DIR
#     if [[ ! -d "asio" ]]; then
#         git clone --depth=1 --branch boost-1.90.0 https://github.com/boostorg/asio.git
#     fi

#     mkdir -p "$INSTALL_PREFIX/include/boost"
#     cp -r ./asio/include/boost/* "$INSTALL_PREFIX/include/boost/"
# }

woop_boop()
{
    repo_owner="$1"
    repo_name="$2"
    repo_branch="$3"
    repo_url="https://github.com/$repo_owner/$repo_name.git"
    args="--recursive --depth=1 "

    if [[ "$repo_branch" != "" ]]; then
        args+="--branch $repo_branch "
    fi

    cd $THIRDPARTY_DIR
    if [[ ! -d "$repo_name" ]]; then
       git clone $repo_url $args
    fi
}


build_glad()
{
    woop_boop Dav1dde glad v2.0.8
    # cd $THIRDPARTY_DIR
    # if [[ ! -d "glm" ]]; then
    #     git clone --depth=1 --branch v2.0.8 https://github.com/Dav1dde/glad.git --recursive
    # fi
}


build_glm()
{
    cd $THIRDPARTY_DIR
    if [[ ! -d "glm" ]]; then
        git clone --depth=1 --branch 1.0.3 https://github.com/g-truc/glm.git --recursive
    fi

    cd glm
    cmake -B build . -DGLM_BUILD_TESTS=OFF -DBUILD_SHARED_LIBS=OFF $COMMON_CMAKE_DEFS
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
    ./cmake_linux_clang_gcc.sh Release g++ ${COMMON_CMAKE_DEFS} -DBUILD_SHARED_LIBS=OFF
    cd Linux_Release && make -j$(nproc) && ./UnitTests && make install
}


build_assimp()
{
    cd $THIRDPARTY_DIR
    if [[ ! -d "assimp" ]]; then
        git clone --depth=1 --branch v6.0.4 https://github.com/assimp/assimp.git
    fi

    cd assimp
    cmake CMakeLists.txt \
        ${COMMON_CMAKE_DEFS} \
        -DBUILD_SHARED_LIBS=ON \
        -DASSIMP_NO_EXPORT=ON \
        -DASSIMP_BUILD_TESTS=OFF \
        -DASSIMP_BUILD_ZLIB=ON \
        -DASSIMP_USE_HUNTER=ON
    cmake --build . && cmake --install .
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
    if [[ ! -d "SDL_net" ]]; then
        git clone --depth=1 --branch release-3.2.0 --single-branch https://github.com/libsdl-org/SDL_net.git
    fi

    cd SDL
    cmake -S . -B build ${COMMON_CMAKE_DEFS} -DSDL_SHARED=ON
    cmake --build build --config $build_type
    cmake --install build --prefix "$INSTALL_PREFIX"

    cd ../SDL_image
    cmake -S . -B build ${COMMON_CMAKE_DEFS} -DSDL_SHARED=ON
    cmake --build build --config $build_type
    cmake --install build --prefix "$INSTALL_PREFIX"

    cd ../SDL_mixer
    cmake -S . -B build ${COMMON_CMAKE_DEFS} -DSDL_SHARED=ON
    cmake --build build --config $build_type
    cmake --install build --prefix "$INSTALL_PREFIX"

    cd ../SDL_net
    cmake -S . -B build ${COMMON_CMAKE_DEFS} -DSDL_SHARED=ON
    cmake --build build
    cmake --install build --prefix "$INSTALL_PREFIX"
}


build_slang()
{
    cd $THIRDPARTY_DIR
    if [[ ! -d "slang" ]]; then
        git clone --depth=1 --branch v2026.5.2 --single-branch https://github.com/shader-slang/slang.git --recursive
        # git clone --depth=1 --branch v2026.5.2 --single-branch https://github.com/shader-slang/slang.git
    fi

    cd slang
    git fetch https://github.com/shader-slang/slang.git 'refs/tags/*:refs/tags/*'

    # cmake --preset default -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
    # cmake --build --preset release
    # cmake --build . --target install
    # # cmake --build --preset <debug|release|releaseWithDebugInfo>
}


for key in "${!repo_opts[@]}"; do
    if [[ "${repo_opts[$key]}" == "1" ]]; then
        build_$key
    fi
done
