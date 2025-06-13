// ignore_for_file: public_member_api_docs, sort_constructors_first
class HourlyWeather {
  final double temp;
  final String weatherCategory;
  final String? condition;
  final DateTime date;

  HourlyWeather({
    required this.temp,
    required this.weatherCategory,
    this.condition,
    required this.date,
  });

  static HourlyWeather fromJson(dynamic json) {
    return HourlyWeather(
      temp: (json['main']['temp'] as num?)?.toDouble() ?? 0.0,
      weatherCategory: json['weather'][0]['main'] as String? ?? 'Unknown',
      condition: json['weather'][0]['description'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(
        ((json['dt'] as num?)?.toInt() ?? 0) * 1000,
        isUtc: true,
      ),
    );
  }
}
