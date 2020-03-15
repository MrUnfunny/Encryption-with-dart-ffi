cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(encryption_library VERSION 1.0.0 LANGUAGES C)
add_library(encryption_library SHARED encryption.c encryption.def)
add_executable(encryption_test encryption.c)

set_target_properties(encryption_library PROPERTIES
    PUBLIC_HEADER encryption.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "encryption"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)
