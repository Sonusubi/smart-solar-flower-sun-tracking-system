import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class CurrentViewModel extends BaseViewModel {
  static const String CURRENT_DATA_KEY = 'current';
  static const int MAX_POINTS = 500;

  List<FlSpot> currentSpots = [];
  double currentXValue = 0;
  double currentCurrent = 0;
  double previousCurrent = -1; // Store the previous voltage
  late SharedPreferences _prefs;

  final DatabaseReference _currentRef = FirebaseDatabase.instance.ref('Solar/otherdata/current');

  Future<void> initialize() async {
    setBusy(true);
    await _initSharedPreferences();
    await _loadStoredCurrentData();
    _subscribeToCurrentData(); // Listen to Firebase database changes
    setBusy(false);
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadStoredCurrentData() async {
    final storedCurrentData = _prefs.getString(CURRENT_DATA_KEY);
    if (storedCurrentData != null) {
      final List<dynamic> decodedCurrentData = json.decode(storedCurrentData);
      currentSpots = decodedCurrentData
          .map((point) => FlSpot(
        double.parse(point['x'].toString()),
        double.parse(point['y'].toString()),
      ))
          .toList();
      currentXValue = currentSpots.isNotEmpty ? currentSpots.last.x.toInt() + 1 : 0;
      currentCurrent = currentSpots.isNotEmpty ? currentSpots.last.y : 0; // Set current voltage from stored data
      previousCurrent = currentCurrent; // Set the previous voltage from stored data
    }
  }

  void _subscribeToCurrentData() {
    _currentRef.onValue.listen((event) {
      final dynamic currentData = event.snapshot.value;

      if (currentData != null) {
        final double current = double.tryParse(currentData.toString()) ?? 0.0;

        print('Received voltage: $current'); // Debugging print

        // Check if the voltage value has changed
        if (current != previousCurrent) {
          if (currentSpots.length > MAX_POINTS) {
            currentSpots.removeAt(0); // Remove the oldest data point if exceeding MAX_POINTS
          }

          // Add the new data point to the graph
          currentSpots.add(FlSpot(currentXValue.toDouble(), current));
          currentXValue++;
          currentCurrent = current; // Update the current voltage
          previousCurrent = current; // Update the previous voltage

          // Store updated voltage data in SharedPreferences
          _storeCurrentData();

          // Notify listeners to update the UI
          notifyListeners();
        }
      }
    });
  }


  Future<void> _storeCurrentData() async {
    final List<Map<String, double>> currentDataToStore = currentSpots
        .map((spot) => {
      'x': spot.x,
      'y': spot.y,
    })
        .toList();

    await _prefs.setString(CURRENT_DATA_KEY, json.encode(currentDataToStore));
  }

  void resetCurrentGraph() {
    currentSpots.clear();
    currentXValue = 0;
    previousCurrent = -1; // Reset the previous voltage when resetting the graph
    _storeCurrentData();
    notifyListeners();
  }

  LineChartData getCurrentChartData() {
    if (currentSpots.isEmpty) {
      currentSpots = [const FlSpot(0, 0)];
    }

    return LineChartData(
      backgroundColor: Colors.white,
      lineBarsData: [
        LineChartBarData(
          spots: currentSpots,
          color: Colors.blue,
          isCurved: true,
          dotData: const FlDotData(show: false),
          barWidth: 2,
        ),
      ],
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: 5,
        verticalInterval: 1,
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
          axisNameWidget: const Text('Current (A)'),
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
      maxY: 100,
      minX: 0,
      maxX: currentSpots.isNotEmpty ? currentSpots.last.x + 5 : 5,
    );
  }
}
