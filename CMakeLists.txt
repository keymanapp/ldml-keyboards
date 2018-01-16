cmake_minimum_required(VERSION 3.9)

project (ldml-keyboards)

add_subdirectory(capnproto/c++)

add_executable(ldml-keyboards src/ldml-keyboards.cpp)