cmake_minimum_required(VERSION 3.5)

project(idk_build VERSION 0.0.1)

if (NOT DEFINED IDK_POLY_DIR)
    message(FATAL_ERROR "IDK_POLY_DIR must be defined!")
elseif (NOT DEFINED IDK_CMAKE_DIR)
    message(FATAL_ERROR "IDK_CMAKE_DIR must be defined!")
elseif (NOT DEFINED IDK_OUTPUT_DIR)
    message(FATAL_ERROR "IDK_OUTPUT_DIR must be defined!")
elseif (NOT DEFINED IDK_TARGET_NAME)
    message(FATAL_ERROR "IDK_TARGET_NAME must be defined!")
endif()

message(STATUS "IDK_POLY_DIR: ${IDK_POLY_DIR}")
message(STATUS "IDK_CMAKE_DIR: ${IDK_CMAKE_DIR}")
message(STATUS "IDK_OUTPUT_DIR: ${IDK_OUTPUT_DIR}")
message(STATUS "IDK_TARGET_NAME: ${IDK_TARGET_NAME}")



# Thirdparty Libraries
# ----------------------------------------------------------------------------------------------
set(OpenGL_GL_PREFERENCE "GLVND")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIGURATION>")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIGURATION>")

find_package(SDL3 REQUIRED)
find_package(glm CONFIG REQUIRED PATHS "${CMAKE_PREFIX_PATH}/share" NO_DEFAULT_PATH)
find_package(Jolt REQUIRED)

message(STATUS "SDL3 found at: ${SDL3_DIR}")
message(STATUS "glm found at: ${glm_DIR}")
message(STATUS "Jolt found at: ${Jolt_DIR}")

# find_package(Jolt REQUIRED PATHS "${CMAKE_CURRENT_SOURCE_DIR}/lib/cmake" NO_DEFAULT_PATH)
# ----------------------------------------------------------------------------------------------

add_subdirectory("${IDK_POLY_DIR}/idk_core" "${IDK_CMAKE_DIR}/idk_core")
add_subdirectory("${IDK_POLY_DIR}/idk_gfx" "${IDK_CMAKE_DIR}/idk_gfx")
add_subdirectory("${IDK_POLY_DIR}/idk_engine" "${IDK_CMAKE_DIR}/idk_engine")
add_subdirectory("${IDK_POLY_DIR}/${IDK_TARGET_NAME}" "${IDK_CMAKE_DIR}/${IDK_TARGET_NAME}")

target_compile_options(
    ${IDK_TARGET_NAME} PUBLIC -Werror -Wall -Wextra
)

set_target_properties(
    ${IDK_TARGET_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${IDK_OUTPUT_DIR}"
    BUILD_RPATH "$ORIGIN/lib"
)

execute_process(
    COMMAND bash "${CMAKE_CURRENT_SOURCE_DIR}/script/version.sh" "--header" "./include/idk"
    WORKING_DIRECTORY "${IDK_POLY_DIR}/idk"
    RESULT_VARIABLE hpp_ret
    OUTPUT_VARIABLE hpp_out
)
if(NOT hpp_ret EQUAL 0)
    message(FATAL_ERROR "Script failed: ${hpp_ret}, result: ${hpp_out}")
endif()


execute_process(
    COMMAND bash "${CMAKE_CURRENT_SOURCE_DIR}/script/version.sh" "--text" "./"
    WORKING_DIRECTORY "${IDK_OUTPUT_DIR}"
    RESULT_VARIABLE txt_ret
    OUTPUT_VARIABLE txt_out
)
if(NOT txt_ret EQUAL 0)
    message(FATAL_ERROR "Script failed: ${txt_ret}, result: ${txt_out}")
endif()


# install(
#     IMPORTED_RUNTIME_ARTIFACTS
#         SDL3::SDL3-shared
#         Jolt::Jolt
#     RUNTIME DESTINATION ${IDK_OUTPUT_DIR}/bin
#     LIBRARY DESTINATION ${IDK_OUTPUT_DIR}/lib
# )