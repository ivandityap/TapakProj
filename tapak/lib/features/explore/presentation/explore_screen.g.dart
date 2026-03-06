// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RiverpodGenerator
// **************************************************************************
// Run `flutter pub run build_runner build` to regenerate this file.

part of 'explore_screen.dart';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

String _$explorePlacesHash() => r'placeholder_hash';

/// See also [explorePlaces].
@ProviderFor(explorePlaces)
final explorePlacesProvider =
    AutoDisposeFutureProvider<List<Place>>.internal(
  explorePlaces,
  name: r'explorePlacesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$explorePlacesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ExplorePlacesRef = AutoDisposeFutureProviderRef<List<Place>>;

String _$exploreStateHash() => r'placeholder_hash';

/// See also [ExploreState].
@ProviderFor(ExploreState)
final exploreStateProvider =
    AutoDisposeNotifierProvider<ExploreState, ExploreFilter>.internal(
  ExploreState.new,
  name: r'exploreStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$exploreStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExploreState = AutoDisposeNotifier<ExploreFilter>;
