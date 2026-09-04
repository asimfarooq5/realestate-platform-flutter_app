import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? password,
    String? name,
    String? phone,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    @Default('BUYER') String role,
    String? image,
    @JsonKey(name: 'email_verified') DateTime? emailVerified,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'agent_profile') AgentProfile? agentProfile,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class AgentProfile with _$AgentProfile {
  const factory AgentProfile({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'company_name') String? companyName,
    @JsonKey(name: 'license_number') String? licenseNumber,
    String? bio,
    String? experience,
    List<String>? specialties,
    List<String>? languages,
    @Default(false) bool verified,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _AgentProfile;

  factory AgentProfile.fromJson(Map<String, dynamic> json) =>
      _$AgentProfileFromJson(json);
}

@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') required String tokenType,
    required User user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
abstract class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    String? name,
    String? phone,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    @Default('BUYER') String role,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}
