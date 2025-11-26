import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _lastCityKey = 'last_city';
  static const String _lastSearchTimeKey = 'last_search_time';

  static Future<void> saveLastCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, cityName);
    await prefs.setString(_lastSearchTimeKey, DateTime.now().toIso8601String());
  }

  static Future<String?> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCityKey);
  }

  static Future<DateTime?> getLastSearchTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_lastSearchTimeKey);
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastCityKey);
    await prefs.remove(_lastSearchTimeKey);
  }
}