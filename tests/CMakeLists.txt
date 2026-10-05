add_executable(amb_scaffold_test scaffold_test.c)
target_link_libraries(amb_scaffold_test PRIVATE amb::amb)
set_target_properties(amb_scaffold_test PROPERTIES
    C_STANDARD 11 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(amb_scaffold_test PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()
add_test(NAME scaffold.c11 COMMAND amb_scaffold_test)
set_tests_properties(scaffold.c11 PROPERTIES TIMEOUT 5)
