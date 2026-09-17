
cmake_minimum_required(VERSION 3.23)

# a la ABI le afecta el compilador y la arquitectura
set(CMAKE_CXX_COMPILER g++) # clang, g++, msvc...
set(CMAKE_SYSTEM_PROCESSOR x86_64) # x86_64, x86, x64, armvh7, armel7...

# el tipo de build y el runtime puede afectar a la ABI igual
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG")

project(Tutorial)

add_subdirectory(Tutorial)

add_subdirectory(MathFunctions)
