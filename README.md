# Encryption-with-dart-ffi
A Simple Encryption program using functions written in c with the help of dart:ffi

## Running this on your system:

For running this on your system, you need to install [dart-sdk](https://dart.dev/get-dart) and [CMake](https://cmake.org/download/).

## Building Native C Library:

CMake is used for building this C Library. Run following commands to build the library.
```
cd Encryption-with-dart-ffi/encryption_library
cmake .
make.
```

## Getting Depencies for dart

Pub, the package manager of Dart is used to building all dependencies required by the Dart Program.
Run following commands to get the required dependencies.
```
cd Encryption-with-dart-ffi
pub get
```

## Building and Running Tests

This project includes unit tests for the C encryption library and integration tests for the Dart FFI calls.

### 1. C Unit Tests

The C unit tests verify the core encryption, decryption, and key generation logic.

**Prerequisites:**
*   CMake (version 3.10 or higher)
*   A C compiler (e.g., GCC, Clang)
*   Make (or your chosen CMake build tool)

**Steps to build and run:**

1.  Navigate to the `encryption_library` directory:
    ```bash
    cd encryption_library
    ```
2.  Configure the build using CMake:
    ```bash
    cmake .
    ```
3.  Build the tests (and the library):
    ```bash
    make
    ```
4.  Run the C tests:
    ```bash
    ctest
    ```
    Or, you can directly run the test executable:
    ```bash
    ./run_c_tests 
    ```
    (On Windows, it might be `.\Debug\run_c_tests.exe` or `.\Release\run_c_tests.exe` depending on the build configuration).

    You should see output indicating whether the tests passed or failed.

### 2. Dart FFI Integration Tests

The Dart tests verify that the Dart code correctly interacts with the C library via FFI.

**Prerequisites:**
*   Dart SDK (version specified in `pubspec.yaml`, e.g., '>=2.19.0 <3.0.0')
*   Ensure the C library (`libencryption.so`, `libencryption.dylib`, or `encryption.dll`) has been built. You can do this by following steps 1-3 for the C Unit Tests above, as building `make` in `encryption_library` should also produce the shared library.

**Steps to run:**

1.  Navigate to the root project directory (if you're not already there).
2.  Get the Dart dependencies:
    ```bash
    dart pub get
    ```
3.  Run the Dart tests:
    ```bash
    dart test
    ```
    This command will discover and run tests in the `test/` directory. You should see output indicating the results of the tests.
