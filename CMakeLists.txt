cmake_minimum_required(VERSION 3.31)

project(idk_build VERSION 0.0.1)
set(CMAKE_COLOR_DIAGNOSTICS ON)

if (NOT DEFINED IDK_APP_NAME)
    message(FATAL_ERROR "IDK_APP_NAME must be defined!")
elseif (NOT DEFINED IDK_POLY_DIR)
    message(FATAL_ERROR "IDK_POLY_DIR must be defined!")
endif()

if (DEFINED IDK_RUNTIME_NATIVE)
    add_compile_definitions(IDK_RUNTIME_NATIVE="1")
elseif (DEFINED IDK_RUNTIME_STEAMRT4)
    add_compile_definitions(IDK_RUNTIME_STEAMRT4="1")
endif()

add_compile_options(-Werror -Wall -Wextra)
include("${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/CMakeLists.txt")

# ubsan
# ----------------------------------------------------------------------------------------------
add_compile_options(-fsanitize=address,undefined)
add_link_options(-fsanitize=address,undefined)
# ----------------------------------------------------------------------------------------------

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

set(IDK_REPO_NAMES 
    libidk
    idk_gfx
    idk_engine
    idk_game
)

foreach(IDK_REPO_NAME IN LISTS IDK_REPO_NAMES)
    add_subdirectory(
        "${IDK_POLY_DIR}/${IDK_REPO_NAME}" "${CMAKE_BINARY_DIR}/${IDK_REPO_NAME}"
    )
    # install(
    #     DIRECTORY "${IDK_POLY_DIR}/${IDK_REPO_NAME}/data"
    #     DESTINATION "${CMAKE_INSTALL_PREFIX}/"
    # )
endforeach()

# add_subdirectory("${IDK_POLY_DIR}/libidk" "${CMAKE_BINARY_DIR}/libidk")
# add_subdirectory("${IDK_POLY_DIR}/idk_gfx" "${CMAKE_BINARY_DIR}/idk_gfx")
# add_subdirectory("${IDK_POLY_DIR}/idk_engine" "${CMAKE_BINARY_DIR}/idk_engine")
# add_subdirectory("${IDK_POLY_DIR}/idk_game" "${CMAKE_BINARY_DIR}/idk_game")

install(DIRECTORY "${IDK_POLY_DIR}/idk_gfx/data" DESTINATION "${CMAKE_INSTALL_PREFIX}/")
# install(DIRECTORY "${IDK_POLY_DIR}/idk_engine/data" DESTINATION "${CMAKE_INSTALL_PREFIX}/")
# install(DIRECTORY "${IDK_POLY_DIR}/idk_game/data" DESTINATION "${CMAKE_INSTALL_PREFIX}/")

file(GLOB SHARED_LIBRARY_FILES "${CMAKE_PREFIX_PATH}/lib/*.so*")
install(FILES ${SHARED_LIBRARY_FILES} DESTINATION "${CMAKE_INSTALL_LIBDIR}/")
