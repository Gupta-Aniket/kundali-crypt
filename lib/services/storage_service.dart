import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _vaultDataKey = 'vault_data';
  static const String _correctPatternKey = 'correct_pattern';

  Future<String?> getVaultData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_vaultDataKey);
  }

  Future<void> saveVaultData(String encryptedData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vaultDataKey, encryptedData);
  }

  Future<String?> getCorrectPattern() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_correctPatternKey);
  }

  Future<void> saveCorrectPattern(String pattern) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_correctPatternKey, pattern);
  }
}