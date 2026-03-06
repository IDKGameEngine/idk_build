
set(OpenGL_GL_PREFERENCE "GLVND")

add_library(glm INTERFACE)
target_include_directories(
    glm INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)


find_package(Jolt REQUIRED PATHS "${CMAKE_CURRENT_SOURCE_DIR}/lib/cmake" NO_DEFAULT_PATH)

