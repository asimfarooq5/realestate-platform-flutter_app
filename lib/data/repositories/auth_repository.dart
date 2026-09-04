import 'package:malkiyat_app/data/datasources/remote/api_client.dart';
import 'package:malkiyat_app/data/models/user_model.dart';
import 'package:malkiyat_app/data/services/token_storage.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository(this._apiClient, this._tokenStorage);

  Future<AuthResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _apiClient.login(request);
    await _tokenStorage.saveSession(response.accessToken, response.user);
    return response;
  }

  Future<User> register({
    required String email,
    required String password,
    String? name,
    String? phone,
    String role = 'BUYER',
  }) async {
    final request = RegisterRequest(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
    );
    return _apiClient.register(request);
  }

  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  Future<void> clearAuthToken() async {
    _apiClient.clearAuthToken();
    await _tokenStorage.clear();
  }

  Future<void> restoreSession() async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      _apiClient.setAuthToken(token);
    }
  }

  Future<User?> getStoredUser() => _tokenStorage.getUser();
  Future<String?> getStoredToken() => _tokenStorage.getToken();
}
