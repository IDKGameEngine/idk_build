cmake_minimum_required(VERSION 3.31)

project(idk_build VERSION 0.0.1)
set(CMAKE_COLOR_DIAGNOSTICS ON)

if (NOT DEFINED IDK_APP_NAME)
    message(FATAL_ERROR "IDK_APP_NAME must be defined!")
elseif (NOT DEFINED IDK_POLY_DIR)
    message(FATAL_ERROR "IDK_POLY_DIR must be defined!")
elseif (NOT DEFINED IDK_CMAKE_DIR)
    message(FATAL_ERROR "IDK_CMAKE_DIR must be defined!")
elseif (NOT DEFINED IDK_OUTPUT_DIR)
    message(FATAL_ERROR "IDK_OUTPUT_DIR must be defined!")
elseif (NOT DEFINED IDK_ASSETS_DIRNAME)
    message(FATAL_ERROR "IDK_ASSETS_DIRNAME must be defined!")
endif()

message(STATUS "IDK_POLY_DIR: ${IDK_POLY_DIR}")
message(STATUS "IDK_CMAKE_DIR: ${IDK_CMAKE_DIR}")
message(STATUS "IDK_OUTPUT_DIR: ${IDK_OUTPUT_DIR}")
message(STATUS "IDK_ASSETS_DIRNAME: ${IDK_ASSETS_DIRNAME}")
message(STATUS "IDK_GFX_MODEL=${IDK_GFX_MODEL}")

# include("${CMAKE_CURRENT_SOURCE_DIR}/ThirdParty.cmake")
set(OpenGL_GL_PREFERENCE "GLVND")
include("${CMAKE_CURRENT_SOURCE_DIR}/submodule/CMakeLists.txt")

add_compile_definitions(IDK_ASSETS_DIRNAME="${IDK_ASSETS_DIRNAME}")
add_compile_options(-Werror -Wall -Wextra)

# ubsan
# ----------------------------------------------------------------------------------------------
add_compile_options(-fsanitize=address,undefined)
add_link_options(-fsanitize=address,undefined)
# ----------------------------------------------------------------------------------------------

add_subdirectory("${IDK_POLY_DIR}/libidk" "${IDK_CMAKE_DIR}/libidk")
add_subdirectory("${IDK_POLY_DIR}/idk_gfx" "${IDK_CMAKE_DIR}/idk_gfx")
add_subdirectory("${IDK_POLY_DIR}/idk_engine" "${IDK_CMAKE_DIR}/idk_engine")
add_subdirectory("${IDK_POLY_DIR}/idk_game" "${IDK_CMAKE_DIR}/idk_game")
