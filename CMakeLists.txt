cmake_minimum_required(VERSION 3.5)

project(idk_build VERSION 0.0.1)

if (NOT DEFINED IDK_POLY_DIR)
    message(FATAL_ERROR "IDK_POLY_DIR must be defined!")
elseif (NOT DEFINED IDK_BUILD_DIR)
    message(FATAL_ERROR "IDK_BUILD_DIR must be defined!")
elseif (NOT DEFINED IDK_OUTPUT_DIR)
    message(FATAL_ERROR "IDK_OUTPUT_DIR must be defined!")
elseif (NOT DEFINED IDK_TARGET_NAME)
    message(FATAL_ERROR "IDK_TARGET_NAME must be defined!")
endif()

message(STATUS "IDK_POLY_DIR: ${IDK_POLY_DIR}")
message(STATUS "IDK_BUILD_DIR: ${IDK_BUILD_DIR}")
message(STATUS "IDK_OUTPUT_DIR: ${IDK_OUTPUT_DIR}")
message(STATUS "IDK_TARGET_NAME: ${IDK_TARGET_NAME}")



# Thirdparty Libraries
# ----------------------------------------------------------------------------------------------
set(OpenGL_GL_PREFERENCE "GLVND")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIGURATION>")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIGURATION>")

# add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/repo/SDL" EXCLUDE_FROM_ALL)
# add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/repo/SDL_image" EXCLUDE_FROM_ALL)

# add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/repo/glm" EXCLUDE_FROM_ALL)
# find_package(glm CONFIG REQUIRED)
# target_link_libraries(main PRIVATE glm::glm-header-only)

# add_library(glm INTERFACE)
# target_include_directories(
#     glm INTERFACE
#     $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
#     $<INSTALL_INTERFACE:include>
# )

find_package(SDL3 REQUIRED)
find_package(glm REQUIRED)
find_package(Jolt REQUIRED)

message(STATUS "SDL3 found at: ${SDL3_DIR}")
message(STATUS "glm found at: ${glm_DIR}")
message(STATUS "Jolt found at: ${Jolt_DIR}")

# find_package(Jolt REQUIRED PATHS "${CMAKE_CURRENT_SOURCE_DIR}/lib/cmake" NO_DEFAULT_PATH)
# ----------------------------------------------------------------------------------------------

add_subdirectory("${IDK_POLY_DIR}/idk_core" "${IDK_BUILD_DIR}/idk_core")
add_subdirectory("${IDK_POLY_DIR}/idk_gfx" "${IDK_BUILD_DIR}/idk_gfx")
add_subdirectory("${IDK_POLY_DIR}/idk_engine" "${IDK_BUILD_DIR}/idk_engine")
add_subdirectory("${IDK_POLY_DIR}/${IDK_TARGET_NAME}" "${IDK_BUILD_DIR}/${IDK_TARGET_NAME}")

target_compile_options(
    ${IDK_TARGET_NAME} PUBLIC -Werror -Wall -Wextra
)

set_target_properties(
    ${IDK_TARGET_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${IDK_OUTPUT_DIR}"
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