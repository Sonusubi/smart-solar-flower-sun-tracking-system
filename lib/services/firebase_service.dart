import 'package:firebase_database/firebase_database.dart';

import '../models/device_data.dart';

class FirebaseService {
  final DatabaseReference _db =
      FirebaseDatabase.instance.ref().child('Solar/otherdata');

  Stream<SolarPanelData> getSolarPanelData() {
    return _db.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return SolarPanelData.fromJson(Map<String, dynamic>.from(data));
    });
  }

  Future<void> updateSolarPanelData(SolarPanelData data) async {
    await _db.set(data.toJson());
  }
}
