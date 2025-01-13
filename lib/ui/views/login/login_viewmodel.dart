import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.router.dart';
import '../../../services/auth_service.dart';

class LoginViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();
  final NavigationService _navigationService = NavigationService();

  String _email = '';
  String _password = '';
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  void setEmail(String email) {
    _email = email;
    _errorMessage = null;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    _errorMessage = null;
    notifyListeners();
  }

  bool _validateInputs() {
    if (_email.isEmpty || !_email.contains('@')) {
      _errorMessage = 'Please enter a valid email';
      notifyListeners();
      return false;
    }
    if (_password.isEmpty) {
      _errorMessage = 'Password cannot be empty';
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<void> login() async {
    if (!_validateInputs()) return;

    try {
      setBusy(true);
      await _authService.loginWithEmail(_email, _password);
      // Navigate to home view after successful login
      _navigationService.replaceWith(Routes.homeView);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }
}
