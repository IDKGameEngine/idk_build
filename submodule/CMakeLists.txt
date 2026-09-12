add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/submodule/glad")
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/submodule/glm")
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/submodule/imgui")

find_package(assimp REQUIRED)
file(GLOB ASSIMP_FILES "${CMAKE_PREFIX_PATH}/lib/libassimp*.so*")
install(FILES ${ASSIMP_FILES} DESTINATION "${IDK_OUTPUT_DIR}/lib")

find_package(Jolt REQUIRED)

find_package(volk CONFIG REQUIRED)
find_package(vk-bootstrap CONFIG REQUIRED)
find_package(VulkanMemoryAllocator CONFIG REQUIRED)
