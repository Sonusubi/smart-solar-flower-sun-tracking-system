import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../../services/weather_service.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (model) => model.fetchWeatherData(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Color(0xFFFFFFFF),
          appBar: AppBar(
            backgroundColor: Color(0xFFEBDEFF),
            elevation: 0,
            actions: [
              IconButton(
                  onPressed: () {
                    model.logout();
                  },
                  icon: Icon(Icons.logout))
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Header Section with Background Image
                Stack(
                  children: [
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF7E57C2),
                            const Color(0xFF7E57C2).withOpacity(0.95),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        image: DecorationImage(
                          image: AssetImage(_getBackgroundImage(model.getTimePeriod())),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KALADY,INDIA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3.0,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    model.temperature,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(2, 2),
                                          blurRadius: 4.0,
                                          color: Colors.black45,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    model.weatherCondition,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 3.0,
                                          color: Colors.black45,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    model.dateTime != null
                                        ? DateFormat('MMMM d, HH:mm').format(model.dateTime!)
                                        : 'Loading...',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 2.0,
                                          color: Colors.black45,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              _getWeatherIcon(model.getTimePeriod()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Rest of the Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildNavigationButton(
                                icon: Icons.cloud,
                                label: 'WEATHER',
                                onTap: model.navigateToWeather,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildNavigationButton(
                                icon: Icons.solar_power,
                                label: 'SOLAR PANEL',
                                onTap: model.navigateToSolarPanel,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getBackgroundImage(String timePeriod) {
    switch (timePeriod) {
      case 'sunrise':
        return 'assets/images/morning.png';
      case 'noon':
        return 'assets/images/afternoon.png';
      case 'evening':
        return 'assets/images/evening.png';
      case 'night':
        return 'assets/images/midnight.png';
      default:
        return 'assets/images/lanterns_bg.png';
    }
  }

  Widget _getWeatherIcon(String timePeriod) {
    switch (timePeriod) {
      case 'sunrise':
        return Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.yellow],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            shape: BoxShape.circle,
          ),
        );
      case 'noon':
        return Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.yellow,
            shape: BoxShape.circle,
          ),
        );
      case 'evening':
        return Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            shape: BoxShape.circle,
          ),
        );
      case 'night':
        return Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.nightlight_round, size: 40, color: Colors.black54),
        );
      default:
        return Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.yellow,
            shape: BoxShape.circle,
          ),
        );
    }
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Color(0xFFEBDEFF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2.0,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
