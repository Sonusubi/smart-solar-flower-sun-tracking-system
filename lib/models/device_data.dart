class SolarPanelData {
  final double voltage;
  final double current;
  final double power;
  final double tiltangle;
  final double tiltangle2;
  final double efficiency;

  SolarPanelData({
    required this.voltage,
    required this.current,
    required this.power,
    required this.tiltangle,
    required this.tiltangle2,
    required this.efficiency,
  });

  factory SolarPanelData.fromJson(Map<String, dynamic> json) {
    return SolarPanelData(
      voltage: json['voltage']?.toDouble() ?? 0.0,
      current: json['current']?.toDouble() ?? 0.0,
      power: json['power']?.toDouble() ?? 0.0,
      tiltangle: json['tiltangle']?.toDouble() ?? 0.0,
      tiltangle2: json['tiltangle2']?.toDouble() ?? 0.0,
      efficiency: json['efficiency']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voltage': voltage,
      'current': current,
      'power': power,
      'tiltangle': tiltangle,
      'tiltangle2': tiltangle2,
      'efficiency': efficiency,
    };
  }
}
