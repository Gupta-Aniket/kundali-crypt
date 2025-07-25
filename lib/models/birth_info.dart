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