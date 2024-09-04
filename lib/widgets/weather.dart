import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherMapWidget extends StatefulWidget {
  const WeatherMapWidget({super.key});

  @override
  WeatherMapWidgetState createState() => WeatherMapWidgetState();
}

class WeatherMapWidgetState extends State<WeatherMapWidget> {
  final String apiKey = '75b09790e6b51f5ac93affa1334f9644';
  final MapController mapController = MapController();
  List<Marker> markers = [];
  LatLng? currentLocation;
  String? currentCity;
  String? weatherDescription;
  double? temperature;
  double? windSpeed;
  int? humidity;
  int? pressure;
  double? visibility;
  String? windDirection;
  bool isLoading = true;
  Timer? weatherUpdateTimer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    weatherUpdateTimer = Timer.periodic(const Duration(minutes: 10), (timer) => fetchWeather());
  }

  @override
  void dispose() {
    weatherUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
      await _getAddressFromLatLng();
      fetchWeather();
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        currentLocation = const LatLng(12.9716, 77.5946);
        currentCity = 'Bengaluru';
      });
      fetchWeather();
    }
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentLocation!.latitude,
        currentLocation!.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          currentCity = place.locality ?? 'Unknown';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> fetchWeather() async {
    if (currentLocation == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${currentLocation!.latitude}&lon=${currentLocation!.longitude}&appid=$apiKey&units=metric'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherDescription = data['weather'][0]['description'];
          temperature = data['main']['temp'];
          windSpeed = data['wind']['speed'];
          humidity = data['main']['humidity'];
          pressure = data['main']['pressure'];
          visibility = data['visibility'] / 1000; // Convert to km
          windDirection = _getWindDirection(data['wind']['deg']);
          isLoading = false;
          _updateMarker();
        });
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      print('Error fetching weather: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getWindDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[(degrees ~/ 45) % 8];
  }

  void _updateMarker() {
    markers.clear();
    markers.add(
      Marker(
        width: 120.0,
        height: 120.0,
        point: currentLocation!,
        child: _buildMarkerWidget(),
      ),
    );
  }

  Widget _buildMarkerWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BoxedIcon(_getWeatherIcon(), size: 40, color: _getWeatherColor()),
          Text(
            '${temperature?.toStringAsFixed(1)}°C',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            weatherDescription ?? '',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon() {
    if (weatherDescription == null) return WeatherIcons.na;
    if (weatherDescription!.contains('rain')) return WeatherIcons.rain;
    if (weatherDescription!.contains('cloud')) return WeatherIcons.cloudy;
    if (weatherDescription!.contains('sun') || weatherDescription!.contains('clear')) return WeatherIcons.day_sunny;
    if (weatherDescription!.contains('storm')) return WeatherIcons.thunderstorm;
    if (weatherDescription!.contains('snow')) return WeatherIcons.snow;
    return WeatherIcons.na;
  }

  Color _getWeatherColor() {
    if (temperature == null) return Colors.grey;
    if (temperature! > 30) return Colors.red;
    if (temperature! > 20) return Colors.orange;
    if (temperature! > 10) return Colors.green;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentLocation ?? const LatLng(12.9716, 77.5946),
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  right: 16,
                  child: _buildLocationBar(),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildWeatherInfoCard(),
                ),
              ],
            ),
    );
  }

  Widget _buildLocationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              currentCity ?? 'Loading location...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: fetchWeather,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfoCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${temperature?.toStringAsFixed(1)}°C',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              weatherDescription ?? '',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWeatherInfoItem(WeatherIcons.humidity, 'Humidity', '$humidity%'),
                _buildWeatherInfoItem(WeatherIcons.strong_wind, 'Wind', '${windSpeed?.toStringAsFixed(1)} m/s'),
                _buildWeatherInfoItem(WeatherIcons.barometer, 'Pressure', '$pressure hPa'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        BoxedIcon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}