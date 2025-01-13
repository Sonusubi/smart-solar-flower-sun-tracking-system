import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class VoltageViewModel extends BaseViewModel {
  static const String VOLTAGE_DATA_KEY = 'voltage';
  static const int MAX_POINTS = 500;

  List<FlSpot> voltageSpots = [];
  double voltageXValue = 0;
  double currentVoltage = 0;
  double previousVoltage = -1; // Store the previous voltage
  late SharedPreferences _prefs;

  final DatabaseReference _voltageRef = FirebaseDatabase.instance.ref('Solar/otherdata/voltage');

  Future<void> initialize() async {
    setBusy(true);
    await _initSharedPreferences();
    await _loadStoredVoltageData();
    _subscribeToVoltageData(); // Listen to Firebase database changes
    setBusy(false);
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadStoredVoltageData() async {
    final storedVoltageData = _prefs.getString(VOLTAGE_DATA_KEY);
    if (storedVoltageData != null) {
      final List<dynamic> decodedVoltageData = json.decode(storedVoltageData);
      voltageSpots = decodedVoltageData
          .map((point) => FlSpot(
        double.parse(point['x'].toString()),
        double.parse(point['y'].toString()),
      ))
          .toList();
      voltageXValue = voltageSpots.isNotEmpty ? voltageSpots.last.x.toInt() + 1 : 0;
      currentVoltage = voltageSpots.isNotEmpty ? voltageSpots.last.y : 0; // Set current voltage from stored data
      previousVoltage = currentVoltage; // Set the previous voltage from stored data
    }
  }

  void _subscribeToVoltageData() {
    _voltageRef.onValue.listen((event) {
      final dynamic voltageData = event.snapshot.value;

      if (voltageData != null) {
        final double voltage = double.tryParse(voltageData.toString()) ?? 0.0;

        print('Received voltage: $voltage'); // Debugging print

        // Check if the voltage value has changed
        if (voltage != previousVoltage) {
          if (voltageSpots.length > MAX_POINTS) {
            voltageSpots.removeAt(0); // Remove the oldest data point if exceeding MAX_POINTS
          }

          // Add the new data point to the graph
          voltageSpots.add(FlSpot(voltageXValue.toDouble(), voltage));
          voltageXValue++;
          currentVoltage = voltage; // Update the current voltage
          previousVoltage = voltage; // Update the previous voltage

          // Store updated voltage data in SharedPreferences
          _storeVoltageData();

          // Notify listeners to update the UI
          notifyListeners();
        }
      }
    });
  }


  Future<void> _storeVoltageData() async {
    final List<Map<String, double>> voltageDataToStore = voltageSpots
        .map((spot) => {
      'x': spot.x,
      'y': spot.y,
    })
        .toList();

    await _prefs.setString(VOLTAGE_DATA_KEY, json.encode(voltageDataToStore));
  }

  void resetVoltageGraph() {
    voltageSpots.clear();
    voltageXValue = 0;
    previousVoltage = -1; // Reset the previous voltage when resetting the graph
    _storeVoltageData();
    notifyListeners();
  }

  LineChartData getVoltageChartData() {
    if (voltageSpots.isEmpty) {
      voltageSpots = [const FlSpot(0, 0)];
    }

    return LineChartData(
      backgroundColor: Colors.white,
      lineBarsData: [
        LineChartBarData(
          spots: voltageSpots,
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
          axisNameWidget: const Text('Voltage (V)'),
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
      maxX: voltageSpots.isNotEmpty ? voltageSpots.last.x + 5 : 5,
    );
  }
}
