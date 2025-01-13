import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class TiltangleVViewModel extends BaseViewModel {
  static const String TILTANGLEH_DATA_KEY = 'tiltangleV';
  static const int MAX_POINTS = 500;

  List<FlSpot> tiltangleVSpots = [];
  double tiltangleVXValue = 0;
  double currentTiltangleV = 0;
  double previousTiltangleV = -1; // Store the previous tilt angle
  late SharedPreferences _prefs;

  final DatabaseReference _tiltangleVRef = FirebaseDatabase.instance.ref('Solar/otherdata/tiltangle2');

  Future<void> initialize() async {
    setBusy(true);
    await _initSharedPreferences();
    await _loadStoredTiltangleVData();
    _subscribeToTiltangleVData(); // Listen to Firebase database changes
    setBusy(false);
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadStoredTiltangleVData() async {
    final storedTiltangleVData = _prefs.getString(TILTANGLEH_DATA_KEY);
    if (storedTiltangleVData != null) {
      final List<dynamic> decodedTiltangleVData = json.decode(storedTiltangleVData);
      tiltangleVSpots = decodedTiltangleVData
          .map((point) => FlSpot(
        double.parse(point['x'].toString()),
        double.parse(point['y'].toString()),
      ))
          .toList();
      tiltangleVXValue = tiltangleVSpots.isNotEmpty ? tiltangleVSpots.last.x.toInt() + 1 : 0;
      currentTiltangleV = tiltangleVSpots.isNotEmpty ? tiltangleVSpots.last.y : 0; // Set current tilt angle
      previousTiltangleV = currentTiltangleV; // Set the previous tilt angle
    }
  }

  void _subscribeToTiltangleVData() {
    _tiltangleVRef.onValue.listen((event) {
      final dynamic tiltangleVData = event.snapshot.value;

      if (tiltangleVData != null) {
        final double tiltangleV = double.tryParse(tiltangleVData.toString()) ?? 0.0;

        print('Received tilt angle H: $tiltangleV'); // Debugging print

        // Check if the tilt angle value has changed
        if (tiltangleV != previousTiltangleV) {
          if (tiltangleVSpots.length > MAX_POINTS) {
            tiltangleVSpots.removeAt(0); // Remove the oldest data point if exceeding MAX_POINTS
          }

          // Add the new data point to the graph
          tiltangleVSpots.add(FlSpot(tiltangleVXValue.toDouble(), tiltangleV));
          tiltangleVXValue++;
          currentTiltangleV = tiltangleV; // Update the current tilt angle
          previousTiltangleV = tiltangleV; // Update the previous tilt angle

          // Store updated tilt angle data in SharedPreferences
          _storeTiltangleVData();

          // Notify listeners to update the UI
          notifyListeners();
        }
      }
    });
  }

  Future<void> _storeTiltangleVData() async {
    final List<Map<String, double>> tiltangleVDataToStore = tiltangleVSpots
        .map((spot) => {
      'x': spot.x,
      'y': spot.y,
    })
        .toList();

    await _prefs.setString(TILTANGLEH_DATA_KEY, json.encode(tiltangleVDataToStore));
  }

  void resetTiltangleVGraph() {
    tiltangleVSpots.clear();
    tiltangleVXValue = 0;
    previousTiltangleV = -1; // Reset the previous tilt angle when resetting the graph
    _storeTiltangleVData();
    notifyListeners();
  }

  LineChartData getTiltangleVChartData() {
    if (tiltangleVSpots.isEmpty) {
      tiltangleVSpots = [const FlSpot(0, 0)];
    }

    return LineChartData(
      backgroundColor: Colors.white,
      lineBarsData: [
        LineChartBarData(
          spots: tiltangleVSpots,
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
          axisNameWidget: const Text('Tilt Angle V (°)'),
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
      maxX: tiltangleVSpots.isNotEmpty ? tiltangleVSpots.last.x + 5 : 5,
    );
  }
}
