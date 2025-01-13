import 'package:stacked/stacked.dart';
import 'package:smart_solar_sunflower/app/app.locator.dart';
import 'package:smart_solar_sunflower/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  // Check login state and navigate accordingly
  Future<void> runStartupLogic() async {
    await Future.delayed(
        const Duration(seconds: 3)); // Simulate a loading delay

    // Check if the user is already logged in
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, navigate to Home View
      _navigationService.replaceWithHomeView();
    } else {
      // User is not logged in, navigate to Splash View
      _navigationService.replaceWithSplashView();
    }
  }
}
