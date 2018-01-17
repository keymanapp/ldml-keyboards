cmake_minimum_required(VERSION 3.9)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

project (ldml-keyboards)
add_executable(ldml-keyboards src/ldml-keyboards.cpp)
target_link_libraries(ldml-keyboards capnp)

add_custom_command ( TARGET ldml-keyboards
					 PRE_BUILD
					 COMMAND capnp compile -oc++ ${CMAKE_CURRENT_SOURCE_DIR}/src/ldmlman.capnp
					 WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src 
					 #COMMENT Compiles the Cap'N Proto spec into usable C++ source files.
				   )

add_subdirectory(capnproto/c++)
