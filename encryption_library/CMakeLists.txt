cmake_minimum_required(VERSION 3.7 FATAL_ERROR) # Keep or update to 3.10 if specific features are needed, 3.7 is fine.
include(CTest) # For CTest integration

project(encryption_library VERSION 1.0.0 LANGUAGES C)
enable_testing() # Enable testing framework

add_library(encryption_library SHARED encryption.c encryption.def)
# Remove the old executable: add_executable(encryption_test encryption.c)

# Add executable for C unit tests
# This compiles encryption.c and test_encryption.c together into one executable
add_executable(run_c_tests test_encryption.c encryption.c)

# Add the test to CTest
add_test(NAME CEncryptionTests COMMAND run_c_tests)

set_target_properties(encryption_library PROPERTIES
    PUBLIC_HEADER encryption.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "encryption"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)
