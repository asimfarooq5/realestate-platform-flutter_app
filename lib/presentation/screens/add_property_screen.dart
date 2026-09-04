import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';

/// A single-page "Post a Property" form. This is a basic first version —
/// the full multi-step wizard from the product wireframe (subtype, size
/// unit, installments, detailed features/amenities, photos) is a larger
/// follow-up; this covers the fields the backend already requires so
/// listings can actually be created end-to-end.
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
  final _areaSizeController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();

  String _type = 'HOUSE';
  String _status = 'FOR_SALE';
  City? _city;
  Area? _area;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(LoadCities());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _areaSizeController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _city == null || _area == null) {
      if (_city == null || _area == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a city and area')),
        );
      }
      return;
    }

    setState(() => _submitting = true);
    try {
      await context.read<PropertyBloc>().createProperty(Property(
            id: '',
            slug: '',
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            type: _type,
            status: _status,
            listingStatus: 'PENDING',
            cityId: _city!.id,
            areaId: _area!.id,
            address: _addressController.text.trim(),
            price: double.parse(_priceController.text),
            priceUnit: 'PKR',
            areaSize: double.parse(_areaSizeController.text),
            areaUnit: 'sqft',
            bedrooms: _bedroomsController.text.isEmpty ? null : int.tryParse(_bedroomsController.text),
            bathrooms: _bathroomsController.text.isEmpty ? null : int.tryParse(_bathroomsController.text),
            furnished: false,
            ownerId: '',
            views: 0,
            featured: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing submitted for review'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit listing: $e'), backgroundColor: AppTheme.errorColor),
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
                Row(
                  children: [
                    Expanded(child: _purposeChip('FOR_SALE', 'Sell')),
                    const SizedBox(width: 10),
                    Expanded(child: _purposeChip('FOR_RENT', 'Rent')),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Property Type'),
                  items: const [
                    DropdownMenuItem(value: 'HOUSE', child: Text('House')),
                    DropdownMenuItem(value: 'APARTMENT', child: Text('Apartment')),
                    DropdownMenuItem(value: 'PLOT', child: Text('Plot')),
                    DropdownMenuItem(value: 'COMMERCIAL', child: Text('Commercial')),
                    DropdownMenuItem(value: 'VILLA', child: Text('Villa')),
                  ],
                  onChanged: (value) => setState(() => _type = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                BlocBuilder<PropertyBloc, PropertyState>(
                  buildWhen: (previous, current) => current is CitiesLoaded,
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
                        if (value != null) {
                          context.read<PropertyBloc>().add(LoadAreas(value.id));
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<PropertyBloc, PropertyState>(
                  buildWhen: (previous, current) => current is AreasLoaded,
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price (PKR)'),
                        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _areaSizeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Size (sqft)'),
                        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bedroomsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Bedrooms (optional)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _bathroomsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Bathrooms (optional)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Submit for Review'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _purposeChip(String value, String label) {
    final selected = _status == value;
    return GestureDetector(
      onTap: () => setState(() => _status = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
