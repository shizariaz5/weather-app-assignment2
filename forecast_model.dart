class ForecastData {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String iconCode;

  ForecastData({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.iconCode,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    return ForecastData(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      minTemp: (json['main']['temp_min']).toDouble(),
      maxTemp: (json['main']['temp_max']).toDouble(),
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}

class ForecastResponse {
  final List<ForecastData> forecastList;

  ForecastResponse({required this.forecastList});

  factory ForecastResponse.fromJson(Map<String, dynamic> json) {
    List<ForecastData> forecasts = [];

    // Group forecasts by date and take one reading per day
    Map<String, ForecastData> dailyForecasts = {};

    for (var item in json['list']) {
      final forecast = ForecastData.fromJson(item);
      final dateKey = '${forecast.date.year}-${forecast.date.month}-${forecast.date.day}';

      if (!dailyForecasts.containsKey(dateKey)) {
        dailyForecasts[dateKey] = forecast;
      } else {
        // Update min/max temperatures
        final existing = dailyForecasts[dateKey]!;
        if (forecast.minTemp < existing.minTemp) {
          dailyForecasts[dateKey] = ForecastData(
            date: existing.date,
            minTemp: forecast.minTemp,
            maxTemp: existing.maxTemp,
            description: existing.description,
            iconCode: existing.iconCode,
          );
        }
        if (forecast.maxTemp > existing.maxTemp) {
          dailyForecasts[dateKey] = ForecastData(
            date: existing.date,
            minTemp: existing.minTemp,
            maxTemp: forecast.maxTemp,
            description: existing.description,
            iconCode: existing.iconCode,
          );
        }
      }
    }

    // Take first 3 days
    return ForecastResponse(
      forecastList: dailyForecasts.values.take(3).toList(),
    );
  }
}