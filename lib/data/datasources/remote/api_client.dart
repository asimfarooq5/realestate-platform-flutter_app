import 'package:dio/dio.dart';
import 'package:malkiyat_app/core/constants/api_constants.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/data/models/user_model.dart';

class ApiClient {
  late Dio _dio;
  String? _authToken;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // Auth
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<User> register(RegisterRequest request) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: request.toJson(),
    );
    return User.fromJson(response.data);
  }

  // Properties
  Future<PropertyListResponse> getProperties({
    int page = 1,
    int limit = 12,
    String? cityId,
    String? areaId,
    String? type,
    String? status,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? search,
    bool? featured,
    double? nearLat,
    double? nearLng,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (cityId != null) 'city_id': cityId,
      if (areaId != null) 'area_id': areaId,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (bedrooms != null) 'bedrooms': bedrooms,
      if (search != null) 'search': search,
      if (featured != null) 'featured': featured,
      if (nearLat != null) 'near_lat': nearLat,
      if (nearLng != null) 'near_lng': nearLng,
    };

    final response = await _dio.get(
      ApiConstants.properties,
      queryParameters: queryParams,
    );
    return PropertyListResponse.fromJson(response.data);
  }

  Future<Property> getPropertyBySlug(String slug) async {
    final response = await _dio.get('${ApiConstants.properties}$slug');
    return Property.fromJson(response.data);
  }

  Future<Property> createProperty(Property property) async {
    final response = await _dio.post(
      ApiConstants.properties,
      data: property.toJson(),
    );
    return Property.fromJson(response.data);
  }

  Future<Property> updateProperty(String id, Property property) async {
    final response = await _dio.put(
      '${ApiConstants.properties}$id',
      data: property.toJson(),
    );
    return Property.fromJson(response.data);
  }

  Future<void> deleteProperty(String id) async {
    await _dio.delete('${ApiConstants.properties}$id');
  }

  Future<Inquiry> createInquiry(String propertyId, Inquiry inquiry) async {
    final response = await _dio.post(
      '${ApiConstants.properties}$propertyId/inquiry',
      data: inquiry.toJson(),
    );
    return Inquiry.fromJson(response.data);
  }

  // Cities
  Future<List<City>> getCities() async {
    final response = await _dio.get(ApiConstants.cities);
    return (response.data as List)
        .map((json) => City.fromJson(json))
        .toList();
  }

  Future<List<Area>> getAreas(String cityId) async {
    final response = await _dio.get(
      ApiConstants.areas.replaceAll('{cityId}', cityId),
    );
    return (response.data as List)
        .map((json) => Area.fromJson(json))
        .toList();
  }

  // Favorites
  Future<void> addFavorite(String propertyId) async {
    await _dio.post('${ApiConstants.properties}$propertyId/favorite');
  }

  Future<void> removeFavorite(String propertyId) async {
    await _dio.delete('${ApiConstants.properties}$propertyId/favorite');
  }

  Future<bool> isFavorite(String propertyId) async {
    final response = await _dio
        .get('${ApiConstants.properties}$propertyId/favorite/status');
    return response.data == true;
  }

  Future<List<Property>> getMyFavorites() async {
    final response = await _dio.get(ApiConstants.myFavorites);
    return (response.data as List)
        .map((json) => Property.fromJson(json))
        .toList();
  }
}
