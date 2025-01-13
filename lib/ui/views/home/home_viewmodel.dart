import 'package:intl/intl.dart';
import 'package:smart_solar_sunflower/app/app.router.dart';
import 'package:smart_solar_sunflower/services/auth_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../services/weather_service.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final WeatherService _weatherService = WeatherService();
  final _dialogService = locator<DialogService>();
  final _userService = locator<AuthService>();

  String location = 'Kalady, India'; // Static for this example
  String temperature = '--';
  String weatherCondition = '--';
  DateTime? dateTime;

  String getTimePeriod() {
    if (dateTime == null) return 'day';

    int hour = dateTime!.hour;

    if (hour >= 6 && hour < 10) {
      return 'sunrise';
    } else if (hour >= 10 && hour < 15) {
      return 'noon';
    } else if (hour >= 15 && hour < 18) {
      return 'evening';
    } else {
      return 'night';
    }
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter =
        DateFormat('MMMM d, HH:mm'); // e.g., December 4, 17:14
    return formatter.format(dateTime);
  }

  Future<void> fetchWeatherData() async {
    setBusy(true);

    try {
      final data = await _weatherService.fetchHourlyWeather(
        latitude: 10.165998,
        longitude:  76.438687,
      );

      print('Weather Data: $data');

      temperature = '${data["hourly"]["temperature_2m"][0]}°';
      weatherCondition =
          _mapWeatherCodeToCondition(data['hourly']['weather_code'][0]);
      dateTime = DateTime.now();
    } catch (e) {
      print('Error fetching weather data: $e');
      temperature = '--';
      weatherCondition = 'Error';
      dateTime = null;
    }

    setBusy(false);
    notifyListeners();
  }

  Future<void> navigateToWeather() async {
    await _navigationService.navigateToWeatherView();
  }

  Future<void> navigateToSolarPanel() async {
    await _navigationService.navigateToSolarPanelView();
  }

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

  Future<void> logout() async {
    DialogResponse? response = await _dialogService.showConfirmationDialog(
      title: 'Logout',
      description: 'Are you sure you want to logout?',
      confirmationTitle: 'Yes',
      cancelTitle: 'No',
    );

    if (response != null && response.confirmed) {
      setBusy(true);
      await _userService.logout();
      _navigationService.replaceWithSplashView();
      setBusy(false);
    }
  }
}
