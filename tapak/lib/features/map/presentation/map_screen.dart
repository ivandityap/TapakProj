import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/place.dart';
import '../domain/places_providers.dart';
import 'widgets/filter_bar.dart';
import 'widgets/place_bottom_sheet.dart';
import 'widgets/places_list_view.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  bool _showListView = false;
  Place? _selectedPlace;
  bool _locationLoading = false;

  static const _defaultCamera = CameraPosition(
    target: LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() => _locationLoading = true);
    try {
      final position = await _getCurrentLocation();
      if (position != null && mounted) {
        ref.read(mapFilterProvider.notifier).setLocation(
              position.latitude,
              position.longitude,
            );
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Set<Marker> _buildMarkers(List<Place> places) {
    return places.map((place) {
      return Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.location.latitude, place.location.longitude),
        infoWindow: InfoWindow(title: place.name),
        onTap: () => setState(() => _selectedPlace = place),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(nearbyPlacesProvider);
    final filter = ref.watch(mapFilterProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: _defaultCamera,
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: placesAsync.valueOrNull != null
                ? _buildMarkers(placesAsync.valueOrNull!)
                : {},
            onTap: (_) => setState(() => _selectedPlace = null),
          ),

          // Filter bar at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: FilterBar(
              onListToggle: () => setState(() => _showListView = !_showListView),
              isListView: _showListView,
            ),
          ),

          // Loading indicator
          if (placesAsync.isLoading || _locationLoading)
            const Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),

          // Near Me button
          Positioned(
            bottom: _selectedPlace != null ? 220 : 100,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'near_me',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  onPressed: _locationLoading ? null : _initLocation,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                _RadiusButton(
                  currentRadius: filter.radiusMeters,
                  onChanged: (r) =>
                      ref.read(mapFilterProvider.notifier).setRadius(r),
                ),
              ],
            ),
          ),

          // Suggest a place FAB
          Positioned(
            bottom: _selectedPlace != null ? 220 : 100,
            left: 16,
            child: FloatingActionButton.extended(
              heroTag: 'suggest',
              backgroundColor: AppColors.secondary,
              onPressed: () => context.push('/suggest'),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Suggest a Place',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          // Place bottom sheet
          if (_selectedPlace != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: PlaceBottomSheet(
                place: _selectedPlace!,
                onClose: () => setState(() => _selectedPlace = null),
                onTap: () => context.push('/place/${_selectedPlace!.id}'),
              ),
            ),

          // List view overlay
          if (_showListView)
            Positioned.fill(
              top: MediaQuery.of(context).padding.top + 80,
              bottom: 80,
              child: placesAsync.when(
                data: (places) => PlacesListView(places: places),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
        ],
      ),
    );
  }
}

class _RadiusButton extends StatelessWidget {
  final int currentRadius;
  final ValueChanged<int> onChanged;

  const _RadiusButton({
    required this.currentRadius,
    required this.onChanged,
  });

  String _label(int meters) {
    if (meters < 1000) return '${meters}m';
    return '${meters ~/ 1000}km';
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Search radius',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.radar, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              _label(currentRadius),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onSelected: onChanged,
      itemBuilder: (_) => AppConstants.radiusOptions
          .map(
            (r) => PopupMenuItem(
              value: r,
              child: Text(_label(r)),
            ),
          )
          .toList(),
    );
  }
}
