cmake_minimum_required(VERSION 3.9)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

project (ldml-keyboards)
add_executable(ldml-keyboards src/ldml-keyboards.cpp)
target_link_libraries(ldml-keyboards capnp)

add_subdirectory(capnproto/c++)
