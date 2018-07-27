cmake_minimum_required(VERSION 3.0.0)

set(ETH_CMAKE_DIR   "${CMAKE_CURRENT_LIST_DIR}/cmake"   CACHE PATH "The the path to the cmake directory")
list(APPEND CMAKE_MODULE_PATH ${ETH_CMAKE_DIR})

# project name and version should be set after cmake_policy CMP0048
set(PROJECT_VERSION "0.0.1")
project(solidity VERSION ${PROJECT_VERSION})
