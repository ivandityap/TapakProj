import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/place.dart';
import '../../../shared/models/review.dart';
import '../../../shared/models/photo.dart';
import '../data/places_repository.dart';

part 'places_providers.g.dart';

class PlacesFilter {
  final double? latitude;
  final double? longitude;
  final int radiusMeters;
  final PetType? petType;
  final PlaceCategory? category;

  const PlacesFilter({
    this.latitude,
    this.longitude,
    this.radiusMeters = AppConstants.defaultRadius,
    this.petType,
    this.category,
  });

  PlacesFilter copyWith({
    double? latitude,
    double? longitude,
    int? radiusMeters,
    PetType? petType,
    PlaceCategory? category,
    bool clearPetType = false,
    bool clearCategory = false,
  }) {
    return PlacesFilter(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      petType: clearPetType ? null : (petType ?? this.petType),
      category: clearCategory ? null : (category ?? this.category),
    );
  }
}

@riverpod
class MapFilter extends _$MapFilter {
  @override
  PlacesFilter build() => const PlacesFilter();

  void update(PlacesFilter filter) => state = filter;
  void setLocation(double lat, double lng) =>
      state = state.copyWith(latitude: lat, longitude: lng);
  void setRadius(int meters) => state = state.copyWith(radiusMeters: meters);
  void setPetType(PetType? petType) =>
      state = state.copyWith(petType: petType, clearPetType: petType == null);
  void setCategory(PlaceCategory? category) =>
      state = state.copyWith(category: category, clearCategory: category == null);
}

@riverpod
Future<List<Place>> nearbyPlaces(NearbyPlacesRef ref) async {
  final filter = ref.watch(mapFilterProvider);
  if (filter.latitude == null || filter.longitude == null) return [];

  final repo = ref.read(placesRepositoryProvider);
  return repo.getPlacesNearby(
    latitude: filter.latitude!,
    longitude: filter.longitude!,
    radiusMeters: filter.radiusMeters,
    petTypeFilter: filter.petType?.dbValue,
    categoryFilter: filter.category?.name,
  );
}

@riverpod
Future<Place?> placeDetail(PlaceDetailRef ref, String placeId) async {
  final repo = ref.read(placesRepositoryProvider);
  return repo.getPlaceDetail(placeId);
}

@riverpod
Future<List<Review>> placeReviews(PlaceReviewsRef ref, String placeId) async {
  final repo = ref.read(placesRepositoryProvider);
  return repo.getPlaceReviews(placeId);
}

@riverpod
Future<List<Photo>> placePhotos(PlacePhotosRef ref, String placeId) async {
  final repo = ref.read(placesRepositoryProvider);
  return repo.getPlacePhotos(placeId);
}
