Weather App - Flutter Developer Technical Test
Overview
This is a Flutter-based weather application developed as part of a technical test. The app allows users to search for real-time weather data by city name, displaying key information such as temperature (in Celsius and Fahrenheit), weather description, humidity, wind speed, and a weather icon. It features a clean, responsive UI with error handling and a loading indicator. Bonus features include local storage for the last searched city and system-based dark mode support.
Approach

API: Utilized the OpenWeatherMap API (free tier) to fetch real-time weather data.
Architecture: Followed a clean architecture approach with separation of concerns (data, domain, presentation layers).
State Management: Used Provider for managing state, ensuring efficient UI updates.
Local Storage: Implemented SharedPreferences to save the last searched city and load its weather on app launch.
UI Design: Created a minimal, aesthetic UI with proper alignment, padding, and support for dark mode using Flutter's ThemeData.
Error Handling: Added user-friendly error messages for invalid city names or network issues.
Loading State: Included a loading indicator during API calls.
Assumptions:
OpenWeatherMap API key is required and should be added to the environment configuration.
Internet connection is available for API calls.
The app targets Android devices for the provided .apk.



Features

Search for weather by city name.
Display city name, temperature (°C/°F), weather description, icon, humidity, and wind speed.
Responsive UI with loading indicator and error messages.
Persist last searched city using SharedPreferences.
Dark mode support based on system settings.

Installation and Setup

Prerequisites:

Flutter SDK (version 3.32.0 or higher)
Dart (version 3.8.0 or higher)
Android Studio or VS Code with Flutter plugin
OpenWeatherMap API key (sign up at OpenWeatherMap to get a free key)


Steps to Run:
# Clone the repository
git clone https://github.com/MuhammadAhmadSharif/Weather-App.git

# Navigate to the project directory
cd weather-app

# Install dependencies
flutter pub get

# Run the app
flutter run


Build APK:
flutter build apk --release

The generated APK will be located at build/app/outputs/flutter-apk/app-release.apk.

Dependencies

http: For making API requests.
provider: For state management.
shared_preferences: For local storage.
flutter_dotenv: For managing environment variables.

Running the App

Ensure an Android emulator or physical device is connected.
Add your OpenWeatherMap API key to the .env file.
Run flutter run to launch the app.
On first launch, the app loads the weather for the last searched city (if available) or prompts for a city name.
Search for a city using the input field, and the app will display the weather details.

Notes

The app assumes an active internet connection for API calls.
Dark mode adapts to the system's theme settings.
The .apk is optimized for Android and tested on API level 34.
Error messages are displayed for invalid city names or failed API requests.

Future Improvements

Add unit and widget tests for better reliability.
Implement caching for offline access to recent weather data.
Support multiple languages for weather descriptions.

