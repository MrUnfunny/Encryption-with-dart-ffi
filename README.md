# Encryption-with-dart-ffi
A Simple Encryption program using functions written in c with the help of dart:ffi

## Running this on your system:

For running this on your system, you need to install [dart-sdk](https://dart.dev/get-dart) and [CMake](https://cmake.org/download/).

## Building Native C Library:

CMake is used for building this C Library. Run following commands to build the library.
'''
cd Encryption-with-dart-ffi/encryption_library
cmake .
make.
'''

## Getting Depencies for dart

Pub, the package manager of Dart is used to building all dependencies required by the Dart Program.
Run following commands to get the required dependencies.
'''
cd Encryption-with-dart-ffi
pub get
'''


