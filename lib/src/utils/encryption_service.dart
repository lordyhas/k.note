import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();

  factory EncryptionService() {
    return _instance;
  }

  EncryptionService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  encrypt.Key? _masterKey;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize the service by checking for a locally stored master key.
  Future<void> init() async {
    try {
      final keyString = await _storage.read(key: 'master_key');
      if (keyString != null) {
        _masterKey = encrypt.Key.fromBase64(keyString);
        _isInitialized = true;
      }
    } catch (e) {
      // Handle storage read error
      print('EncryptionService init error: $e');
    }
  }

  /// SETUP: Generates a new master key, stores it locally, and returns
  /// an encrypted version of it (protected by PIN) to be stored in Firebase.
  Future<String> setup(String pin) async {
    // 1. Generate a random 32-byte Master Key
    final keyBytes =
        List<int>.generate(32, (i) => Random.secure().nextInt(256));
    _masterKey = encrypt.Key(Uint8List.fromList(keyBytes));

    // 2. Save Master Key locally
    await _storage.write(key: 'master_key', value: _masterKey!.base64);
    _isInitialized = true;

    // 3. Encrypt Master Key with PIN for cloud backup
    return _encryptMasterKeyWithPin(pin, _masterKey!);
  }

  /// RECOVER: Decrypts the remote encrypted master key using the PIN
  /// and stores the result locally.
  Future<void> recover(String pin, String remoteEncryptedKey) async {
    try {
      final masterKey = _decryptMasterKeyWithPin(pin, remoteEncryptedKey);
      _masterKey = masterKey;
      await _storage.write(key: 'master_key', value: _masterKey!.base64);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Invalid PIN or corrupted key');
    }
  }

  /// Clears local keys (for logout/reset)
  Future<void> clearLocalKeys() async {
    await _storage.delete(key: 'master_key');
    _masterKey = null;
    _isInitialized = false;
  }

  // --- Data Encryption ---

  String? encryptData(String? text) {
    if (text == null) return null;
    if (!_isInitialized || _masterKey == null) {
      throw Exception('EncryptionService not initialized');
    }

    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(_masterKey!));

    final encrypted = encrypter.encrypt(text, iv: iv);
    // Return format: iv:ciphertext (base64)
    return '${iv.base64}:${encrypted.base64}';
  }

  String? decryptData(String? text) {
    if (text == null) return null;
    // If text doesn't look like our encrypted format (iv:ciphertext), return it as is
    // This provides backward compatibility for unencrypted notes
    if (!text.contains(':')) return text;

    if (!_isInitialized || _masterKey == null) {
      throw Exception('EncryptionService not initialized');
    }

    try {
      final parts = text.split(':');
      if (parts.length != 2) return text;

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      final encrypter = encrypt.Encrypter(encrypt.AES(_masterKey!));

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      // Use simpler error handling in case of bad formatting
      return text; //'Error decrypting';
    }
  }

  // --- Helpers ---

  // Derives a key from PIN using SHA-256 (simple version)
  encrypt.Key _deriveKeyFromPin(String pin) {
    const salt = 'K_NOTE_SECURE_SALT';
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    // SHA-256 gives 32 bytes, perfect for AES-256
    return encrypt.Key(Uint8List.fromList(digest.bytes));
  }

  String _encryptMasterKeyWithPin(String pin, encrypt.Key masterKey) {
    final kek = _deriveKeyFromPin(pin);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(kek));

    final encrypted = encrypter.encrypt(masterKey.base64, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  encrypt.Key _decryptMasterKeyWithPin(String pin, String encryptedWrapper) {
    final parts = encryptedWrapper.split(':');
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

    final kek = _deriveKeyFromPin(pin);
    final encrypter = encrypt.Encrypter(encrypt.AES(kek));

    final decryptedBase64 = encrypter.decrypt(encrypted, iv: iv);
    return encrypt.Key.fromBase64(decryptedBase64);
  }
}
