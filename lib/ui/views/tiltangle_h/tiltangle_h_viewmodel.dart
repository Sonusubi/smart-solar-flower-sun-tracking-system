import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class TiltangleHViewModel extends BaseViewModel {
  static const String TILTANGLEH_DATA_KEY = 'tiltangleH';
  static const int MAX_POINTS = 500;

  List<FlSpot> tiltangleHSpots = [];
  double tiltangleHXValue = 0;
  double currentTiltangleH = 0;
  double previousTiltangleH = -1; // Store the previous tilt angle
  late SharedPreferences _prefs;

  final DatabaseReference _tiltangleHRef = FirebaseDatabase.instance.ref('Solar/otherdata/tiltangle');

  Future<void> initialize() async {
    setBusy(true);
    await _initSharedPreferences();
    await _loadStoredTiltangleHData();
    _subscribeToTiltangleHData(); // Listen to Firebase database changes
    setBusy(false);
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadStoredTiltangleHData() async {
    final storedTiltangleHData = _prefs.getString(TILTANGLEH_DATA_KEY);
    if (storedTiltangleHData != null) {
      final List<dynamic> decodedTiltangleHData = json.decode(storedTiltangleHData);
      tiltangleHSpots = decodedTiltangleHData
          .map((point) => FlSpot(
        double.parse(point['x'].toString()),
        double.parse(point['y'].toString()),
      ))
          .toList();
      tiltangleHXValue = tiltangleHSpots.isNotEmpty ? tiltangleHSpots.last.x.toInt() + 1 : 0;
      currentTiltangleH = tiltangleHSpots.isNotEmpty ? tiltangleHSpots.last.y : 0; // Set current tilt angle
      previousTiltangleH = currentTiltangleH; // Set the previous tilt angle
    }
  }

  void _subscribeToTiltangleHData() {
    _tiltangleHRef.onValue.listen((event) {
      final dynamic tiltangleHData = event.snapshot.value;

      if (tiltangleHData != null) {
        final double tiltangleH = double.tryParse(tiltangleHData.toString()) ?? 0.0;

        print('Received tilt angle H: $tiltangleH'); // Debugging print

        // Check if the tilt angle value has changed
        if (tiltangleH != previousTiltangleH) {
          if (tiltangleHSpots.length > MAX_POINTS) {
            tiltangleHSpots.removeAt(0); // Remove the oldest data point if exceeding MAX_POINTS
          }

          // Add the new data point to the graph
          tiltangleHSpots.add(FlSpot(tiltangleHXValue.toDouble(), tiltangleH));
          tiltangleHXValue++;
          currentTiltangleH = tiltangleH; // Update the current tilt angle
          previousTiltangleH = tiltangleH; // Update the previous tilt angle

          // Store updated tilt angle data in SharedPreferences
          _storeTiltangleHData();

          // Notify listeners to update the UI
          notifyListeners();
        }
      }
    });
  }

  Future<void> _storeTiltangleHData() async {
    final List<Map<String, double>> tiltangleHDataToStore = tiltangleHSpots
        .map((spot) => {
      'x': spot.x,
      'y': spot.y,
    })
        .toList();

    await _prefs.setString(TILTANGLEH_DATA_KEY, json.encode(tiltangleHDataToStore));
  }

  void resetTiltangleHGraph() {
    tiltangleHSpots.clear();
    tiltangleHXValue = 0;
    previousTiltangleH = -1; // Reset the previous tilt angle when resetting the graph
    _storeTiltangleHData();
    notifyListeners();
  }

  LineChartData getTiltangleHChartData() {
    if (tiltangleHSpots.isEmpty) {
      tiltangleHSpots = [const FlSpot(0, 0)];
    }

    return LineChartData(
      backgroundColor: Colors.white,
      lineBarsData: [
        LineChartBarData(
          spots: tiltangleHSpots,
          color: Colors.orange,
          isCurved: true,
          dotData: const FlDotData(show: false),
          barWidth: 2,
        ),
      ],
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: 10,
        verticalInterval: 2,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.black12, strokeWidth: 1),
        getDrawingVerticalLine: (value) =>
            FlLine(color: Colors.black12, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          axisNameWidget: const Text('Time (s)'),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: const Text('Tilt Angle H (°)'),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: Colors.black26),
          bottom: BorderSide(color: Colors.black26),
        ),
      ),
      minY: 0,
      maxY: 180, // Adjust based on expected tilt angle range
      minX: 0,
      maxX: tiltangleHSpots.isNotEmpty ? tiltangleHSpots.last.x + 5 : 5,
    );
  }
}
