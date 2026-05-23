# Zameen Real Estate App - Flutter

A professional, cross-platform real estate mobile application built with Flutter.

## Features

- **Cross-Platform**: iOS, Android, Web, Desktop support
- **Modern UI**: Material Design 3 with custom theme
- **State Management**: BLoC pattern for predictable state
- **API Integration**: RESTful API with Dio
- **Offline Support**: Caching with shared preferences
- **Maps Integration**: Google Maps for property locations
- **Image Caching**: Efficient image loading with cached_network_image

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: flutter_bloc
- **HTTP Client**: Dio + Retrofit
- **Dependency Injection**: GetIt
- **Code Generation**: Freezed + JSON Serializable
- **Image Handling**: cached_network_image
- **Maps**: google_maps_flutter
- **Animations**: Carousel Slider, Smooth Page Indicator

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants
│   ├── theme/           # App themes
│   └── di/              # Dependency injection
├── data/
│   ├── models/          # Data models
│   ├── datasources/     # API clients
│   └── repositories/    # Data repositories
├── presentation/
│   ├── blocs/           # BLoC state management
│   ├── screens/         # UI screens
│   └── widgets/         # Reusable widgets
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 2.17+
- Android Studio / Xcode

### Installation

1. Clone the repository:
```bash
git clone <repo-url>
cd flutter_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

### Configuration

Update `lib/core/constants/api_constants.dart` with your API URL:

```dart
static const String baseUrl = 'http://your-api-url:8000';
```

## Screens

- **Splash**: Animated app launch
- **Home**: Featured properties, cities, property types
- **Search**: Advanced search with filters
- **Property Detail**: Full property information with image carousel
- **Favorites**: Saved properties
- **Profile**: User profile and settings
- **Login/Register**: Authentication screens

## Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Features

- Property search and filtering
- Property detail view with image gallery
- City and area browsing
- User authentication
- Favorites management
- Contact agents directly
- Responsive design for all screen sizes
# realestate-platform-flutter_app
