cmake_minimum_required(VERSION 3.31)
project(idk_vulkan_sdk)
include(GNUInstallDirs)

set(SDK_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/../../thirdparty/vulkan-sdk")
execute_process(
    COMMAND bash "${SDK_SOURCE}/unpack.sh"
    COMMAND_ERROR_IS_FATAL ANY
)

set(SDK_PREFIX "${SDK_SOURCE}/sdk/x86_64")
if(NOT EXISTS "${SDK_PREFIX}/bin/slangc")
    message(FATAL_ERROR "The prepared Vulkan SDK does not contain bin/slangc: ${SDK_PREFIX}")
endif()

# install(DIRECTORY) defaults to non-executable file permissions. SDK tools
# must retain their source permissions for CMake find_program() and execution.
install(DIRECTORY "${SDK_PREFIX}/bin/" DESTINATION "${CMAKE_INSTALL_BINDIR}" USE_SOURCE_PERMISSIONS)
install(DIRECTORY "${SDK_PREFIX}/include/" DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
install(DIRECTORY "${SDK_PREFIX}/lib/" DESTINATION "${CMAKE_INSTALL_LIBDIR}")
