part of 'property_bloc.dart';

abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

class LoadProperties extends PropertyEvent {
  final int page;
  final int limit;
  final String? cityId;
  final String? areaId;
  final String? type;
  final String? status;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final bool? featured;
  final String? search;

  const LoadProperties({
    this.page = 1,
    this.limit = 12,
    this.cityId,
    this.areaId,
    this.type,
    this.status,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.featured,
    this.search,
  });

  @override
  List<Object?> get props => [
        page,
        limit,
        cityId,
        areaId,
        type,
        status,
        minPrice,
        maxPrice,
        bedrooms,
        featured,
        search,
      ];
}

class LoadPropertyDetail extends PropertyEvent {
  final String slug;

  const LoadPropertyDetail(this.slug);

  @override
  List<Object?> get props => [slug];
}

class LoadCities extends PropertyEvent {}

class LoadAreas extends PropertyEvent {
  final String cityId;

  const LoadAreas(this.cityId);

  @override
  List<Object?> get props => [cityId];
}

class SearchProperties extends PropertyEvent {
  final String query;

  const SearchProperties(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadFavorites extends PropertyEvent {}

class AddFavorite extends PropertyEvent {
  final String propertyId;

  const AddFavorite(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class RemoveFavorite extends PropertyEvent {
  final String propertyId;

  const RemoveFavorite(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class ToggleFavorite extends PropertyEvent {
  final String propertyId;

  const ToggleFavorite(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class CheckFavoriteStatus extends PropertyEvent {
  final String propertyId;

  const CheckFavoriteStatus(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}