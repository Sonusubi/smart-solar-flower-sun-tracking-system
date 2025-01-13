import 'package:flutter/material.dart';
import 'package:smart_solar_sunflower/ui/views/solarpanel/solarpanel_viewmodel.dart';
import 'package:stacked/stacked.dart';

class SolarPanelView extends StatelessWidget {
  const SolarPanelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SolarPanelViewModel>.reactive(
      viewModelBuilder: () => SolarPanelViewModel(),
      onViewModelReady: (viewModel) => viewModel.initialize(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(),
        body: viewModel.panelData == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: CustomPaint(
                                painter: CircularProgressPainter(
                                  progress:
                                      viewModel.panelData!.efficiency / 100,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'EFFICIENCY',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${viewModel.panelData!.efficiency.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.bolt,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          InkWell(
                            onTap:viewModel.navigateToVoltageDetails,
                            child: _buildInfoCard(
                              icon: Icons.bolt,
                              title: 'VOLTAGE',
                              value: '${viewModel.panelData!.voltage}V',
                            ),
                          ),
                          InkWell(
                            onTap: viewModel.navigateToCurrentDetails,
                            child: _buildInfoCard(
                              icon: Icons.electric_meter,
                              title: 'CURRENT',
                              value: '${viewModel.panelData!.current}A',
                            ),
                          ),
                          InkWell(
                            onTap: viewModel.navigateToPowerDetails,
                            child: _buildInfoCard(
                              icon: Icons.power,
                              title: 'POWER',
                              value: '${viewModel.panelData!.power}W',
                            ),
                          ),
                          InkWell(
                            onTap: viewModel.navigateToTiltAngleHDetails,
                            child: _buildInfoCard(
                              icon: Icons.solar_power,
                              title: 'TILT ANGLE H',
                              value: '${viewModel.panelData!.tiltangle}°',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: InkWell(
                          onTap: viewModel.navigateToTiltAngleVDetails,
                          child: _buildInfoCard(
                            icon: Icons.solar_power,
                            title: 'TILT ANGLE V',
                            value: '${viewModel.panelData!.tiltangle2}°',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.black87),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ),
      -1.5708,
      progress * 2 * 3.14159,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
