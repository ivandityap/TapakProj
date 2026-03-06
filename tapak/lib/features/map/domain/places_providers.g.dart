// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RiverpodGenerator
// **************************************************************************
// Run `flutter pub run build_runner build` to regenerate this file.

part of 'places_providers.dart';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

String _$nearbyPlacesHash() => r'placeholder_hash';

/// See also [nearbyPlaces].
@ProviderFor(nearbyPlaces)
final nearbyPlacesProvider = AutoDisposeFutureProvider<List<Place>>.internal(
  nearbyPlaces,
  name: r'nearbyPlacesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nearbyPlacesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NearbyPlacesRef = AutoDisposeFutureProviderRef<List<Place>>;

String _$placeDetailHash() => r'placeholder_hash';

/// See also [placeDetail].
@ProviderFor(placeDetail)
const placeDetailProvider = PlaceDetailFamily();

class PlaceDetailFamily extends Family<AsyncValue<Place?>> {
  const PlaceDetailFamily();

  AutoDisposeFutureProvider<Place?> call(String placeId) {
    return AutoDisposeFutureProvider<Place?>.internal(
      (ref) => placeDetail(ref as PlaceDetailRef, placeId),
      from: this,
      argument: placeId,
      name: r'placeDetailProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$placeDetailHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );
  }
}

typedef PlaceDetailRef = AutoDisposeFutureProviderRef<Place?>;

String _$placeReviewsHash() => r'placeholder_hash';

/// See also [placeReviews].
@ProviderFor(placeReviews)
const placeReviewsProvider = PlaceReviewsFamily();

class PlaceReviewsFamily extends Family<AsyncValue<List<Review>>> {
  const PlaceReviewsFamily();

  AutoDisposeFutureProvider<List<Review>> call(String placeId) {
    return AutoDisposeFutureProvider<List<Review>>.internal(
      (ref) => placeReviews(ref as PlaceReviewsRef, placeId),
      from: this,
      argument: placeId,
      name: r'placeReviewsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$placeReviewsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );
  }
}

typedef PlaceReviewsRef = AutoDisposeFutureProviderRef<List<Review>>;

String _$placePhotosHash() => r'placeholder_hash';

/// See also [placePhotos].
@ProviderFor(placePhotos)
const placePhotosProvider = PlacePhotosFamily();

class PlacePhotosFamily extends Family<AsyncValue<List<Photo>>> {
  const PlacePhotosFamily();

  AutoDisposeFutureProvider<List<Photo>> call(String placeId) {
    return AutoDisposeFutureProvider<List<Photo>>.internal(
      (ref) => placePhotos(ref as PlacePhotosRef, placeId),
      from: this,
      argument: placeId,
      name: r'placePhotosProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$placePhotosHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );
  }
}

typedef PlacePhotosRef = AutoDisposeFutureProviderRef<List<Photo>>;

String _$mapFilterHash() => r'placeholder_hash';

/// See also [MapFilter].
@ProviderFor(MapFilter)
final mapFilterProvider =
    AutoDisposeNotifierProvider<MapFilter, PlacesFilter>.internal(
  MapFilter.new,
  name: r'mapFilterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mapFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MapFilter = AutoDisposeNotifier<PlacesFilter>;
