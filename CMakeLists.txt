cmake_minimum_required(VERSION 3.16)

# Project definition
project(OpenAutoTransport_client VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard and libc++ flags 
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -lc++abi")

# Fetch Cap'n Proto v1.1.0
include(FetchContent)
FetchContent_Declare(
  capnproto
  GIT_REPOSITORY https://github.com/capnproto/capnproto.git
  GIT_TAG v1.1.0
)

# Make Cap'n Proto available
FetchContent_MakeAvailable(capnproto)

# Configure OpenAutoTransport
set(OAT_VARIANT "amd64_gnu")  # Adjust based on your system
set(OAT_LINKAGE "STATIC")
include(cmake/OpenAutoTransport.cmake)

# Create executable
add_executable(${PROJECT_NAME} src/main.cpp)

# Link OpenAutoTransport library and Cap'n Proto
target_link_libraries(${PROJECT_NAME} PRIVATE 
    open_auto_transport::open_auto_transport
    capnp
    kj
    pthread
)

# Set output directory
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)