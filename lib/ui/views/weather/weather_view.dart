import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'weather_viewmodel.dart';

class WeatherView extends StatelessWidget {
  const WeatherView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WeatherViewModel>.reactive(
      viewModelBuilder: () => WeatherViewModel(),
      onModelReady: (model) => model.initialize(),
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF7E57C2),
          body: SafeArea(
            child: viewModel.isBusy
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                            width: double.infinity,
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
                              image: const DecorationImage(
                                image:
                                    AssetImage('assets/images/lanterns_bg.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Location Header
                                      const Text(
                                        'KALADY, INDIA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Temperature and Weather Section
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                viewModel.temperature ?? '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 64,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                viewModel.currentDateTime ?? '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              const Icon(Icons.cloud,
                                                  color: Colors.white,
                                                  size: 40),
                                              Text(
                                                viewModel.weatherCondition ??
                                                    '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ]))),

                        const SizedBox(height: 10),

                        // Tabs
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildTab('Today', true),
                                  const SizedBox(width: 8),
                                  _buildTab('Tomorrow', false),
                                  const SizedBox(width: 8),
                                  _buildTab('10 days', false),
                                ],
                              ),
                        const SizedBox(height: 16),

                        // Weather Details Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildWeatherCard(
                                'Wind speed',
                                '${viewModel.windSpeed}km/h',
                                '↓ 2 km/h',
                                Icons.air,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildWeatherCard(
                                'Rain chance',
                                '${viewModel.rainChance}%',
                                '↓ 10%',
                                Icons.water_drop,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: _buildWeatherCard(
                                'Pressure',
                                '${viewModel.pressure} hPa',
                                '↑ 32 hpa',
                                Icons.compress,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildWeatherCard(
                                'UV Index',
                                viewModel.uvIndex ?? '',
                                '0.3',
                                Icons.wb_sunny,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Hourly Forecast
                        const Text(
                          'Hourly forecast',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: viewModel.hourlyForecast.length,
                            itemBuilder: (context, index) {
                              final forecast = viewModel.hourlyForecast[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: _buildHourlyForecast(
                                  forecast['time'] ?? '',
                                  forecast['temp'] ?? '',
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sunrise/Sunset
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSunriseSunset(
                              'Sunrise',
                              viewModel.sunrise ?? '',
                              Icons.arrow_upward,
                            ),
                            _buildSunriseSunset(
                              'Sunset',
                              viewModel.sunset ?? '',
                              Icons.arrow_downward,
                            ),
                          ],
                        ),
                      ],

          )
        )
            ]
        )
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildTab(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildWeatherCard(
      String title, String value, String change, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            change,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(String time, String temp) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        const Icon(Icons.cloud, color: Colors.white70),
        const SizedBox(height: 8),
        Text(
          temp,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSunriseSunset(String title, String time, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
