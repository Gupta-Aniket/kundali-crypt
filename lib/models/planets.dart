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