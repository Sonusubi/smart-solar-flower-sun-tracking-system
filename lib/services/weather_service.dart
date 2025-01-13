import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class WeatherService {
  final String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Fetches hourly weather data
  Future<Map<String, dynamic>> fetchHourlyWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl?latitude=10.165998&longitude=76.438687&current=rain&hourly=temperature_2m,relative_humidity_2m,rain,weather_code,wind_speed_10m,uv_index,is_day,temperature_1000hPa&daily=sunrise,sunset,uv_index_max&timezone=auto&forecast_days=16&forecast_hours=24',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to fetch weather data: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching weather data: $e');
    }
  }
}
