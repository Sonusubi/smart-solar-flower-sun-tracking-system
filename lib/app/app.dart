import 'package:smart_solar_sunflower/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:smart_solar_sunflower/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:smart_solar_sunflower/ui/views/home/home_view.dart';
import 'package:smart_solar_sunflower/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:smart_solar_sunflower/ui/views/splash/splash_view.dart';
import 'package:smart_solar_sunflower/ui/views/login/login_view.dart';
import 'package:smart_solar_sunflower/ui/views/weather/weather_view.dart';
import 'package:smart_solar_sunflower/ui/views/solarpanel/solarpanel_view.dart';
import 'package:smart_solar_sunflower/services/weather_service.dart';
import 'package:smart_solar_sunflower/services/firebase_service.dart';
import 'package:smart_solar_sunflower/ui/views/register/register_view.dart';
import 'package:smart_solar_sunflower/ui/views/weather/weather_view.dart';
import 'package:smart_solar_sunflower/services/auth_service.dart';
import 'package:smart_solar_sunflower/ui/views/current/current_view.dart';
import 'package:smart_solar_sunflower/ui/views/voltage/voltage_view.dart';
import 'package:smart_solar_sunflower/ui/views/power/power_view.dart';
import 'package:smart_solar_sunflower/ui/views/tiltangle_h/tiltangle_h_view.dart';
import 'package:smart_solar_sunflower/ui/views/tiltangle_v/tiltangle_v_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: SplashView),
    MaterialRoute(page: LoginView),
    // MaterialRoute(page: WeatherView),
    MaterialRoute(page: SolarPanelView),
    MaterialRoute(page: RegisterView),
    MaterialRoute(page: WeatherView),
    MaterialRoute(page: CurrentView),
    MaterialRoute(page: VoltageView),
    MaterialRoute(page: PowerView),
    MaterialRoute(page: TiltangleHView),
    MaterialRoute(page: TiltangleVView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: WeatherService),
    LazySingleton(classType: FirebaseService),
    LazySingleton(classType: AuthService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
