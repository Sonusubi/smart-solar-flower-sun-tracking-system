import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class PowerViewModel extends BaseViewModel {
  static const String POWER_DATA_KEY = 'power';
  static const int MAX_POINTS = 500;

  List<FlSpot> powerSpots = [];
  double powerXValue = 0;
  double currentPower = 0;
  double previousPower = -1; // Store the previous power value
  late SharedPreferences _prefs;

  final DatabaseReference _powerRef = FirebaseDatabase.instance.ref('Solar/otherdata/power');

  Future<void> initialize() async {
    setBusy(true);
    await _initSharedPreferences();
    await _loadStoredPowerData();
    _subscribeToPowerData(); // Listen to Firebase database changes
    setBusy(false);
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadStoredPowerData() async {
    final storedPowerData = _prefs.getString(POWER_DATA_KEY);
    if (storedPowerData != null) {
      final List<dynamic> decodedPowerData = json.decode(storedPowerData);
      powerSpots = decodedPowerData
          .map((point) => FlSpot(
        double.parse(point['x'].toString()),
        double.parse(point['y'].toString()),
      ))
          .toList();
      powerXValue = powerSpots.isNotEmpty ? powerSpots.last.x.toInt() + 1 : 0;
      currentPower = powerSpots.isNotEmpty ? powerSpots.last.y : 0; // Set current power from stored data
      previousPower = currentPower; // Set the previous power from stored data
    }
  }

  void _subscribeToPowerData() {
    _powerRef.onValue.listen((event) {
      final dynamic powerData = event.snapshot.value;

      if (powerData != null) {
        final double power = double.tryParse(powerData.toString()) ?? 0.0;

        print('Received power: $power'); // Debugging print

        // Check if the power value has changed
        if (power != previousPower) {
          if (powerSpots.length > MAX_POINTS) {
            powerSpots.removeAt(0); // Remove the oldest data point if exceeding MAX_POINTS
          }

          // Add the new data point to the graph
          powerSpots.add(FlSpot(powerXValue.toDouble(), power));
          powerXValue++;
          currentPower = power; // Update the current power
          previousPower = power; // Update the previous power

          // Store updated power data in SharedPreferences
          _storePowerData();

          // Notify listeners to update the UI
          notifyListeners();
        }
      }
    });
  }

  Future<void> _storePowerData() async {
    final List<Map<String, double>> powerDataToStore = powerSpots
        .map((spot) => {
      'x': spot.x,
      'y': spot.y,
    })
        .toList();

    await _prefs.setString(POWER_DATA_KEY, json.encode(powerDataToStore));
  }

  void resetPowerGraph() {
    powerSpots.clear();
    powerXValue = 0;
    previousPower = -1; // Reset the previous power when resetting the graph
    _storePowerData();
    notifyListeners();
  }

  LineChartData getPowerChartData() {
    if (powerSpots.isEmpty) {
      powerSpots = [const FlSpot(0, 0)];
    }

    return LineChartData(
      backgroundColor: Colors.white,
      lineBarsData: [
        LineChartBarData(
          spots: powerSpots,
          color: Colors.green,
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
          axisNameWidget: const Text('Power (W)'),
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
      maxY: 200, // Adjust based on expected power range
      minX: 0,
      maxX: powerSpots.isNotEmpty ? powerSpots.last.x + 5 : 5,
    );
  }
}
