/// Category → subtype taxonomy, and category → backend `type` enum mapping,
/// straight from the product wireframes ("Homes" / "Plot" / "Commercial",
/// each with their own subtype list; renting switches the price label to
/// "Monthly rent").
enum PropertyCategory { homes, plot, commercial }

extension PropertyCategoryX on PropertyCategory {
  String get label => switch (this) {
        PropertyCategory.homes => 'Homes',
        PropertyCategory.plot => 'Plot',
        PropertyCategory.commercial => 'Commercial',
      };

  /// The backend `type` enum value to submit — the specific subtype string
  /// carries the finer detail (e.g. "Upper Portion") separately.
  String get backendType => switch (this) {
        PropertyCategory.homes => 'HOUSE',
        PropertyCategory.plot => 'PLOT',
        PropertyCategory.commercial => 'COMMERCIAL',
      };

  List<String> get subtypes => switch (this) {
        PropertyCategory.homes => const [
            'House',
            'Flat',
            'Upper Portion',
            'Lower Portion',
            'Farm House',
            'Penthouse',
            'Room',
            'Apartment',
            'Other',
          ],
        PropertyCategory.plot => const [
            'Residential Plot',
            'Commercial Plot',
            'Agricultural Land',
            'Industrial Land',
            'Plot File',
            'Plot Form',
            'Other',
          ],
        PropertyCategory.commercial => const [
            'Office',
            'Shop',
            'Warehouse',
            'Factory',
            'Building',
            'Other',
          ],
      };

  /// Only Homes subtypes have bedrooms/bathrooms worth asking about.
  bool get hasRoomCounts => this == PropertyCategory.homes;
}

const sizeUnits = ['sqft', 'sqyd', 'sqm', 'marla', 'kanal'];

const mainFeatureOptions = [
  'Central Air Conditioning',
  'Central Heating',
  'Waste Disposal',
  'Furnished',
  'Internet',
  'Cable',
  'Swimming Pool',
  'Jacuzzi',
  'Lawn',
];

const roomOptions = [
  'Servant Quarters',
  'Store Rooms',
  'Drawing Room',
  'Dining Room',
  'Study Room',
  'Prayer Room',
  'Powder Room',
  'Gym',
  'Lounge',
  'Laundry Room',
  'Barbeque Area',
];

const nearbyOptions = [
  'Schools',
  'Hospitals',
  'Shopping Malls',
  'Restaurants',
  'Public Transport Service',
];

const communityOptions = [
  'Community Lawn / Garden',
  'Community Swimming Pool',
  'Community Gym',
  'Medical Centre',
  'Day Care Centre',
  'Kids Play Area',
  'Mosque',
];
