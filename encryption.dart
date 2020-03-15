import 'dart:ffi' ;                           
import 'package:ffi/ffi.dart';
import 'dart:io';


typedef generateKey_func = Int32 Function();
typedef GenerateKey= int Function();

typedef encryption_func = Pointer<Utf8> Function(Pointer<Utf8> msg,Int32 length,Int32 key);
typedef Encryption = Pointer<Utf8> Function(Pointer<Utf8> msg,int length,int key);

typedef decryption_func = Pointer<Utf8> Function(Pointer<Utf8> msg,Int32 length,Int32 key);
typedef Decryption = Pointer<Utf8> Function(Pointer<Utf8> msg,int length,int key);

main()
{
  var path = './encryption_library/libencryption.so';
  if (Platform.isMacOS) path = './encryption_library/libencryption.dylib';
  if (Platform.isWindows) path = r'encryption_library\Debug\encryption.dll';
  final dylib = DynamicLibrary.open(path);

  //C Function of generating Key for encryption.
  final generateKeyPointer = dylib.lookup<NativeFunction<generateKey_func>>('generateKey');
  final generateKey = generateKeyPointer.asFunction<GenerateKey>();

  //Taking Input for the String to be Encoded by the user
  print("Enter String to be Encoded: ");
  String msg=stdin.readLineSync();
  int len=msg.length;

  //Invoking the C Function to generate Key.
  int generatedKey=generateKey();

  //C string parameter pointer function which takes input of the string to be encrypted, it's length and the key
  //and returns the encrypted String. - char *encryption(char *msg, int length, int key);
  final encryptionPointer = dylib.lookup<NativeFunction<encryption_func>>('encryption');
  final encryption = encryptionPointer.asFunction<Encryption>();

  //C string parameter pointer funtion which takes input of the encrypted string, it's length and the key
  //and returns the decrypted String. - char *decryption(char *msg, int length, int key);      
  final decryptionPointer = dylib.lookup<NativeFunction<decryption_func>>('decryption');
  final decryption = decryptionPointer.asFunction<Decryption>();

  //Invoking the C functions for encrypting and then decrypting back the Strings input by the user.
  String encryptedString=Utf8.fromUtf8(encryption(Utf8.toUtf8(msg),len,generatedKey));
  String decryptedString=Utf8.fromUtf8(decryption(Utf8.toUtf8(encryptedString),len,generatedKey));

  //Providing Options to User for showing the Encrypted and Decrypted Strings.
  String option='0';
  while(option!='4')
  {
  print("\nPress 1 to encrypt the Message\n2 to decrypt the message\n3 to enter another String\n4 to end the program:");
  option=stdin.readLineSync();


  switch (option) {
    case '1':
    {
      print("Encrypted Message is:\n $encryptedString\n\n");
      continue;
    }
    case '2':
     {
      print("Decrypted Message is:\n $decryptedString\n\n");
      continue;
     }
    case '3':
      {
      print("Enter the String");
      msg=stdin.readLineSync();
      encryptedString=Utf8.fromUtf8(encryption(Utf8.toUtf8(msg),len,generatedKey));
      decryptedString=Utf8.fromUtf8(decryption(Utf8.toUtf8(encryptedString),len,generatedKey));    
      continue;
      }
    case '4':
    {
      print("Program Ended");
      break;
    }
    default :
      {
      print("Invalid Input, Try Again:\n");
      continue;
      }
  }
  }
}