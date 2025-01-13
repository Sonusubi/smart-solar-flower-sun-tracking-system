import 'package:flutter_test/flutter_test.dart';
import 'package:smart_solar_sunflower/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('WeatherServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
