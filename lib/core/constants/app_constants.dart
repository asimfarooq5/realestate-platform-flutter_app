class AppConstants {
  // App Info
  static const String appName = 'Malkiyat';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String favoritesKey = 'favorites';
  
  // Pagination
  static const int defaultPageSize = 12;
  
  // Property Types
  static const List<String> propertyTypes = [
    'HOUSE',
    'APARTMENT',
    'PLOT',
    'COMMERCIAL',
    'VILLA',
    'FARM_HOUSE',
  ];
  
  // Cities (Pakistan)
  static const List<Map<String, String>> cities = [
    {'name': 'Karachi', 'slug': 'karachi'},
    {'name': 'Lahore', 'slug': 'lahore'},
    {'name': 'Islamabad', 'slug': 'islamabad'},
    {'name': 'Rawalpindi', 'slug': 'rawalpindi'},
    {'name': 'Faisalabad', 'slug': 'faisalabad'},
    {'name': 'Peshawar', 'slug': 'peshawar'},
    {'name': 'Multan', 'slug': 'multan'},
    {'name': 'Quetta', 'slug': 'quetta'},
  ];
}
