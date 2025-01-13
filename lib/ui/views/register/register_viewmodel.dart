import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.router.dart';
import '../../../services/auth_service.dart';

class RegisterViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();
  final NavigationService _navigationService = NavigationService();

  String _email = '';
  String _password = '';
  String _username = '';
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

  void setUsername(String username) {
    _username = username;
    _errorMessage = null;
    notifyListeners();
  }

  bool _validateInputs() {
    if (_username.isEmpty) {
      _errorMessage = 'Username is required';
      notifyListeners();
      return false;
    }
    if (_email.isEmpty || !_email.contains('@')) {
      _errorMessage = 'Please enter a valid email';
      notifyListeners();
      return false;
    }
    if (_password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<void> register() async {
    if (!_validateInputs()) return;

    try {
      setBusy(true);
      await _authService.registerWithEmail(_email, _password, _username);
      // Navigate to home view after successful registration
      _navigationService.replaceWith(Routes.homeView);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }
}
