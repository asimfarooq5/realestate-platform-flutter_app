/// Feature flags/credentials sourced from build-time environment variables
/// (`--dart-define=KEY=value`), so nothing here needs to be hardcoded or
/// committed. Values default to empty, which the UI treats as "not
/// configured yet" rather than crashing.
class AppConfig {
  static const String googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

  static bool get isGoogleSignInConfigured => googleClientId.isNotEmpty;
}
