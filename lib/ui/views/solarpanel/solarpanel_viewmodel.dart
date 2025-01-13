// solar_panel_viewmodel.dart
import 'package:smart_solar_sunflower/services/firebase_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:async';

import '../../../models/device_data.dart';
import '../current/current_view.dart';
import '../power/power_view.dart';
import '../tiltangle_h/tiltangle_h_view.dart';
import '../tiltangle_v/tiltangle_v_view.dart';
import '../voltage/voltage_view.dart';

class SolarPanelViewModel extends BaseViewModel {
  final FirebaseService _service = FirebaseService();
  final NavigationService _navigationService = NavigationService();

  StreamSubscription? _dataSubscription;
  SolarPanelData? _panelData;

  SolarPanelData? get panelData => _panelData;

  void initialize() {
    _dataSubscription = _service.getSolarPanelData().listen((data) {
      _panelData = data;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }
  void navigateToVoltageDetails() {
    _navigationService.navigateToView(
      VoltageView(),
    );
  }

  void navigateToCurrentDetails() {
    _navigationService.navigateToView(
      CurrentView(),
    );
  }

  void navigateToPowerDetails() {
    _navigationService.navigateToView(
      PowerView(),
    );
  }

  void navigateToTiltAngleHDetails() {
    _navigationService.navigateToView(
      TiltangleHView(),
    );
  }

  void navigateToTiltAngleVDetails() {
    _navigationService.navigateToView(
      TiltangleVView(),
    );
  }
}
