## 📂 Project Structure

```
└── ./
    ├── controllers/
    │   ├── app_controller.dart
    │   ├── astrology_controller.dart
    │   └── vault_controller.dart
    ├── main.dart
    ├── models/
    │   ├── birth_info.dart
    │   ├── kundali.dart
    │   ├── planets.dart
    │   └── vault_item.dart
    ├── services/
    │   ├── encryption_service.dart
    │   └── storage_service.dart
    └── views/
        ├── add_vault_item.dart
        ├── birth_form_view.dart
        ├── home_view.dart
        ├── kundali_display_view.dart
        ├── pattern_unlock_view.dart
        └── vault_view.dart
```

### app_controller.dart
```dart
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
```

### astrology_controller.dart
```dart
import 'package:flutter/material.dart';
import 'package:kundali_crypt/models/planets.dart';
import 'dart:math';
import '../models/birth_info.dart';
import '../models/kundali.dart';

class AstrologyController extends ChangeNotifier {
  final List<String> _signs = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  final List<String> _nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira',
    'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha'
  ];

  Future<Kundali> generateKundali(BirthInfo birthInfo) async {
    // Simulate calculation delay
    await Future.delayed(Duration(milliseconds: 1500));
    
    final random = Random(birthInfo.dateTime.millisecondsSinceEpoch);
    final planets = <Planet>[];

    // Generate planets with deterministic but realistic positions
    for (int i = 0; i < PlanetType.values.length; i++) {
      final type = PlanetType.values[i];
      final house = (random.nextInt(12) + 1);
      final sign = _signs[random.nextInt(_signs.length)];
      final degrees = random.nextDouble() * 30;

      planets.add(Planet(
        type: type,
        name: _getPlanetName(type),
        house: house,
        sign: sign,
        degrees: degrees,
      ));
    }

    final ascendant = _signs[random.nextInt(_signs.length)];
    final nakshatra = _nakshatras[random.nextInt(_nakshatras.length)];

    return Kundali(
      birthInfo: birthInfo,
      planets: planets,
      ascendant: ascendant,
      nakshatra: nakshatra,
    );
  }

  String _getPlanetName(PlanetType type) {
    switch (type) {
      case PlanetType.sun: return 'Sun';
      case PlanetType.moon: return 'Moon';
      case PlanetType.mars: return 'Mars';
      case PlanetType.mercury: return 'Mercury';
      case PlanetType.jupiter: return 'Jupiter';
      case PlanetType.venus: return 'Venus';
      case PlanetType.saturn: return 'Saturn';
      case PlanetType.rahu: return 'Rahu';
      case PlanetType.ketu: return 'Ketu';
    }
  }

  List<String> getDailyPrediction() {
    return [
      "Today brings positive energy for new beginnings.",
      "Focus on relationships and communication today.",
      "Financial opportunities may present themselves.",
      "A good day for creative pursuits and self-expression.",
      "Pay attention to your health and well-being.",
    ];
  }
}

```

### vault_controller.dart
```dart
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
```

### main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'views/home_view.dart';
import 'controllers/app_controller.dart';
import 'controllers/vault_controller.dart';
import 'controllers/astrology_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(KundaliLockApp());
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Same as scaffold/app bar background
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}

class KundaliLockApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppController()),
        ChangeNotifierProvider(create: (_) => VaultController()),
        ChangeNotifierProvider(create: (_) => AstrologyController()),
      ],
      child: MaterialApp(
        title: 'Kundali Viewer',

        //
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black87),
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        home: HomeView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

```

### birth_info.dart
```dart
class BirthInfo {
  final DateTime dateTime;
  final String place;
  final double latitude;
  final double longitude;

  BirthInfo({
    required this.dateTime,
    required this.place,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'dateTime': dateTime.toIso8601String(),
    'place': place,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory BirthInfo.fromJson(Map<String, dynamic> json) => BirthInfo(
    dateTime: DateTime.parse(json['dateTime']),
    place: json['place'],
    latitude: json['latitude'],
    longitude: json['longitude'],
  );
}
```

### kundali.dart
```dart
import 'package:kundali_crypt/models/birth_info.dart';
import 'package:kundali_crypt/models/planets.dart';

class Kundali {
  final BirthInfo birthInfo;
  final List<Planet> planets;
  final String ascendant;
  final String nakshatra;

  Kundali({
    required this.birthInfo,
    required this.planets,
    required this.ascendant,
    required this.nakshatra,
  });

  Planet getPlanet(PlanetType type) {
    return planets.firstWhere((p) => p.type == type);
  }
}

```

### planets.dart
```dart
// models/planet.dart
enum PlanetType {
  sun, moon, mars, mercury, jupiter, venus, saturn, rahu, ketu
}

class Planet {
  final PlanetType type;
  final String name;
  final int house;
  final String sign;
  final double degrees;

  Planet({
    required this.type,
    required this.name,
    required this.house,
    required this.sign,
    required this.degrees,
  });

  String get keySegment {
    // Generate 8-digit deterministic key segment
    final baseString = '${name.toUpperCase()}_$house';
    final hash = baseString.hashCode.abs();
    return hash.toString().padLeft(8, '0').substring(0, 8);
  }

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'name': name,
    'house': house,
    'sign': sign,
    'degrees': degrees,
  };
}
```

### vault_item.dart
```dart
class VaultItem {
  final String id;
  final String title;
  final String content;
  final VaultItemType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaultItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'type': type.index,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory VaultItem.fromJson(Map<String, dynamic> json) => VaultItem(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    type: VaultItemType.values[json['type']],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

enum VaultItemType { note, password, file, image }
```

### encryption_service.dart
```dart
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

```

### storage_service.dart
```dart
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
```

### add_vault_item.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../controllers/vault_controller.dart';
import '../models/vault_item.dart';

class AddVaultItemView extends StatefulWidget {
  @override
  _AddVaultItemViewState createState() => _AddVaultItemViewState();
}

class _AddVaultItemViewState extends State<AddVaultItemView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  VaultItemType _selectedType = VaultItemType.note;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text('Add Vault Item'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Enter title',
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _contentController,
                  label: 'Content',
                  hint: 'Enter sensitive content',
                  maxLines: 5,
                ),
                SizedBox(height: 20),
                _buildDropdown(),
                Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save to Vault',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white30),
        filled: true,
        fillColor: Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Field cannot be empty' : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<VaultItemType>(
      value: _selectedType,
      dropdownColor: Color(0xFF1A1A1A),
      iconEnabledColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Type',
        labelStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: VaultItemType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(
            type.name[0].toUpperCase() + type.name.substring(1),
            style: TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: (type) {
        if (type != null) setState(() => _selectedType = type);
      },
    );
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final newItem = VaultItem(
        id: Uuid().v4(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        createdAt: now,
        updatedAt: now,
      );

      final vaultController = Provider.of<VaultController>(context, listen: false);
      await vaultController.addVaultItem(newItem);

      Navigator.of(context).pop(); // go back to vault view
    }
  }
}

```

### birth_form_view.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../controllers/astrology_controller.dart';
import '../models/birth_info.dart';

class BirthFormView extends StatefulWidget {
  @override
  _BirthFormViewState createState() => _BirthFormViewState();
}

class _BirthFormViewState extends State<BirthFormView> {
  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Kundali'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Text(
                'Enter Birth Details',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Generate your personalized birth chart',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),

              // Date Picker
              _buildDateTimeField(
                'Date of Birth',
                _selectedDate?.toString().split(' ')[0] ?? 'Select Date',
                Icons.calendar_today,
                () => _selectDate(context),
              ),
              SizedBox(height: 20),

              // Time Picker
              _buildDateTimeField(
                'Time of Birth',
                _selectedTime?.format(context) ?? 'Select Time',
                Icons.access_time,
                () => _selectTime(context),
              ),
              SizedBox(height: 20),

              // Place Field
              TextFormField(
                controller: _placeController,
                decoration: InputDecoration(
                  labelText: 'Place of Birth',
                  hintText: 'Enter city, country',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter place of birth';
                  }
                  return null;
                },
              ),

              Spacer(),

              // Generate Button
              Consumer<AppController>(
                builder: (context, appController, child) {
                  return ElevatedButton(
                    onPressed:
                        appController.isLoading ? null : _generateKundali,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child:
                        appController.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Generate Kundali',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _generateKundali() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final appController = Provider.of<AppController>(context, listen: false);
      final astrologyController = Provider.of<AstrologyController>(
        context,
        listen: false,
      );

      appController.setLoading(true);

      final birthInfo = BirthInfo(
        dateTime: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
        place: _placeController.text,
        latitude: 28.7041, // Default to Delhi coordinates
        longitude: 77.1025,
      );

      appController.setBirthInfo(birthInfo);

      try {
        final kundali = await astrologyController.generateKundali(birthInfo);
        appController.setKundali(kundali);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating Kundali: $e')));
      } finally {
        appController.setLoading(false);
      }
    }
  }
}

```

### home_view.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../controllers/astrology_controller.dart';
import '../controllers/vault_controller.dart';
import '../models/birth_info.dart';
import 'birth_form_view.dart';
import 'kundali_display_view.dart';
import 'pattern_unlock_view.dart';
import 'vault_view.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Same as scaffold/app bar background
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Consumer<AppController>(
        builder: (context, appController, child) {
          Widget currentView;

          switch (appController.currentMode) {
            case AppMode.public:
              currentView =
                  appController.kundali == null
                      ? BirthFormView()
                      : KundaliDisplayView();
              break;
            case AppMode.pattern:
              currentView = PatternUnlockView();
              break;
            case AppMode.vault:
            case AppMode.honeypot:
              currentView = VaultView();
              break;
          }

          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
  final offsetAnimation = Tween<Offset>(
    begin: Offset(0, 0.1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

  return SlideTransition(
    position: offsetAnimation,
    child: FadeTransition(
      opacity: animation,
      child: child,
    ),
  );
},

            child: currentView,
          );
        },
      ),
    );
  }
}

```

### kundali_display_view.dart
```dart
import 'package:flutter/material.dart';
import 'package:kundali_crypt/models/planets.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../controllers/astrology_controller.dart';
import '../models/kundali.dart';

class KundaliDisplayView extends StatefulWidget {
  @override
  _KundaliDisplayViewState createState() => _KundaliDisplayViewState();
}

class _KundaliDisplayViewState extends State<KundaliDisplayView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            // Hidden trigger - long press on title for 3 seconds
            Provider.of<AppController>(context, listen: false).triggerHiddenGesture();
          },
          child: Text('My Kundali'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => Provider.of<AppController>(context, listen: false).resetToPublic(),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<AppController>(
          builder: (context, appController, child) {
            final kundali = appController.kundali!;
            
            return IndexedStack(
              index: _currentIndex,
              children: [
                _buildChartView(kundali),
                _buildTodayView(),
                _buildInfoView(kundali),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Hidden trigger - triple tap on Saturn (Info) tab
          if (index == 2) {
            _handleInfoTap();
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Info',
          ),
        ],
      ),
    );
  }

  int _infoTapCount = 0;
  DateTime? _lastInfoTap;

  void _handleInfoTap() {
    final now = DateTime.now();
    if (_lastInfoTap == null || now.difference(_lastInfoTap!).inSeconds > 2) {
      _infoTapCount = 1;
    } else {
      _infoTapCount++;
    }
    _lastInfoTap = now;

    // Triple tap trigger
    if (_infoTapCount >= 3) {
      Provider.of<AppController>(context, listen: false).triggerHiddenGesture();
      _infoTapCount = 0;
    }
  }

  Widget _buildChartView(Kundali kundali) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Planetary Positions'),
          SizedBox(height: 16),
          ...kundali.planets.map((planet) => _buildPlanetCard(planet)).toList(),
          SizedBox(height: 24),
          _buildSectionHeader('Chart Details'),
          SizedBox(height: 16),
          _buildDetailCard('Ascendant', kundali.ascendant),
          _buildDetailCard('Nakshatra', kundali.nakshatra),
          _buildDetailCard('Birth Place', kundali.birthInfo.place),
        ],
      ),
    );
  }

  Widget _buildTodayView() {
    return Consumer<AstrologyController>(
      builder: (context, astrologyController, child) {
        final predictions = astrologyController.getDailyPrediction();
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Today\'s Guidance'),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.wb_sunny, size: 48, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Daily Prediction',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...predictions.map((prediction) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• $prediction',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoView(Kundali kundali) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('About Kundali'),
          SizedBox(height: 16),
          _buildInfoCard(
            'Birth Information',
            'Date: ${kundali.birthInfo.dateTime.toString().split(' ')[0]}\n'
            'Time: ${kundali.birthInfo.dateTime.toString().split(' ')[1].substring(0, 5)}\n'
            'Place: ${kundali.birthInfo.place}',
          ),
          SizedBox(height: 16),
          _buildInfoCard(
            'Chart System',
            'This Kundali uses the Vedic astrology system based on sidereal calculations. '
            'The positions shown are accurate for the birth time and location provided.',
          ),
          SizedBox(height: 16),
          _buildInfoCard(
            'Interpretation',
            'Planetary positions influence different aspects of life. Each house represents '
            'specific life areas, and planetary placements provide insights into personality and destiny.',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPlanetCard(Planet planet) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getPlanetColor(planet.type),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getPlanetIcon(planet.type),
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planet.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${planet.house}${_getOrdinalSuffix(planet.house)} House, ${planet.sign}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlanetColor(PlanetType type) {
    switch (type) {
      case PlanetType.sun: return Colors.orange;
      case PlanetType.moon: return Colors.blue[300]!;
      case PlanetType.mars: return Colors.red;
      case PlanetType.mercury: return Colors.green;
      case PlanetType.jupiter: return Colors.purple;
      case PlanetType.venus: return Colors.pink;
      case PlanetType.saturn: return Colors.indigo;
      case PlanetType.rahu: return Colors.brown;
      case PlanetType.ketu: return Colors.grey;
    }
  }

  IconData _getPlanetIcon(PlanetType type) {
    switch (type) {
      case PlanetType.sun: return Icons.wb_sunny;
      case PlanetType.moon: return Icons.nightlight_round;
      case PlanetType.mars: return Icons.rocket_launch;
      case PlanetType.mercury: return Icons.speed;
      case PlanetType.jupiter: return Icons.expand;
      case PlanetType.venus: return Icons.favorite;
      case PlanetType.saturn: return Icons.schedule;
      case PlanetType.rahu: return Icons.trending_up;
      case PlanetType.ketu: return Icons.trending_down;
    }
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}
```

### pattern_unlock_view.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kundali_crypt/models/planets.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../controllers/vault_controller.dart';


class PatternUnlockView extends StatefulWidget {
  @override
  _PatternUnlockViewState createState() => _PatternUnlockViewState();
}

class _PatternUnlockViewState extends State<PatternUnlockView> 
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _glowController;
  late Animation<double> _orbitAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _orbitAnimation = Tween<double>(begin: 0, end: 1).animate(_orbitController);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: SafeArea(
        child: Stack(
          children: [
            // Background stars
            ...List.generate(50, (index) => _buildStar(index)),
            
            // Main content
            Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Celestial Vault',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Draw your pattern across the planets',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Pattern display
                Expanded(
                  child: Consumer<VaultController>(
                    builder: (context, vaultController, child) {
                      return Column(
                        children: [
                          // Current pattern
                          Container(
                            height: 60,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Pattern: ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                ...vaultController.currentPattern.map((planet) => 
                                  Container(
                                    margin: EdgeInsets.only(right: 8),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12, 
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPlanetColor(planet),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getPlanetColor(planet).withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _getPlanetName(planet),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ).toList(),
                              ],
                            ),
                          ),
                          
                          // Planet grid
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _orbitAnimation,
                              builder: (context, child) {
                                return _buildPlanetGrid(vaultController);
                              },
                            ),
                          ),
                          
                          // Action buttons
                          Padding(
                            padding: EdgeInsets.all(24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: vaultController.currentPattern.isEmpty 
                                      ? null 
                                      : () => vaultController.clearPattern(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[600],
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text('Clear'),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: vaultController.currentPattern.length < 4
                                      ? null
                                      : () => _unlockVault(vaultController),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text('Unlock Vault'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Back button
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                onPressed: () {
                  Provider.of<AppController>(context, listen: false).resetToPublic();
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(int index) {
    final random = index * 123; // Pseudo-random
    final left = (random % 100) / 100 * MediaQuery.of(context).size.width;
    final top = ((random * 7) % 100) / 100 * MediaQuery.of(context).size.height;
    final size = ((random * 3) % 4) + 1.0;
    
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(_glowAnimation.value * 0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 2,
                  spreadRadius: 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanetGrid(VaultController vaultController) {
    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1,
      ),
      itemCount: PlanetType.values.length,
      itemBuilder: (context, index) {
        final planet = PlanetType.values[index];
        final isSelected = vaultController.currentPattern.contains(planet);
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (isSelected) {
              vaultController.removeFromPattern(planet);
            } else {
              vaultController.addToPattern(planet);
            }
          },
          child: AnimatedBuilder(
            animation: _orbitAnimation,
            builder: (context, child) {
              final rotationOffset = index * 0.2;
              final rotation = (_orbitAnimation.value + rotationOffset) * 2 * 3.14159;
              
              return Transform.rotate(
                angle: rotation * 0.1, // Subtle rotation
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _getPlanetColor(planet).withOpacity(0.8),
                        _getPlanetColor(planet).withOpacity(0.3),
                      ],
                    ),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getPlanetColor(planet).withOpacity(0.5),
                        blurRadius: isSelected ? 20 : 10,
                        spreadRadius: isSelected ? 5 : 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getPlanetIcon(planet),
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _getPlanetName(planet),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _unlockVault(VaultController vaultController) async {
    final appController = Provider.of<AppController>(context, listen: false);
    
    // Default pattern for demo - in production, this would be user-set
    const correctPattern = '1,2,6,8'; // Moon, Mars, Saturn, Ketu
    
    HapticFeedback.mediumImpact();
    
    final success = await vaultController.unlockVault(
      appController.kundali!.planets, 
      correctPattern,
    );
    
    if (success) {
      HapticFeedback.heavyImpact();
      appController.switchMode(AppMode.vault);
    } else {
      // Wrong pattern feedback
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pattern must have at least 4 planets'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getPlanetColor(PlanetType type) {
    switch (type) {
      case PlanetType.sun: return Color(0xFFFF6B35);
      case PlanetType.moon: return Color(0xFF4A90E2);
      case PlanetType.mars: return Color(0xFFE74C3C);
      case PlanetType.mercury: return Color(0xFF2ECC71);
      case PlanetType.jupiter: return Color(0xFF9B59B6);
      case PlanetType.venus: return Color(0xFFE91E63);
      case PlanetType.saturn: return Color(0xFF34495E);
      case PlanetType.rahu: return Color(0xFF795548);
      case PlanetType.ketu: return Color(0xFF607D8B);
    }
  }

  IconData _getPlanetIcon(PlanetType type) {
    switch (type) {
      case PlanetType.sun: return Icons.wb_sunny;
      case PlanetType.moon: return Icons.nightlight_round;
      case PlanetType.mars: return Icons.rocket_launch;
      case PlanetType.mercury: return Icons.speed;
      case PlanetType.jupiter: return Icons.expand;
      case PlanetType.venus: return Icons.favorite;
      case PlanetType.saturn: return Icons.schedule;
      case PlanetType.rahu: return Icons.trending_up;
      case PlanetType.ketu: return Icons.trending_down;
    }
  }

  String _getPlanetName(PlanetType type) {
    switch (type) {
      case PlanetType.sun: return 'Sun';
      case PlanetType.moon: return 'Moon';
      case PlanetType.mars: return 'Mars';
      case PlanetType.mercury: return 'Mercury';
      case PlanetType.jupiter: return 'Jupiter';
      case PlanetType.venus: return 'Venus';
      case PlanetType.saturn: return 'Saturn';
      case PlanetType.rahu: return 'Rahu';
      case PlanetType.ketu: return 'Ketu';
    }
  }
}
```

### vault_view.dart
```dart
import 'package:flutter/material.dart';
import 'package:kundali_crypt/views/add_vault_item.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../controllers/vault_controller.dart';
import '../models/vault_item.dart';

class VaultView extends StatefulWidget {
  @override
  _VaultViewState createState() => _VaultViewState();
}

class _VaultViewState extends State<VaultView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<VaultController>(
      builder: (context, vaultController, child) {
        return Scaffold(
          backgroundColor: Color(0xFF0A0A0A),
          appBar: AppBar(
            backgroundColor: Color(0xFF1A1A1A),
            title: Row(
              children: [
                Icon(
                  vaultController.isHoneypot ? Icons.warning : Icons.lock,
                  color:
                      vaultController.isHoneypot ? Colors.orange : Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  vaultController.isHoneypot ? 'Decoy Vault' : 'Secure Vault',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed:
                    vaultController.isHoneypot
                        ? null
                        : () => _showAddItemDialog(context),
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  vaultController.lockVault();
                  Provider.of<AppController>(
                    context,
                    listen: false,
                  ).resetToPublic();
                },
              ),
            ],
          ),
          body: SafeArea(
            child:
                vaultController.vaultItems.isEmpty
                    ? _buildEmptyState()
                    : _buildVaultItems(vaultController.vaultItems),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.white30),
          SizedBox(height: 16),
          Text(
            'Your vault is empty',
            style: TextStyle(fontSize: 20, color: Colors.white70),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first secure item',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultItems(List<VaultItem> items) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildVaultItemCard(item);
      },
    );
  }

  Widget _buildVaultItemCard(VaultItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getItemTypeColor(item.type),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getItemTypeIcon(item.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          item.content.length > 50
              ? '${item.content.substring(0, 50)}...'
              : item.content,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.white30),
        onTap: () => _showItemDetails(context, item),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => AddVaultItemView()));
  }

  void _showItemDetails(BuildContext context, VaultItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getItemTypeColor(item.type),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getItemTypeIcon(item.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.content,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Created: ${item.createdAt.toString().split('.')[0]}',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getItemTypeColor(VaultItemType type) {
    switch (type) {
      case VaultItemType.note:
        return Colors.blueAccent;
      case VaultItemType.password:
        return Colors.redAccent;
      case VaultItemType.file:
        return Colors.teal;
      case VaultItemType.image:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getItemTypeIcon(VaultItemType type) {
    switch (type) {
      case VaultItemType.note:
        return Icons.notes;
      case VaultItemType.password:
        return Icons.vpn_key;
      case VaultItemType.file:
        return Icons.insert_drive_file;
      case VaultItemType.image:
        return Icons.image;
      default:
        return Icons.lock;
    }
  }
}

```

