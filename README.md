# weather-app-assignment2
Flutter Weather Application 

A Flutter weather application that displays current weather and 3-day forecast with local storage functionality.

## 📱Features

- Search weather by city name
- Current weather: temperature, description, humidity, wind speed, weather icons
- 3-day forecast with min/max temperatures and descriptions
- Local storage- automatically saves and loads last searched city
- Beautiful UI with sunset orange theme
- Error handling for city not found and network issues
- Loading states with smooth animations
- Cross-platform - works on Android, iOS, Web, and Desktop

## Technologies Used

- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **OpenWeatherMap API** - Weather data
- **SharedPreferences** - Local storage
- **HTTP** - API calls
- **Material Design** - UI components

## Local Storage Feature

The app implements local storage using **SharedPreferences**:
- **Automatically saves** the last searched city
- **Loads on app startup** - no manual intervention needed
- **Persists data** between app sessions
- **Visual indicators** show when using stored data

### How to Test Local Storage:
1. Search for any city (e.g., "London")
2. Close the app completely
3. Reopen the app - it automatically loads London's weather
4. The search bar is pre-filled with the last city

## ⚙️ Setup & Run Instructions

### Prerequisites
- Flutter SDK installed (version 3.0+)
- Android Studio/VSCode with Flutter extension
- OpenWeatherMap API key

### Step 1: Get API Key
1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Verify your email
4. Get your API key from the dashboard

### Step 2: Configure API Key
1. Open `assets/.env` file
2. Replace `your_api_key_here` with your actual API key:

# For Chrome (Web)
flutter run -d chrome

# For Android
flutter run -d android

# For iOS
flutter run -d ios
