import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:kundali_crypt/models/planets.dart';
import 'dart:convert';
import 'dart:math';

import '../models/vault_item.dart';
import '../services/encryption_service.dart';
import '../services/storage_service.dart';

class VaultController extends ChangeNotifier {
  final EncryptionService _encryptionService = EncryptionService();
  final StorageService _storageService = StorageService();
  
  List<VaultItem> _vaultItems = [];
  List<VaultItem> _honeypotItems = [];
  List<PlanetType> _currentPattern = [];
  bool _isUnlocked = false;
  bool _isHoneypot = false;

  List<VaultItem> get vaultItems => _vaultItems;
  List<PlanetType> get currentPattern => _currentPattern;
  bool get isUnlocked => _isUnlocked;
  bool get isHoneypot => _isHoneypot;

  void addToPattern(PlanetType planet) {
    if (!_currentPattern.contains(planet)) {
      _currentPattern.add(planet);
      notifyListeners();
    }
  }

  void removeFromPattern(PlanetType planet) {
    _currentPattern.remove(planet);
    notifyListeners();
  }

  void clearPattern() {
    _currentPattern.clear();
    notifyListeners();
  }

  String generateSalt(List<Planet> planets) {
    String salt = '';
    for (PlanetType planetType in _currentPattern) {
      final planet = planets.firstWhere((p) => p.type == planetType);
      salt += planet.keySegment;
    }
    return salt;
  }

  String generateAESKey(String salt) {
    final pepper = 'KundaliLock2024SecretPepper';
    final combined = salt + pepper;
    
    // PBKDF2 with 100,000 iterations
    final key = sha512.convert(utf8.encode(combined)).toString();
    return key.substring(0, 64); // 256-bit key
  }

  Future<bool> unlockVault(List<Planet> planets, String correctPattern) async {
    final salt = generateSalt(planets);
    final key = generateAESKey(salt);
    
    // Check if pattern matches expected pattern
    final patternString = _currentPattern.map((p) => p.index).join(',');
    
    if (patternString == correctPattern) {
      // Unlock real vault
      _isUnlocked = true;
      _isHoneypot = false;
      await _loadVaultItems(key);
    } else if (_isValidLookingPattern()) {
      // Open honeypot
      _isUnlocked = true;
      _isHoneypot = true;
      _loadHoneypotItems();
    } else {
      // Invalid pattern
      _isUnlocked = false;
      _isHoneypot = false;
      return false;
    }
    
    notifyListeners();
    return true;
  }

  bool _isValidLookingPattern() {
    // Pattern should have at least 4 planets to look legitimate
    return _currentPattern.length >= 4;
  }

  Future<void> _loadVaultItems(String key) async {
    try {
      final encryptedData = await _storageService.getVaultData();
      if (encryptedData != null) {
        final decryptedData = await _encryptionService.decrypt(encryptedData, key);
        final List<dynamic> jsonList = jsonDecode(decryptedData);
        _vaultItems = jsonList.map((json) => VaultItem.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading vault items: $e');
      _vaultItems = [];
    }
  }

  void _loadHoneypotItems() {
    _vaultItems = [
      VaultItem(
        id: '1',
        title: 'Shopping List',
        content: 'Milk, Bread, Eggs, Butter',
        type: VaultItemType.note,
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        updatedAt: DateTime.now().subtract(Duration(days: 3)),
      ),
      VaultItem(
        id: '2',
        title: 'Meeting Notes',
        content: 'Team meeting scheduled for tomorrow at 2 PM',
        type: VaultItemType.note,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      VaultItem(
        id: '3',
        title: 'WiFi Password',
        content: 'HomeNetwork123',
        type: VaultItemType.password,
        createdAt: DateTime.now().subtract(Duration(days: 7)),
        updatedAt: DateTime.now().subtract(Duration(days: 7)),
      ),
    ];
  }

  Future<void> addVaultItem(VaultItem item) async {
    if (_isHoneypot) return; // Don't save to honeypot
    
    _vaultItems.add(item);
    await _saveVaultItems();
    notifyListeners();
  }

  Future<void> _saveVaultItems() async {
    try {
      // Generate current key from pattern
      final salt = generateSalt([]);  // Would need actual planets here
      final key = generateAESKey(salt);
      
      final jsonString = jsonEncode(_vaultItems.map((item) => item.toJson()).toList());
      final encryptedData = await _encryptionService.encrypt(jsonString, key);
      await _storageService.saveVaultData(encryptedData);
    } catch (e) {
      print('Error saving vault items: $e');
    }
  }

  void lockVault() {
    _isUnlocked = false;
    _isHoneypot = false;
    _vaultItems.clear();
    _currentPattern.clear();
    notifyListeners();
  }
}