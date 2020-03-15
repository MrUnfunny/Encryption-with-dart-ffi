#include<stdlib.h>
#include <stdio.h>
#include "encryption.h"

int main()
{
	return 0;
}

// Function for generating the key for Encryption.
int generateKey()
{
	int key=rand();
	key=key%11;
	
	return key;
}

//Function for generating the encrypted String.
char *encryption(char *msg, int length,int key)
{	
    char *encryptedString = (char *)malloc((length + 1) * sizeof(char));
    for (int i = 0; i < length; i++)
    {
        encryptedString[i] = msg[i]+key;
    }
    encryptedString[length] = '\0';
    return encryptedString;
}

//Function for generating the decrypted String.
char *decryption(char *msg, int length,int key)
{	
    char *DecryptedString = (char *)malloc((length + 1) * sizeof(char));
    for (int i = 0; i < length; i++)
    {
        DecryptedString[i] = msg[i]-key;
    }
    DecryptedString[length] = '\0';
    return DecryptedString;
}
