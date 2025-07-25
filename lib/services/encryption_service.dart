import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class EncryptionService {
  Future<String> encrypt(String data, String key) async {
    // Simplified encryption - in production, use proper AES implementation
    final keyBytes = utf8.encode(key);
    final dataBytes = utf8.encode(data);
    
    // XOR encryption (placeholder - use proper AES in production)
    final encrypted = <int>[];
    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return base64.encode(encrypted);
  }

  Future<String> decrypt(String encryptedData, String key) async {
    final keyBytes = utf8.encode(key);
    final encryptedBytes = base64.decode(encryptedData);
    
    // XOR decryption (placeholder - use proper AES in production)
    final decrypted = <int>[];
    for (int i = 0; i < encryptedBytes.length; i++) {
      decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return utf8.decode(decrypted);
  }
}
