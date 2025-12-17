cmake_minimum_required(VERSION 3.20.0)
project(my_hello)
set(CMAKE_CXX_STANDARD 11)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin)  # 设置动态库和可执行文件输出路径(Windows)
# set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin)  # Linux下动态库输出路径
# set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin)  # Linux下静态库输出路径

aux_source_directory(${PROJECT_SOURCE_DIR}/src SRC_LIST)  # 添加源文件目录

add_library(  # 生成动态库
    common
    SHARED
    ${SRC_LIST}
)

target_include_directories(  # 为动态库添加头文件目录
    common
    PUBLIC
    ${PROJECT_SOURCE_DIR}/include
)

add_executable(CMakeTest main.cpp)  # 生成主程序

target_include_directories(  # 为项目主程序添加头文件目录
    CMakeTest
    PUBLIC
    ${PROJECT_SOURCE_DIR}/include
)

target_link_libraries(  # 链接动态库到主程序
    CMakeTest
    PUBLIC
    common
)
