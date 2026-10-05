cmake_minimum_required(VERSION 3.20)
project(airplay_multiroom_bridge VERSION 0.0.0 LANGUAGES C)

# Interface-only placeholder: no production implementation or public API yet.
add_library(amb INTERFACE)
add_library(amb::amb ALIAS amb)
target_compile_features(amb INTERFACE c_std_11)
target_include_directories(amb INTERFACE
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>")

include(CTest)
if(BUILD_TESTING)
    add_subdirectory(tests)
endif()
