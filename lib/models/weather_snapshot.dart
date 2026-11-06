class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.observedAt,
    required this.latitude,
    required this.longitude,
  });

  final double temperature;
  final int humidity;
  final double windSpeed;
  final String condition;
  final DateTime observedAt;
  final double latitude;
  final double longitude;

  String get temperatureLabel => '${temperature.round()} C';

  String get observedLabel {
    final hour = observedAt.hour.toString().padLeft(2, '0');
    final minute = observedAt.minute.toString().padLeft(2, '0');
    return 'Updated $hour:$minute';
  }
}
