import 'package:stacked/stacked.dart';
import '../../../services/weather_service.dart';

class WeatherViewModel extends BaseViewModel {
  final WeatherService _weatherService = WeatherService();

  List<Map<String, String>> hourlyForecast = [];
  String temperature = '--';
  String windSpeed = '--';
  String rainChance = '--';
  String pressure = '--';
  String uvIndex = '--';
  String locationName = 'KALADY, INDIA';
  String? currentDateTime;
  String weatherCondition = '--';
  String sunrise = '--';
  String sunset = '--';

  /// Initialize and fetch weather data
  Future<void> initialize() async {
    setBusy(true);

    try {
      // Replace with your desired coordinates
      const latitude = 10.165998;
      const longitude = 76.438687;

      final data = await _weatherService.fetchHourlyWeather(
        latitude: latitude,
        longitude: longitude,
      );

      _processWeatherData(data);
    } catch (e) {
      // Handle any errors here
      print('Error fetching weather data: $e');
    } finally {
      setBusy(false);
    }
  }

  /// Process API data to populate the required fields
  void _processWeatherData(Map<String, dynamic> data) {
    // Fetch the hourly weather data
    final hourly = data['hourly'];
    final daily = data['daily'];

    if (hourly != null) {
      hourlyForecast = List.generate(24, (index) {
        return {
          'time': _formatTime(hourly['time'][index]),
          'temp': '${hourly['temperature_2m'][index]}°C',
        };
      });

      // Update other fields
      temperature = '${hourly['temperature_2m'][0]}°C';
      windSpeed = '${hourly['wind_speed_10m'][0]}';
      rainChance = '${hourly['rain'][0]} mm';
      pressure = '${hourly['temperature_1000hPa'][0]}'; // Adjust field if necessary
      uvIndex = '${hourly['uv_index'][0]}';
      weatherCondition = _mapWeatherCodeToCondition(hourly['weather_code'][0]);
      currentDateTime = DateTime.now().toString();
    }

    // Fetch the daily sunrise and sunset data
    if (daily != null) {
      sunrise = _formatDateTime(daily['sunrise'][0]);
      sunset = _formatDateTime(daily['sunset'][0]);
    }

    notifyListeners();
  }

  /// Map weather_code to a human-readable condition
  String _mapWeatherCodeToCondition(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Severe Thunderstorm';
      default:
        return 'Unknown';
    }
  }

  /// Format the time string for hourly data
  String _formatTime(String time) {
    final dateTime = DateTime.parse(time);
    return '${dateTime.hour}:00';
  }

  /// Format sunrise and sunset time
  String _formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
