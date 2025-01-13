import 'package:smart_solar_sunflower/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';

class SplashViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  Future<void> navigateToLogin() async {
    await _navigationService.navigateToLoginView();
  }

  Future<void> navigateToRegister() async {
    await _navigationService.navigateToRegisterView();
  }
}
