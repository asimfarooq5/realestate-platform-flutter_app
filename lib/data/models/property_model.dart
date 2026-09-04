import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_model.freezed.dart';
part 'property_model.g.dart';

@freezed
abstract class Property with _$Property {
  const factory Property({
    required String id,
    required String title,
    required String slug,
    required String description,
    required String type,
    required String status,
    @JsonKey(name: 'listing_status') required String listingStatus,
    @JsonKey(name: 'city_id') required String cityId,
    @JsonKey(name: 'area_id') required String areaId,
    required String address,
    required double price,
    @JsonKey(name: 'price_unit') @Default('PKR') String priceUnit,
    int? bedrooms,
    int? bathrooms,
    int? kitchens,
    @JsonKey(name: 'area_size') required double areaSize,
    @JsonKey(name: 'area_unit') @Default('sqft') String areaUnit,
    int? floor,
    @JsonKey(name: 'total_floors') int? totalFloors,
    @JsonKey(name: 'year_built') int? yearBuilt,
    @Default(false) bool furnished,
    List<String>? amenities,
    @JsonKey(name: 'video_url') String? videoUrl,
    @JsonKey(name: 'virtual_tour_url') String? virtualTourUrl,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    @JsonKey(name: 'contact_email') String? contactEmail,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'owner_id') required String ownerId,
    @Default(0) int views,
    @Default(false) bool featured,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    List<PropertyImage>? images,
    City? city,
    Area? area,
  }) = _Property;

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);
}

@freezed
abstract class PropertyImage with _$PropertyImage {
  const factory PropertyImage({
    required String id,
    @JsonKey(name: 'property_id') required String propertyId,
    required String url,
    String? caption,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    @Default(0) int order,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PropertyImage;

  factory PropertyImage.fromJson(Map<String, dynamic> json) =>
      _$PropertyImageFromJson(json);
}

@freezed
abstract class City with _$City {
  const factory City({
    required String id,
    required String name,
    required String slug,
    String? province,
    String? description,
    String? image,
    @Default(false) bool featured,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'property_count') @Default(0) int propertyCount,
  }) = _City;

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
}

@freezed
abstract class Area with _$Area {
  const factory Area({
    required String id,
    required String name,
    required String slug,
    @JsonKey(name: 'city_id') required String cityId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'property_count') @Default(0) int propertyCount,
  }) = _Area;

  factory Area.fromJson(Map<String, dynamic> json) => _$AreaFromJson(json);
}

@freezed
abstract class PropertyListResponse with _$PropertyListResponse {
  const factory PropertyListResponse({
    required List<Property> properties,
    required int total,
    required int page,
    required int limit,
    required int pages,
  }) = _PropertyListResponse;

  factory PropertyListResponse.fromJson(Map<String, dynamic> json) =>
      _$PropertyListResponseFromJson(json);
}

@freezed
abstract class Inquiry with _$Inquiry {
  const factory Inquiry({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'property_id') required String propertyId,
    required String name,
    required String email,
    String? phone,
    required String message,
    @Default('PENDING') String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Inquiry;

  factory Inquiry.fromJson(Map<String, dynamic> json) =>
      _$InquiryFromJson(json);
}
