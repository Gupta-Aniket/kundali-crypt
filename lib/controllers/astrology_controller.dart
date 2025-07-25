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
