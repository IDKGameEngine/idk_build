cmake_minimum_required(VERSION 3.31)

project(idk_build VERSION 0.0.1)
set(CMAKE_COLOR_DIAGNOSTICS ON)
set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

if (NOT DEFINED IDK_APP_NAME)
    message(FATAL_ERROR "IDK_APP_NAME must be defined!")
elseif (NOT DEFINED IDK_POLY_DIR)
    message(FATAL_ERROR "IDK_POLY_DIR must be defined!")
elseif (NOT DEFINED IDK_CONTENT_BASEPATH)
    message(FATAL_ERROR "IDK_CONTENT_BASEPATH must be defined!")
endif()

include(GNUInstallDirs)
include_directories("${CMAKE_PREFIX_PATH}/include")
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/thirdparty")

add_compile_definitions(IDK_CONTENT_BASEPATH="${IDK_CONTENT_BASEPATH}")
add_compile_options(-Werror -Wall -Wextra)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_definitions(IDK_DEBUG="1")
    # add_compile_options(-fsanitize=address,undefined)
    # add_link_options(-fsanitize=address,undefined)
endif()


set(IDK_REPO_NAMES 
    idk_engine
    idk_content
    idk_game
    libidk
)

foreach(REPO_NAME IN LISTS IDK_REPO_NAMES)
    add_subdirectory("${IDK_POLY_DIR}/${REPO_NAME}" "${CMAKE_BINARY_DIR}/${REPO_NAME}")
endforeach()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    file(GLOB SHARED_LIBRARY_FILES "${CMAKE_PREFIX_PATH}/lib/*.so*")
    install(FILES ${SHARED_LIBRARY_FILES} DESTINATION "${CMAKE_INSTALL_LIBDIR}/")
endif()
