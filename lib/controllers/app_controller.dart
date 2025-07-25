import 'package:flutter/material.dart';
import '../models/birth_info.dart';
import '../models/kundali.dart';

enum AppMode { public, pattern, vault, honeypot }

class AppController extends ChangeNotifier {
  AppMode _currentMode = AppMode.public;
  BirthInfo? _birthInfo;
  Kundali? _kundali;
  bool _isLoading = false;

  AppMode get currentMode => _currentMode;
  BirthInfo? get birthInfo => _birthInfo;
  Kundali? get kundali => _kundali;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setBirthInfo(BirthInfo info) {
    _birthInfo = info;
    notifyListeners();
  }

  void setKundali(Kundali kundali) {
    _kundali = kundali;
    notifyListeners();
  }

  void switchMode(AppMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  void triggerHiddenGesture() {
    if (_currentMode == AppMode.public && _kundali != null) {
      switchMode(AppMode.pattern);
    }
  }

  void resetToPublic() {
    _currentMode = AppMode.public;
    notifyListeners();
  }
}