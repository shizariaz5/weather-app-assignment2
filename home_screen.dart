import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';
import '../widgets/current_weather_widget.dart';
import '../widgets/forecast_widget.dart';
import '../widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  WeatherData? _currentWeather;
  ForecastResponse? _forecast;
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentCity = '';
  String? _lastSearchedCity;
  DateTime? _lastSearchTime;

  @override
  void initState() {
    super.initState();
    _loadLastCity();
  }

  Future<void> _loadLastCity() async {
    final lastCity = await StorageService.getLastCity();
    final lastTime = await StorageService.getLastSearchTime();

    setState(() {
      _lastSearchedCity = lastCity;
      _lastSearchTime = lastTime;
    });

    if (lastCity != null && lastCity.isNotEmpty) {
      _searchController.text = lastCity;
      _fetchWeatherData(lastCity);
    }
  }

  Future<void> _fetchWeatherData(String cityName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weather = await WeatherService.getCurrentWeather(cityName);
      final forecast = await WeatherService.getForecast(cityName);

      setState(() {
        _currentWeather = weather;
        _forecast = forecast;
        _currentCity = cityName;
        _lastSearchedCity = cityName;
        _lastSearchTime = DateTime.now();
      });

      await StorageService.saveLastCity(cityName);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _currentWeather = null;
        _forecast = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchWeather() {
    final cityName = _searchController.text.trim();
    if (cityName.isNotEmpty) {
      _fetchWeatherData(cityName);
    }
  }

  void _clearHistory() async {
    await StorageService.clearHistory();
    setState(() {
      _lastSearchedCity = null;
      _lastSearchTime = null;
      _searchController.clear();
      _currentWeather = null;
      _forecast = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F0),
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFFF7675),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_lastSearchedCity != null)
            IconButton(
              icon: Icon(Icons.history, color: Colors.white),
              onPressed: _showStorageInfo,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            _buildSearchBar(),
            if (_lastSearchedCity != null && (_currentWeather == null || _isLoading))
              _buildLastSearchInfo(),
            const SizedBox(height: 8),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Local Storage Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last City: ${_lastSearchedCity ?? 'None'}'),
            if (_lastSearchTime != null)
              Text('Last Search: ${_lastSearchTime!.toString()}'),
            SizedBox(height: 10),
            Text(
              'This data is stored locally on your device and will persist even when you close the app.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _clearHistory,
            child: Text('Clear History', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildLastSearchInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.history, size: 16, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing last searched: $_lastSearchedCity',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Color(0xFFFF7675)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search city...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onSubmitted: (_) => _searchWeather(),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFF7675),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 20),
              onPressed: _searchWeather,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (_currentWeather == null || _forecast == null) {
      return _buildWelcomeWidget();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          CurrentWeatherWidget(weatherData: _currentWeather!),
          ForecastWidget(forecastList: _forecast!.forecastList),
        ],
      ),
    );
  }

  Widget _buildWelcomeWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wb_sunny,
              size: 64,
              color: Color(0xFFFF7675),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Weather App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF7675),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Search for a city to see current weather\nand 3-day forecast',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (_lastSearchedCity != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last searched city:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          _lastSearchedCity!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF7675),
                          ),
                        ),
                        if (_lastSearchTime != null)
                          Text(
                            'on ${_lastSearchTime!.toString().split(' ')[0]}',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  _searchController.text = _lastSearchedCity!;
                  _searchWeather();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFFFF7675),
                  side: BorderSide(color: Color(0xFFFF7675)),
                ),
                child: Text('Load Last City'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF7675),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: _searchWeather,
              child: const Text('Search New City'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFFF7675),
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF7675),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (_lastSearchedCity != null) ...[
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  _searchController.text = _lastSearchedCity!;
                  _searchWeather();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFFFF7675),
                  side: BorderSide(color: Color(0xFFFF7675)),
                ),
                child: Text('Try Last City: $_lastSearchedCity'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF7675),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: _searchWeather,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}