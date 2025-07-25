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
