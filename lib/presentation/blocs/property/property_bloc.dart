import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/data/repositories/property_repository.dart';

part 'property_event.dart';
part 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final PropertyRepository _propertyRepository;
  final List<Property> _allProperties = [];

  PropertyBloc(this._propertyRepository) : super(PropertyInitial()) {
    on<LoadProperties>(_onLoadProperties);
    on<LoadPropertyDetail>(_onLoadPropertyDetail);
    on<LoadCities>(_onLoadCities);
    on<LoadAreas>(_onLoadAreas);
    on<SearchProperties>(_onSearchProperties);
    on<LoadFavorites>(_onLoadFavorites);
    on<LoadInquiries>(_onLoadInquiries);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
    on<ToggleFavorite>(_onToggleFavorite);
    on<CheckFavoriteStatus>(_onCheckFavoriteStatus);
  }

  Future<void> _onLoadProperties(
    LoadProperties event,
    Emitter<PropertyState> emit,
  ) async {
    if (event.page == 1) {
      _allProperties.clear();
      emit(PropertyLoading());
    }
    try {
      final response = await _propertyRepository.getProperties(
        page: event.page,
        limit: event.limit,
        cityId: event.cityId,
        areaId: event.areaId,
        type: event.type,
        status: event.status,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        bedrooms: event.bedrooms,
        featured: event.featured,
        agencyOnly: event.agencyOnly,
        search: event.search,
        nearLat: event.nearLat,
        nearLng: event.nearLng,
      );
      _allProperties.addAll(response.properties);
      emit(PropertiesLoaded(
        properties: List.from(_allProperties),
        total: response.total,
        page: response.page,
        pages: response.pages,
      ));
    } catch (e) {
      emit(PropertyError(_friendlyError(e)));
    }
  }

  Future<void> _onLoadPropertyDetail(
    LoadPropertyDetail event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    try {
      final property = await _propertyRepository.getPropertyBySlug(event.slug);
      emit(PropertyDetailLoaded(property));
    } catch (e) {
      emit(PropertyError(_friendlyError(e)));
    }
  }

  Future<void> _onLoadCities(
    LoadCities event,
    Emitter<PropertyState> emit,
  ) async {
    try {
      final cities = await _propertyRepository.getCities();
      emit(CitiesLoaded(cities));
    } catch (e) {
      emit(PropertyError(_friendlyError(e)));
    }
  }

  Future<void> _onLoadAreas(
    LoadAreas event,
    Emitter<PropertyState> emit,
  ) async {
    try {
      final areas = await _propertyRepository.getAreas(event.cityId);
      emit(AreasLoaded(areas));
    } catch (e) {
      emit(PropertyError(_friendlyError(e)));
    }
  }

  Future<void> _onSearchProperties(
    SearchProperties event,
    Emitter<PropertyState> emit,
  ) async {
    _allProperties.clear();
    emit(PropertyLoading());
    try {
      final response = await _propertyRepository.getProperties(
        search: event.query,
        page: 1,
        limit: 20,
      );
      _allProperties.addAll(response.properties);
      emit(PropertiesLoaded(
        properties: List.from(_allProperties),
        total: response.total,
        page: response.page,
        pages: response.pages,
      ));
    } catch (e) {
      emit(PropertyError(_friendlyError(e)));
    }
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<PropertyState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final favorites = await _propertyRepository.getMyFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(PropertyError(_friendlyError(e)));
    }
  }

  Future<void> _onLoadInquiries(
    LoadInquiries event,
    Emitter<PropertyState> emit,
  ) async {
    emit(InquiriesLoading());
    try {
      final inquiries = await _propertyRepository.getMyInquiries();
      emit(InquiriesLoaded(inquiries));
    } catch (e) {
      emit(PropertyError(_friendlyError(e)));
    }
  }

  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<PropertyState> emit,
  ) async {
    try {
      await _propertyRepository.addFavorite(event.propertyId);
      emit(FavoriteToggled(event.propertyId, true));
    } catch (e) {
      emit(PropertyError(_friendlyError(e)));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<PropertyState> emit,
  ) async {
    try {
      await _propertyRepository.removeFavorite(event.propertyId);
      emit(FavoriteToggled(event.propertyId, false));
    } catch (e) {
      emit(PropertyError(_friendlyError(e)));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<PropertyState> emit,
  ) async {
    try {
      final current = await _propertyRepository.isFavorite(event.propertyId);
      if (current) {
        await _propertyRepository.removeFavorite(event.propertyId);
      } else {
        await _propertyRepository.addFavorite(event.propertyId);
      }
      emit(FavoriteToggled(event.propertyId, !current));
    } catch (e) {
      emit(PropertyError(_friendlyError(e)));
    }
  }

  Future<void> _onCheckFavoriteStatus(
    CheckFavoriteStatus event,
    Emitter<PropertyState> emit,
  ) async {
    try {
      final isFav = await _propertyRepository.isFavorite(event.propertyId);
      emit(FavoriteStatusLoaded(event.propertyId, isFav));
    } catch (e) {
      emit(FavoriteStatusLoaded(event.propertyId, false));
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('401')) {
      return 'Please sign in to continue';
    }
    if (msg.contains('SocketException') || msg.contains('Connection failed') || msg.contains('Connection refused')) {
      return 'Could not connect to the server. Check your internet connection.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> sendInquiry(String propertyId, Inquiry inquiry) async {
    await _propertyRepository.createInquiry(propertyId, inquiry);
  }

  Future<Property> createProperty(Property property) async {
    return _propertyRepository.createProperty(property);
  }
}
