import 'package:dio/dio.dart';
import 'package:malkiyat_app/core/constants/api_constants.dart';
import 'package:malkiyat_app/data/models/chat_model.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/data/models/user_model.dart';

class ApiClient {
  late Dio _dio;
  String? _authToken;

  /// Fired when a request comes back 401 with a token attached — the
  /// session is no longer valid (expired/revoked), so callers should treat
  /// this as a forced sign-out rather than a one-off request failure.
  void Function()? onUnauthorized;

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
          final path = error.requestOptions.path;
          final isAuthEndpoint = path == ApiConstants.login || path == ApiConstants.register;
          if (error.response?.statusCode == 401 && !isAuthEndpoint) {
            _authToken = null;
            onUnauthorized?.call();
          }
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

  Future<User> updateProfile({String? name, String? phone}) async {
    final response = await _dio.put(
      ApiConstants.me,
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      },
    );
    return User.fromJson(response.data);
  }

  Future<void> deactivateAccount() async {
    await _dio.post('${ApiConstants.me}/deactivate');
  }

  Future<List<Property>> getMyProperties({bool? isDraft}) async {
    final response = await _dio.get(
      ApiConstants.myProperties,
      queryParameters: {if (isDraft != null) 'is_draft': isDraft},
    );
    return (response.data as List)
        .map((json) => Property.fromJson(json))
        .toList();
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
    bool? agencyOnly,
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
      if (agencyOnly != null) 'agency_only': agencyOnly,
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

  Future<List<Inquiry>> getMyInquiries() async {
    final response = await _dio.get(ApiConstants.myInquiries);
    return (response.data as List)
        .map((json) => Inquiry.fromJson(json))
        .toList();
  }

  // Chat
  Future<List<Conversation>> getConversations() async {
    final response = await _dio.get(ApiConstants.conversations);
    return (response.data as List)
        .map((json) => Conversation.fromJson(json))
        .toList();
  }

  Future<Conversation> startConversation({
    required String otherUserId,
    String? propertyId,
    required String message,
  }) async {
    final response = await _dio.post(
      ApiConstants.startConversation,
      data: {
        'other_user_id': otherUserId,
        if (propertyId != null) 'property_id': propertyId,
        'message': message,
      },
    );
    return Conversation.fromJson(response.data);
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final response = await _dio.get('${ApiConstants.conversations}$conversationId/messages');
    return (response.data as List)
        .map((json) => ChatMessage.fromJson(json))
        .toList();
  }

  Future<ChatMessage> sendChatMessage(String conversationId, String text) async {
    final response = await _dio.post(
      '${ApiConstants.conversations}$conversationId/messages',
      data: {'text': text},
    );
    return ChatMessage.fromJson(response.data);
  }

  Future<List<Project>> getProjects() async {
    final response = await _dio.get(ApiConstants.projects);
    return (response.data as List)
        .map((json) => Project.fromJson(json))
        .toList();
  }

  Future<List<CommunityPost>> getCommunityPosts() async {
    final response = await _dio.get(ApiConstants.communityPosts);
    return (response.data as List)
        .map((json) => CommunityPost.fromJson(json))
        .toList();
  }
}
