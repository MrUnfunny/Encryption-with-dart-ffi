#include <stdio.h>
#include <stdlib.h>
#include <string.h> // Added for strcmp and strcpy
#include <time.h>
#include "encryption.h"

// Test function for generateKey
int test_generateKey() {
    int errors = 0;
    int key;
    for (int i = 0; i < 100; i++) {
        key = generateKey();
        if (key < 0 || key > 10) {
            fprintf(stderr, "Error: generateKey() produced out-of-range key: %d\n", key);
            errors++;
        }
    }
    return errors;
}

// Structure for encryption/decryption test cases
typedef struct {
    char* original;
    int key;
    char* description;
} TestCase;

// Test function for encryption and decryption
int test_encryption_decryption() {
    int errors = 0;

    TestCase tests[] = {
        {"hello", 3, "Simple lowercase string"},
        {"HeLLo", 5, "Mixed case string"},
        {"test123", 7, "String with numbers"},
        {"", 2, "Empty string"},
        {"world", 10, "String with max key"},
        {"nochange", 0, "String with key 0"}
    };
    int num_tests = sizeof(tests) / sizeof(tests[0]);

    for (int i = 0; i < num_tests; i++) {
        char* original_str = tests[i].original;
        int key = tests[i].key;
        int len = strlen(original_str);

        // Encryption allocates new memory
        char* encrypted_output = encryption(original_str, len, key);
        if (encrypted_output == NULL) {
            fprintf(stderr, "Error in test: %s\n", tests[i].description);
            fprintf(stderr, "  encryption() returned NULL for original: '%s', key: %d\n", original_str, key);
            errors++;
            continue; // Skip to next test case
        }

        // Decryption allocates new memory
        char* decrypted_output = decryption(encrypted_output, len, key);
        if (decrypted_output == NULL) {
            fprintf(stderr, "Error in test: %s\n", tests[i].description);
            fprintf(stderr, "  decryption() returned NULL for encrypted: '%s', key: %d\n", encrypted_output, key);
            errors++;
            free(encrypted_output); // Free memory allocated by encryption
            continue; // Skip to next test case
        }

        if (strcmp(original_str, decrypted_output) != 0) {
            fprintf(stderr, "Error in test: %s\n", tests[i].description);
            fprintf(stderr, "  Original:   '%s'\n", original_str);
            fprintf(stderr, "  Key:        %d\n", key);
            fprintf(stderr, "  Encrypted:  '%s'\n", encrypted_output);
            fprintf(stderr, "  Decrypted:  '%s' (should be '%s')\n", decrypted_output, original_str);
            errors++;
        }
        
        // Free memory allocated by encryption and decryption
        free(encrypted_output);
        free(decrypted_output);
    }
    return errors;
}


int main() {
    // Seed the random number generator
    srand(time(NULL));

    int key_errors = test_generateKey();
    int enc_dec_errors = test_encryption_decryption();

    int total_errors = key_errors + enc_dec_errors;

    if (total_errors == 0) {
        printf("All tests passed.\n");
    } else {
        if (key_errors > 0) {
            printf("generateKey tests failed with %d errors.\n", key_errors);
        }
        if (enc_dec_errors > 0) {
            printf("Encryption/Decryption tests failed with %d errors.\n", enc_dec_errors);
        }
        printf("Total errors: %d.\n", total_errors);
    }

    return (total_errors == 0) ? 0 : 1;
}
