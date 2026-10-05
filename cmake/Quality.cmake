# Developer-only checks; normal builds do not require these tools.
find_program(AMB_CLANG_FORMAT NAMES clang-format-18 clang-format REQUIRED)
find_program(AMB_CLANG_TIDY NAMES clang-tidy-18 clang-tidy REQUIRED)

foreach(tool IN ITEMS AMB_CLANG_FORMAT AMB_CLANG_TIDY)
    execute_process(COMMAND "${${tool}}" --version
        OUTPUT_VARIABLE tool_version ERROR_VARIABLE tool_error
        RESULT_VARIABLE tool_result)
    if(NOT tool_result EQUAL 0 OR NOT tool_version MATCHES "version 18\\.1\\.8([^0-9]|$)")
        message(FATAL_ERROR "${tool} must be version 18.1.8: ${tool_version}${tool_error}")
    endif()
endforeach()

# Globbing is limited to check targets, never used to define library sources.
file(GLOB_RECURSE amb_format_sources CONFIGURE_DEPENDS
    "${PROJECT_SOURCE_DIR}/src/*.c" "${PROJECT_SOURCE_DIR}/src/*.h"
    "${PROJECT_SOURCE_DIR}/include/*.h"
    "${PROJECT_SOURCE_DIR}/tests/*.c" "${PROJECT_SOURCE_DIR}/tests/*.h")
add_custom_target(format-check
    COMMAND "${AMB_CLANG_FORMAT}" --dry-run --Werror ${amb_format_sources}
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}" VERBATIM)
add_custom_target(format
    COMMAND "${AMB_CLANG_FORMAT}" -i ${amb_format_sources}
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}" VERBATIM)

# Analyze only translation units present in this build's compilation database.
# Explicit source targets remain authoritative; headers are checked via includes.
find_package(Python3 3.8 REQUIRED COMPONENTS Interpreter)
add_custom_target(lint
    COMMAND "${Python3_EXECUTABLE}" "${PROJECT_SOURCE_DIR}/tools/lint.py"
        "${AMB_CLANG_TIDY}" "${PROJECT_BINARY_DIR}/compile_commands.json"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}" VERBATIM)
