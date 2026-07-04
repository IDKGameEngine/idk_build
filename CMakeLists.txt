cmake_minimum_required(VERSION 4.2)

project(idk_build VERSION 0.0.1)
set(CMAKE_COLOR_DIAGNOSTICS ON)

if (NOT DEFINED IDK_POLY_DIR)
    message(FATAL_ERROR "IDK_POLY_DIR must be defined!")
elseif (NOT DEFINED IDK_CMAKE_DIR)
    message(FATAL_ERROR "IDK_CMAKE_DIR must be defined!")
elseif (NOT DEFINED IDK_OUTPUT_DIR)
    message(FATAL_ERROR "IDK_OUTPUT_DIR must be defined!")
elseif (NOT DEFINED IDK_ASSETS_DIRNAME)
    message(FATAL_ERROR "IDK_ASSETS_DIRNAME must be defined!")
elseif (NOT DEFINED IDK_TARGET_NAME)
    message(FATAL_ERROR "IDK_TARGET_NAME must be defined!")
endif()

message(STATUS "IDK_POLY_DIR: ${IDK_POLY_DIR}")
message(STATUS "IDK_CMAKE_DIR: ${IDK_CMAKE_DIR}")
message(STATUS "IDK_OUTPUT_DIR: ${IDK_OUTPUT_DIR}")
message(STATUS "IDK_ASSETS_DIRNAME: ${IDK_ASSETS_DIRNAME}")
message(STATUS "IDK_TARGET_NAME: ${IDK_TARGET_NAME}")

add_compile_definitions(IDK_ASSETS_DIRNAME="${IDK_ASSETS_DIRNAME}")

# Thirdparty Libraries
# ----------------------------------------------------------------------------------------------
set(OpenGL_GL_PREFERENCE "GLVND")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIGURATION>")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIGURATION>")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${IDK_OUTPUT_DIR}")
set(CMAKE_BUILD_RPATH "$ORIGIN/lib")

find_package(SDL3 REQUIRED)
find_package(SDL3_image REQUIRED)
find_package(SDL3_net REQUIRED)
find_package(glm CONFIG REQUIRED PATHS "${CMAKE_PREFIX_PATH}/share" NO_DEFAULT_PATH)
find_package(Jolt REQUIRED)

message(STATUS "SDL3 found at: ${SDL3_DIR}")
message(STATUS "SDL3_image found at: ${SDL3_image_DIR}")
message(STATUS "SDL3_net found at: ${SDL3_net_DIR}")
message(STATUS "glm found at: ${glm_DIR}")
message(STATUS "Jolt found at: ${Jolt_DIR}")

# find_package(Jolt REQUIRED PATHS "${CMAKE_CURRENT_SOURCE_DIR}/lib/cmake" NO_DEFAULT_PATH)
# ----------------------------------------------------------------------------------------------
add_compile_options(-Werror -Wall -Wextra)

# if (debug)
add_compile_options(-fsanitize=address,undefined)
add_link_options(-fsanitize=address,undefined)
# endif()

add_subdirectory("${IDK_POLY_DIR}/idk_core" "${IDK_CMAKE_DIR}/idk_core")
add_subdirectory("${IDK_POLY_DIR}/idk_gfx" "${IDK_CMAKE_DIR}/idk_gfx")
add_subdirectory("${IDK_POLY_DIR}/idk_engine" "${IDK_CMAKE_DIR}/idk_engine")
add_subdirectory("${IDK_POLY_DIR}/${IDK_TARGET_NAME}" "${IDK_CMAKE_DIR}/${IDK_TARGET_NAME}")

# target_compile_options(
#     ${IDK_TARGET_NAME} PUBLIC -Werror -Wall -Wextra -fsanitize=address,undefined
# )

# set_target_properties(
#     ${IDK_TARGET_NAME} PROPERTIES
#     RUNTIME_OUTPUT_DIRECTORY "${IDK_OUTPUT_DIR}"
#     BUILD_RPATH "$ORIGIN/lib"
# )

execute_process(
    COMMAND bash "${CMAKE_CURRENT_SOURCE_DIR}/script/version.sh" "--header" "--text"
    WORKING_DIRECTORY "${IDK_POLY_DIR}"
)


# install(
#     IMPORTED_RUNTIME_ARTIFACTS
#         SDL3::SDL3-shared
#         Jolt::Jolt
#     RUNTIME DESTINATION ${IDK_OUTPUT_DIR}/bin
#     LIBRARY DESTINATION ${IDK_OUTPUT_DIR}/lib
# )