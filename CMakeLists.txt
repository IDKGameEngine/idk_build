cmake_minimum_required(VERSION 3.5)

project(idk_build VERSION 0.0.1)
add_compile_options(-Werror -Wall -Wextra)

if (NOT DEFINED IDK_ROOT_DIR)
    message(FATAL_ERROR "IDK_ROOT_DIR must be defined!")
elseif (NOT DEFINED IDK_BUILD_DIR)
    message(FATAL_ERROR "IDK_BUILD_DIR must be defined!")
elseif (NOT DEFINED IDK_OUTPUT_DIR)
    message(FATAL_ERROR "IDK_OUTPUT_DIR must be defined!")
elseif (NOT DEFINED IDK_TARGET_NAME)
    message(FATAL_ERROR "IDK_TARGET_NAME must be defined!")
endif()

message(STATUS "IDK_ROOT_DIR: ${IDK_ROOT_DIR}")
message(STATUS "IDK_BUILD_DIR: ${IDK_BUILD_DIR}")
message(STATUS "IDK_OUTPUT_DIR: ${IDK_OUTPUT_DIR}")
message(STATUS "IDK_TARGET_NAME: ${IDK_TARGET_NAME}")

set(OpenGL_GL_PREFERENCE "GLVND")

add_subdirectory("${IDK_ROOT_DIR}/libidk" "${IDK_BUILD_DIR}/libidk")
add_subdirectory("${IDK_ROOT_DIR}/idk_core" "${IDK_BUILD_DIR}/idk_core")
add_subdirectory("${IDK_ROOT_DIR}/idk_gfx" "${IDK_BUILD_DIR}/idk_gfx")
add_subdirectory("${IDK_ROOT_DIR}/idk_platform" "${IDK_BUILD_DIR}/idk_platform")
add_subdirectory("${IDK_ROOT_DIR}/${IDK_TARGET_NAME}" "${IDK_BUILD_DIR}/${IDK_TARGET_NAME}")

set_target_properties(
    ${IDK_TARGET_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${IDK_OUTPUT_DIR}"
    RUNTIME_OUTPUT_NAME "game"
)

# configure_file(
#     "${PROJECT_SOURCE_DIR}/version.h.in"
#     "${PROJECT_BINARY_DIR}/version.h"
# )

# add_executable(
#     ${PROJECT_NAME} "src/main.cpp"
# )
# target_compile_features(
#     ${PROJECT_NAME} PUBLIC cxx_std_23
# )
# target_link_libraries(
#     ${PROJECT_NAME} PUBLIC idk_platform idk_gfx
# )