import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/map/data/places_repository.dart';
import '../../../shared/models/pet_policy.dart';

class _PetPolicyDraft {
  PetType petType;
  AllowedZone allowedZone;
  String conditions;

  _PetPolicyDraft({
    required this.petType,
    required this.allowedZone,
    this.conditions = '',
  });
}

class SuggestPlaceScreen extends ConsumerStatefulWidget {
  const SuggestPlaceScreen({super.key});

  @override
  ConsumerState<SuggestPlaceScreen> createState() => _SuggestPlaceScreenState();
}

class _SuggestPlaceScreenState extends ConsumerState<SuggestPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mapsUrlController = TextEditingController();
  final _instagramController = TextEditingController();
  final _notesController = TextEditingController();

  PlaceCategory _category = PlaceCategory.cafe;
  double _lat = AppConstants.defaultLatitude;
  double _lng = AppConstants.defaultLongitude;
  final List<_PetPolicyDraft> _policies = [];
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _mapsUrlController.dispose();
    _instagramController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      context.push('/login');
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = ref.read(placesRepositoryProvider);
      final placeId = await repo.submitPlace(
        name: _nameController.text.trim(),
        category: _category.name,
        address: _addressController.text.trim(),
        latitude: _lat,
        longitude: _lng,
        submittedBy: user.uid,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        googleMapsUrl: _mapsUrlController.text.trim().isEmpty
            ? null
            : _mapsUrlController.text.trim(),
        instagramUrl: _instagramController.text.trim().isEmpty
            ? null
            : _instagramController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      // Insert pet policies
      for (final policy in _policies) {
        await ref.read(placesRepositoryProvider).submitPlace(
              name: _nameController.text.trim(),
              category: _category.name,
              address: _addressController.text.trim(),
              latitude: _lat,
              longitude: _lng,
              submittedBy: user.uid,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Place submitted! Under review.'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addPolicy() {
    setState(() {
      _policies.add(_PetPolicyDraft(
        petType: PetType.cat,
        allowedZone: AllowedZone.outdoor,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suggest a Place')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Help the community discover pet-friendly places! '
              'All submissions are reviewed before appearing on the map.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Place Name *',
                prefixIcon: Icon(Icons.store_outlined),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<PlaceCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: PlaceCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.emoji} ${c.displayName}'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),

            // Map picker hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Coordinates: ${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: _showMapPicker,
                    child: const Text('Pick on Map'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Google Maps URL
            TextFormField(
              controller: _mapsUrlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Google Maps Link',
                prefixIcon: Icon(Icons.map_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Instagram
            TextFormField(
              controller: _instagramController,
              decoration: const InputDecoration(
                labelText: 'Instagram URL',
                prefixIcon: Icon(Icons.camera_alt_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (pet policy details, etc.)',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Pet policies
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pet Policies',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _addPolicy,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            ..._policies.asMap().entries.map((entry) {
              final index = entry.key;
              final policy = entry.value;
              return _PolicyEditor(
                policy: policy,
                onRemove: () =>
                    setState(() => _policies.removeAt(index)),
              );
            }),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Submit for Review'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMapPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            AppBar(
              title: const Text('Pick Location'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Expanded(
              child: gmaps.GoogleMap(
                initialCameraPosition: gmaps.CameraPosition(
                  target: gmaps.LatLng(_lat, _lng),
                  zoom: 15,
                ),
                onTap: (position) {
                  setState(() {
                    _lat = position.latitude;
                    _lng = position.longitude;
                  });
                },
                markers: {
                  gmaps.Marker(
                    markerId: const gmaps.MarkerId('selected'),
                    position: gmaps.LatLng(_lat, _lng),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyEditor extends StatefulWidget {
  final _PetPolicyDraft policy;
  final VoidCallback onRemove;

  const _PolicyEditor({required this.policy, required this.onRemove});

  @override
  State<_PolicyEditor> createState() => _PolicyEditorState();
}

class _PolicyEditorState extends State<_PolicyEditor> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<PetType>(
                    value: widget.policy.petType,
                    decoration: const InputDecoration(
                      labelText: 'Pet Type',
                      isDense: true,
                    ),
                    items: PetType.values
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                '${p.emoji} ${p.displayName}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => widget.policy.petType = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<AllowedZone>(
                    value: widget.policy.allowedZone,
                    decoration: const InputDecoration(
                      labelText: 'Zone',
                      isDense: true,
                    ),
                    items: AllowedZone.values
                        .map((z) => DropdownMenuItem(
                              value: z,
                              child: Text(
                                z.displayName,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => widget.policy.allowedZone = v!),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: widget.policy.conditions,
              decoration: const InputDecoration(
                labelText: 'Conditions (optional)',
                isDense: true,
              ),
              onChanged: (v) => widget.policy.conditions = v,
            ),
          ],
        ),
      ),
    );
  }
}
