class ApiConstants {
  // Override at build time with:
  //   flutter build apk --dart-define=API_BASE_URL=https://api.yourdomain.com
  // Default: the production backend on the VPS. For the Android emulator
  // against a locally-run backend instead, use --dart-define=API_BASE_URL=http://10.0.2.2:8000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://100.27.229.125:8000',
  );
  static const String apiVersion = '/api/v1';

  // Auth
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';

  // Properties
  static const String properties = '$apiVersion/properties/';
  static const String cities = '$apiVersion/properties/cities/list';
  static const String areas = '$apiVersion/properties/cities/{cityId}/areas';

  // User account
  static const String me = '$apiVersion/users/me';
  static const String myFavorites = '$apiVersion/users/me/favorites';
  static const String myProperties = '$apiVersion/users/me/properties';
  static const String myInquiries = '$apiVersion/users/me/inquiries';

  // Projects
  static const String projects = '$apiVersion/projects/';

  // Chat
  static const String conversations = '$apiVersion/conversations/';
  static const String startConversation = '$apiVersion/conversations/start';
  static const String communityPosts = '$apiVersion/community/posts';

  // Timeout
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}
