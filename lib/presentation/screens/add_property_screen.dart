import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/constants/property_taxonomy.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/screens/property_features_screen.dart';

/// "Post an Ad" — follows the wireframe's field order: purpose, category
/// (with a subtype list specific to that category), location, size,
/// price + installments, bedrooms/bathrooms (Homes only), title,
/// description, a link out to the detailed Property Features screen,
/// images/video, contact info, then Save Draft / Post Ad.
class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();

  String _purpose = 'FOR_SALE';
  PropertyCategory _category = PropertyCategory.homes;
  String? _subtype;
  String _sizeUnit = 'sqft';
  bool _installments = false;
  int? _bedrooms;
  int? _bathrooms;
  City? _city;
  Area? _area;
  Map<String, dynamic>? _features;
  final List<String> _imageUrls = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(LoadCities());
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _emailController.text = authState.user.email;
      _contactController.text = authState.user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _imageUrlController.dispose();
    _videoUrlController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool isDraft}) async {
    if (!isDraft && !_formKey.currentState!.validate()) return;
    if (!isDraft && (_city == null || _area == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a city and area')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await context.read<PropertyBloc>().createProperty(Property(
            id: '',
            slug: '',
            title: _titleController.text.trim().isEmpty ? 'Untitled listing' : _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            type: _category.backendType,
            status: _purpose,
            listingStatus: 'PENDING',
            cityId: _city?.id ?? '',
            areaId: _area?.id ?? '',
            address: _addressController.text.trim(),
            price: double.tryParse(_priceController.text) ?? 0,
            areaSize: double.tryParse(_sizeController.text) ?? 0,
            areaUnit: _sizeUnit,
            bedrooms: _category.hasRoomCounts ? _bedrooms : null,
            bathrooms: _category.hasRoomCounts ? _bathrooms : null,
            furnished: false,
            subtype: _subtype,
            installmentsAvailable: _installments,
            isDraft: isDraft,
            features: _features,
            videoUrl: _videoUrlController.text.trim().isEmpty ? null : _videoUrlController.text.trim(),
            contactEmail: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            contactPhone: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
            ownerId: '',
            views: 0,
            featured: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            images: _imageUrls
                .asMap()
                .entries
                .map((e) => PropertyImage(
                      id: '',
                      propertyId: '',
                      url: e.value,
                      isPrimary: e.key == 0,
                      order: e.key,
                      createdAt: DateTime.now(),
                    ))
                .toList(),
          ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDraft ? 'Saved as draft' : 'Listing submitted for review'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Property')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _numbered(1, 'Purpose'),
                Row(
                  children: [
                    Expanded(child: _pillChoice('Sell', _purpose == 'FOR_SALE', () => setState(() => _purpose = 'FOR_SALE'))),
                    const SizedBox(width: 10),
                    Expanded(child: _pillChoice('Rent', _purpose == 'FOR_RENT', () => setState(() => _purpose = 'FOR_RENT'))),
                  ],
                ),
                const SizedBox(height: 20),

                _numbered(2, 'Property Category'),
                Row(
                  children: PropertyCategory.values.map((c) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _pillChoice(c.label, _category == c, () => setState(() {
                              _category = c;
                              _subtype = null;
                            })),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _category.subtypes.map((s) {
                    return ChoiceChip(
                      label: Text(s, style: const TextStyle(fontSize: 12.5)),
                      selected: _subtype == s,
                      onSelected: (_) => setState(() => _subtype = s),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                _numbered(3, 'Location'),
                BlocBuilder<PropertyBloc, PropertyState>(
                  buildWhen: (p, c) => c is CitiesLoaded,
                  builder: (context, state) {
                    final cities = state is CitiesLoaded ? state.cities : const <City>[];
                    return DropdownButtonFormField<City>(
                      initialValue: _city,
                      decoration: const InputDecoration(labelText: 'City'),
                      items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                      onChanged: (value) {
                        setState(() {
                          _city = value;
                          _area = null;
                        });
                        if (value != null) context.read<PropertyBloc>().add(LoadAreas(value.id));
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                BlocBuilder<PropertyBloc, PropertyState>(
                  buildWhen: (p, c) => c is AreasLoaded,
                  builder: (context, state) {
                    final areas = state is AreasLoaded ? state.areas : const <Area>[];
                    return DropdownButtonFormField<Area>(
                      initialValue: _area,
                      decoration: const InputDecoration(labelText: 'Area'),
                      items: areas.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
                      onChanged: (value) => setState(() => _area = value),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 20),

                _numbered(4, 'Size'),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _sizeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Size'),
                        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _sizeUnit,
                        items: sizeUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (v) => setState(() => _sizeUnit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _numbered(5, 'Price (PKR)'),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: _purpose == 'FOR_RENT' ? 'Monthly rent' : 'Price'),
                  validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid' : null,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Available on Installments', style: TextStyle(fontSize: 14)),
                  value: _installments,
                  onChanged: (v) => setState(() => _installments = v),
                ),

                if (_category.hasRoomCounts) ...[
                  const SizedBox(height: 12),
                  _numbered(6, 'Bedrooms'),
                  _countChips(_bedrooms, (v) => setState(() => _bedrooms = v)),
                  const SizedBox(height: 20),
                  _numbered(7, 'Bathrooms'),
                  _countChips(_bathrooms, (v) => setState(() => _bathrooms = v)),
                ],
                const SizedBox(height: 20),

                _numbered(8, 'Property Title'),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'e.g. 5 Marla House in DHA Phase 6'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 20),

                _numbered(9, 'Property Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Describe the property'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(builder: (_) => PropertyFeaturesScreen(initial: _features)),
                    );
                    if (result != null) setState(() => _features = result);
                  },
                  icon: const Icon(Icons.tune),
                  label: Text(_features == null ? 'Add Property Features' : 'Edit Property Features ✓'),
                ),
                const SizedBox(height: 20),

                _numbered(10, 'Images'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(labelText: 'Image URL'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                      onPressed: () {
                        final url = _imageUrlController.text.trim();
                        if (url.isEmpty) return;
                        setState(() {
                          _imageUrls.add(url);
                          _imageUrlController.clear();
                        });
                      },
                    ),
                  ],
                ),
                if (_imageUrls.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: _imageUrls
                        .map((url) => Chip(
                              label: Text(url.length > 24 ? '${url.substring(0, 24)}…' : url, style: const TextStyle(fontSize: 11)),
                              onDeleted: () => setState(() => _imageUrls.remove(url)),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 20),

                _numbered(11, 'Video'),
                TextFormField(
                  controller: _videoUrlController,
                  decoration: const InputDecoration(labelText: 'Video URL (optional)'),
                ),
                const SizedBox(height: 20),

                _numbered(12, 'Contact'),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  validator: (v) => (v == null || v.isEmpty || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Contact No.'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _submitting ? null : () => _submit(isDraft: true),
                        child: const Text('Save a Draft'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitting ? null : () => _submit(isDraft: false),
                        child: _submitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                            : const Text('Post Ad'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _numbered(int n, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(radius: 11, backgroundColor: AppTheme.primaryColor, child: Text('$n', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700))),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _pillChoice(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: selected ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _countChips(int? value, ValueChanged<int> onChanged) {
    return Wrap(
      spacing: 8,
      children: [1, 2, 3, 4, 5].map((n) {
        final label = n == 5 ? '5+' : '$n';
        return ChoiceChip(
          label: Text(label),
          selected: value == n,
          onSelected: (_) => onChanged(n),
        );
      }).toList(),
    );
  }
}
