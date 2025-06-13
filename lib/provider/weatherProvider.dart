import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_weather/models/additionalWeatherData.dart';
import 'package:flutter_weather/models/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dailyWeather.dart';
import '../models/hourlyWeather.dart';
import '../models/weather.dart';

class WeatherProvider with ChangeNotifier {
  String apiKey = '667c4ca8e728435166dacb29fe3cfa93';
  Weather? weather;
  late AdditionalWeatherData additionalWeatherData;
  LatLng? currentLocation;
  List<HourlyWeather> hourlyWeather = [];
  List<DailyWeather> dailyWeather = [];
  bool isLoading = false;
  bool isRequestError = false;
  bool isSearchError = false;
  bool isLocationserviceEnabled = false;
  LocationPermission? locationPermission;
  bool isCelsius = true;
  String kLastCityKey = 'last_city';

  String get measurementUnit => isCelsius ? '°C' : '°F';

  Future<Position?> requestLocation(BuildContext context) async {
    isLocationserviceEnabled = await Geolocator.isLocationServiceEnabled();
    notifyListeners();

    if (!isLocationserviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location service disabled')),
      );
      return Future.error('Location services are disabled.');
    }

    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      isLoading = false;
      notifyListeners();
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Permission denied'),
        ));
        return Future.error('Location permissions are denied');
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Location permissions are permanently denied, Please enable manually from app settings',
        ),
      ));
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> getWeatherData(
    BuildContext context, {
    bool notify = false,
  }) async {
    isLoading = true;
    isRequestError = false;
    isSearchError = false;
    if (notify) notifyListeners();

    Position? locData = await requestLocation(context);

    if (locData == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      currentLocation = LatLng(locData.latitude, locData.longitude);
      await getCurrentWeather(currentLocation!);
      await getDailyWeather(currentLocation!);
    } catch (e) {
      print('Error fetching weather data: $e');

      isRequestError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCurrentWeather(LatLng location) async {
    Uri url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey',
    );
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      weather = Weather.fromJson(extractedData);
      print('Fetched Weather for: ${weather?.city}/${weather?.countryCode}');
    } catch (error) {
      developer.log('Error fetching current weather: $error');
      print(error);
      isLoading = false;
      this.isRequestError = true;
    }
  }

  Future<void> getDailyWeather(LatLng location) async {
    isLoading = true;
    notifyListeners();

    Uri forecastUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey',
    );
    try {
      final response = await http.get(forecastUrl);
      final forecastData = json.decode(response.body) as Map<String, dynamic>;

      List forecastList = forecastData['list'];

      // Extract first 24 hours for hourly weather
      hourlyWeather = forecastList
          .take(8) // 8 * 3 hours = 24 hours
          .map((item) => HourlyWeather.fromJson(item))
          .toList();

      // Aggregate daily weather data
      Map<String, List<dynamic>> dailyGroups = {};
      for (var item in forecastList) {
        DateTime date =
            DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000, isUtc: true);
        String dayKey = DateFormat('yyyy-MM-dd').format(date.toLocal());
        if (!dailyGroups.containsKey(dayKey)) {
          dailyGroups[dayKey] = [];
        }
        dailyGroups[dayKey]!.add(item);
      }

      dailyWeather = dailyGroups.entries.map((entry) {
        List<dynamic> dayData = entry.value;
        double tempSum = 0;
        double tempMin = double.infinity;
        double tempMax = -double.infinity;
        double tempMorn = 0;
        double tempDay = 0;
        double tempEve = 0;
        double tempNight = 0;
        int humiditySum = 0;
        int cloudSum = 0;
        double popSum = 0;
        String mainWeather = dayData[0]['weather'][0]['main'];
        String description = dayData[0]['weather'][0]['description'];
        int count = dayData.length;

        for (var item in dayData) {
          double temp = (item['main']['temp'] as num?)?.toDouble() ?? 0.0;
          tempSum += temp;
          tempMin = temp < tempMin ? temp : tempMin;
          tempMax = temp > tempMax ? temp : tempMax;
          humiditySum += (item['main']['humidity'] as num?)?.toInt() ?? 0;
          cloudSum += (item['clouds']['all'] as num?)?.toInt() ?? 0;
          popSum += (item['pop'] as num?)?.toDouble() ?? 0.0;
          DateTime itemDate = DateTime.fromMillisecondsSinceEpoch(
              item['dt'] * 1000,
              isUtc: true);
          int hour = itemDate.hour;
          double feelsLike =
              (item['main']['feels_like'] as num?)?.toDouble() ?? 0.0;
          if (feelsLike == 0.0) {
            developer.log('Null or invalid feels_like for item: $item');
          }
          if (hour >= 6 && hour < 12) {
            tempMorn = feelsLike;
          } else if (hour >= 12 && hour < 18) {
            tempDay = feelsLike;
          } else if (hour >= 18 && hour < 24) {
            tempEve = feelsLike;
          } else {
            tempNight = feelsLike;
          }
        }

        return DailyWeather(
          temp: tempSum / count,
          tempMin: tempMin,
          tempMax: tempMax,
          tempMorning: tempMorn,
          tempDay: tempDay,
          tempEvening: tempEve,
          tempNight: tempNight,
          weatherCategory: mainWeather,
          condition: description,
          date: DateTime.parse(entry.key),
          precipitation: (popSum / count * 100).toStringAsFixed(0),
          clouds: (cloudSum / count).round(),
          humidity: (humiditySum / count).round(),
          uvi: 0.0, // UVI not available in free forecast API
        );
      }).toList();

      // Set additional weather data (mock UVI as 0 since it's not available)
      additionalWeatherData = AdditionalWeatherData(
        precipitation:
            dailyWeather.isNotEmpty ? dailyWeather[0].precipitation : '0',
        uvi: 0.0,
        clouds: dailyWeather.isNotEmpty ? dailyWeather[0].clouds : 0,
      );
    } catch (error) {
      developer.log('Error fetching daily weather: $error');
      print(error);
      isLoading = false;
      this.isRequestError = true;
    }
  }

  Future<GeocodeData?> locationToLatLng(String location) async {
    try {
      Uri url = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$location&limit=5&appid=$apiKey',
      );
      final http.Response response = await http.get(url);
      if (response.statusCode != 200) return null;
      return GeocodeData.fromJson(
        jsonDecode(response.body)[0] as Map<String, dynamic>,
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> searchWeather(String location, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    isRequestError = false;
    isSearchError = false;
    print('search');

    try {
      GeocodeData? geocodeData = await locationToLatLng(location);

      if (geocodeData == null) throw Exception('Unable to Find Location');

      await getCurrentWeather(geocodeData.latLng);
      await getDailyWeather(geocodeData.latLng);

      weather?.city = geocodeData.name;

      // ✅ Save the last searched city to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kLastCityKey, location);
    } catch (e) {
      print('Error during search: $e');
      isSearchError = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to Find Location')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void switchTempUnit() {
    isCelsius = !isCelsius;
    notifyListeners();
  }
}
