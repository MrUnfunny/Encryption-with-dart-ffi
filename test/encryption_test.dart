import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io' show Platform;
import 'package:test/test.dart';

// FFI type definitions (copied from encryption.dart)
typedef GenerateKeyFunc = Int32 Function();
typedef GenerateKey = int Function();

typedef EncryptionFunc = Pointer<Utf8> Function(Pointer<Utf8> msg, Int32 length, Int32 key);
typedef Encryption = Pointer<Utf8> Function(Pointer<Utf8> msg, int length, int key);

typedef DecryptionFunc = Pointer<Utf8> Function(Pointer<Utf8> msg, Int32 length, Int32 key);
typedef Decryption = Pointer<Utf8> Function(Pointer<Utf8> msg, int length, int key);

// Helper function to open the dynamic library
DynamicLibrary openEncryptionLibrary() {
  var path = './encryption_library/libencryption.so'; // For Linux
  if (Platform.isMacOS) {
    path = './encryption_library/libencryption.dylib';
  }
  if (Platform.isWindows) {
    // Assuming the DLL is in encryption_library/Debug/encryption.dll as per original encryption.dart
    // This might need adjustment based on actual CMake build output (e.g., Release folder)
    path = r'encryption_library\Debug\encryption.dll';
  }
  return DynamicLibrary.open(path);
}

void main() {
  group('FFI Encryption Tests', () {
    late DynamicLibrary dylib;
    late GenerateKey generateKey;
    late Encryption encryption;
    late Decryption decryption;

    setUpAll(() {
      dylib = openEncryptionLibrary();

      final generateKeyPointer = dylib.lookup<NativeFunction<GenerateKeyFunc>>('generateKey');
      generateKey = generateKeyPointer.asFunction<GenerateKey>();

      final encryptionPointer = dylib.lookup<NativeFunction<EncryptionFunc>>('encryption');
      encryption = encryptionPointer.asFunction<Encryption>();

      final decryptionPointer = dylib.lookup<NativeFunction<DecryptionFunc>>('decryption');
      decryption = decryptionPointer.asFunction<Decryption>();
    });

    test('Library can be opened', () {
      expect(openEncryptionLibrary, returnsNormally);
    });

    test('generateKey returns a key within the valid range [0, 10]', () {
      for (int i = 0; i < 10; i++) {
        int key = generateKey();
        expect(key, greaterThanOrEqualTo(0), reason: "Key $key was not >= 0");
        expect(key, lessThanOrEqualTo(10), reason: "Key $key was not <= 10");
      }
    });

    // Define test cases for encryption/decryption
    final List<Map<String, dynamic>> testCases = [
      {'description': 'simple lowercase string', 'original': 'hello world', 'key': 3},
      {'description': 'mixed case string', 'original': 'HeLlO wOrLd', 'key': 5},
      {'description': 'string with numbers and symbols', 'original': 'Test123!@#\$%', 'key': 7},
      {'description': 'empty string', 'original': '', 'key': 2},
      {'description': 'string with key 0 (no change)', 'original': 'nochange', 'key': 0},
      {'description': 'string with max key (10)', 'original': 'maxkeytest', 'key': 10},
      // Add a test case that might have been problematic if generateKey() was used directly and produced 0
      {'description': 'another simple string', 'original': 'another test', 'key': generateKey()}, 
    ];

    for (final tc in testCases) {
      test('Encryption/Decryption: ${tc['description']}', () {
        final String originalMessage = tc['original'];
        // If key is dynamic (from generateKey), resolve it. Otherwise, use the fixed key.
        final int key = tc['key'] is int ? tc['key'] : (tc['key'] as GenerateKey)();
        
        // Ensure dynamic keys are also within valid range for the test itself
        if (tc['key'] is GenerateKey) {
            expect(key, greaterThanOrEqualTo(0), reason: "Generated key $key for test was not >= 0");
            expect(key, lessThanOrEqualTo(10), reason: "Generated key $key for test was not <= 10");
        }

        Pointer<Utf8> originalMessageC = nullptr;
        Pointer<Utf8> encryptedMessageC = nullptr;
        Pointer<Utf8> encryptedMessageToDecryptC = nullptr;
        Pointer<Utf8> decryptedMessageC = nullptr;

        try {
          originalMessageC = originalMessage.toUtf8(allocator: calloc);
          
          encryptedMessageC = encryption(originalMessageC, originalMessage.length, key);
          expect(encryptedMessageC, isNot(nullptr), reason: "Encryption returned null pointer");
          final encryptedMessageDart = encryptedMessageC.toDartString(length: originalMessage.length); // Specify length for safety, though not strictly needed if null-terminated.

          encryptedMessageToDecryptC = encryptedMessageDart.toUtf8(allocator: calloc);

          decryptedMessageC = decryption(encryptedMessageToDecryptC, encryptedMessageDart.length, key);
          expect(decryptedMessageC, isNot(nullptr), reason: "Decryption returned null pointer");
          final decryptedMessageDart = decryptedMessageC.toDartString(length: originalMessage.length);

          expect(decryptedMessageDart, equals(originalMessage),
              reason: "Decrypted message did not match original. Original: '$originalMessage', Key: $key, Encrypted: '$encryptedMessageDart', Decrypted: '$decryptedMessageDart'");
        } finally {
          // Free all allocated C memory
          if (originalMessageC != nullptr) calloc.free(originalMessageC);
          // encryptedMessageC and decryptedMessageC are allocated by C functions (assumed via malloc/calloc)
          // and should be freed by a C free function if not handled by Dart's GC through a special mechanism
          // or if the C library doesn't expose a free function.
          // Given the C code uses malloc, and we are in Dart, we must call free on these.
          // The C functions provided do not have a separate free function, so we assume they return
          // pointers that should be freed by the standard C `free` (which `calloc.free` can do).
          if (encryptedMessageC != nullptr) calloc.free(encryptedMessageC);
          if (encryptedMessageToDecryptC != nullptr) calloc.free(encryptedMessageToDecryptC);
          if (decryptedMessageC != nullptr) calloc.free(decryptedMessageC);
        }
      });
    }
  });
}
