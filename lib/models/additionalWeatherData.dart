// ignore_for_file: public_member_api_docs, sort_constructors_first
class AdditionalWeatherData {
  final String precipitation;
  final double uvi;
  final int clouds;
  AdditionalWeatherData({
    required this.precipitation,
    required this.uvi,
    required this.clouds,
  });

  factory AdditionalWeatherData.fromJson(Map<String, dynamic> json) {
    final precipData = json['list'][0]['pop'] ?? 0.0;
    final precip = (precipData * 100).toStringAsFixed(0);
    return AdditionalWeatherData(
      precipitation: precip,
      uvi: 0.0, // UVI not available in free forecast API
      clouds: json['list'][0]['clouds']['all'] ?? 0,
    );
  }
}