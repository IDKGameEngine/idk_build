# # Assimp
# # ------------------------------------------------------------------------------------------
# find_package(assimp REQUIRED)
# message(STATUS "assimp found at: ${Assimp_DIR}")

# file(GLOB ASSIMP_FILES "${CMAKE_PREFIX_PATH}/lib/libassimp*.so*")
# install(FILES ${ASSIMP_FILES} DESTINATION "${IDK_OUTPUT_DIR}/lib")
# # ------------------------------------------------------------------------------------------


# # OpenGL
# # ------------------------------------------------------------------------------------------
# set(OpenGL_GL_PREFERENCE "GLVND")
# set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${IDK_OUTPUT_DIR}")
# set(CMAKE_BUILD_RPATH "$ORIGIN/lib")
# # ------------------------------------------------------------------------------------------


# # Jolt
# # ------------------------------------------------------------------------------------------
# find_package(Jolt REQUIRED)
# message(STATUS "Jolt found at: ${Jolt_DIR}")

# file(GLOB JOLT_FILES "${CMAKE_PREFIX_PATH}/lib/libJolt*.so*")
# install(FILES ${JOLT_FILES} DESTINATION "${IDK_OUTPUT_DIR}/lib")
# # ------------------------------------------------------------------------------------------


# # SDL3
# # ------------------------------------------------------------------------------------------
# find_package(SDL3 REQUIRED)
# find_package(SDL3_image REQUIRED)
# find_package(SDL3_mixer REQUIRED)
# find_package(SDL3_net REQUIRED)

# message(STATUS "SDL3 found at: ${SDL3_DIR}")
# message(STATUS "SDL3_image found at: ${SDL3_image_DIR}")
# message(STATUS "SDL3_mixer found at: ${SDL3_mixer_DIR}")
# message(STATUS "SDL3_net found at: ${SDL3_net_DIR}")

# file(GLOB SDL3_FILES "${CMAKE_PREFIX_PATH}/lib/libSDL3*.so*")
# install(FILES ${SDL3_FILES} DESTINATION "${IDK_OUTPUT_DIR}/lib")
# # ------------------------------------------------------------------------------------------

