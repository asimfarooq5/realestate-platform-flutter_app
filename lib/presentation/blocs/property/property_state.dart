part of 'property_bloc.dart';

abstract class PropertyState extends Equatable {
  const PropertyState();

  @override
  List<Object?> get props => [];
}

class PropertyInitial extends PropertyState {}

class PropertyLoading extends PropertyState {}

class PropertiesLoaded extends PropertyState {
  final List<Property> properties;
  final int total;
  final int page;
  final int pages;

  const PropertiesLoaded({
    required this.properties,
    required this.total,
    required this.page,
    required this.pages,
  });

  @override
  List<Object?> get props => [properties, total, page, pages];
}

class PropertyDetailLoaded extends PropertyState {
  final Property property;

  const PropertyDetailLoaded(this.property);

  @override
  List<Object?> get props => [property];
}

class CitiesLoaded extends PropertyState {
  final List<City> cities;

  const CitiesLoaded(this.cities);

  @override
  List<Object?> get props => [cities];
}

class AreasLoaded extends PropertyState {
  final List<Area> areas;

  const AreasLoaded(this.areas);

  @override
  List<Object?> get props => [areas];
}

class PropertyError extends PropertyState {
  final String message;

  const PropertyError(this.message);

  @override
  List<Object?> get props => [message];
}

class FavoritesLoading extends PropertyState {}

class FavoritesLoaded extends PropertyState {
  final List<Property> properties;

  const FavoritesLoaded(this.properties);

  @override
  List<Object?> get props => [properties];
}

class FavoriteStatusLoaded extends PropertyState {
  final String propertyId;
  final bool isFavorite;

  const FavoriteStatusLoaded(this.propertyId, this.isFavorite);

  @override
  List<Object?> get props => [propertyId, isFavorite];
}

class FavoriteToggled extends PropertyState {
  final String propertyId;
  final bool isFavorite;

  const FavoriteToggled(this.propertyId, this.isFavorite);

  @override
  List<Object?> get props => [propertyId, isFavorite];
}

class InquiriesLoading extends PropertyState {}

class InquiriesLoaded extends PropertyState {
  final List<Inquiry> inquiries;

  const InquiriesLoaded(this.inquiries);

  @override
  List<Object?> get props => [inquiries];
}
