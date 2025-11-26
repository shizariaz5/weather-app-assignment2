import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  // Using your actual API key
  static final String _apiKey = 'a933b17558fd4b4afab280f637b22652';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<WeatherData> getCurrentWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('City not found');
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  static Future<ForecastResponse> getForecast(String cityName) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/forecast?q=$cityName&appid=$_apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return ForecastResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('City not found');
    } else {
      throw Exception('Failed to load forecast data: ${response.statusCode}');
    }
  }
}