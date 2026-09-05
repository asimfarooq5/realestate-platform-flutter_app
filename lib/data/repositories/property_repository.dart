import 'package:malkiyat_app/data/datasources/remote/api_client.dart';
import 'package:malkiyat_app/data/models/property_model.dart';

class PropertyRepository {
  final ApiClient _apiClient;

  PropertyRepository(this._apiClient);

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
    return _apiClient.getProperties(
      page: page,
      limit: limit,
      cityId: cityId,
      areaId: areaId,
      type: type,
      status: status,
      minPrice: minPrice,
      maxPrice: maxPrice,
      bedrooms: bedrooms,
      search: search,
      featured: featured,
      agencyOnly: agencyOnly,
      nearLat: nearLat,
      nearLng: nearLng,
    );
  }

  Future<Property> getPropertyBySlug(String slug) async {
    return _apiClient.getPropertyBySlug(slug);
  }

  Future<Property> createProperty(Property property) async {
    return _apiClient.createProperty(property);
  }

  Future<Property> updateProperty(String id, Property property) async {
    return _apiClient.updateProperty(id, property);
  }

  Future<void> deleteProperty(String id) async {
    return _apiClient.deleteProperty(id);
  }

  Future<List<City>> getCities() async {
    return _apiClient.getCities();
  }

  Future<List<Area>> getAreas(String cityId) async {
    return _apiClient.getAreas(cityId);
  }

  Future<Inquiry> createInquiry(String propertyId, Inquiry inquiry) async {
    return _apiClient.createInquiry(propertyId, inquiry);
  }

  Future<void> addFavorite(String propertyId) async {
    return _apiClient.addFavorite(propertyId);
  }

  Future<void> removeFavorite(String propertyId) async {
    return _apiClient.removeFavorite(propertyId);
  }

  Future<bool> isFavorite(String propertyId) async {
    return _apiClient.isFavorite(propertyId);
  }

  Future<List<Property>> getMyFavorites() async {
    return _apiClient.getMyFavorites();
  }

  Future<List<Inquiry>> getMyInquiries() async {
    return _apiClient.getMyInquiries();
  }

  Future<List<Property>> getMyProperties({bool? isDraft}) async {
    return _apiClient.getMyProperties(isDraft: isDraft);
  }

  Future<List<Project>> getProjects() async {
    return _apiClient.getProjects();
  }
}
