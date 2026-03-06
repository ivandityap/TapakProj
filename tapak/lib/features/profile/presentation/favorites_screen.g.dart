// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RiverpodGenerator
// **************************************************************************
// Run `flutter pub run build_runner build` to regenerate this file.

part of 'favorites_screen.dart';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

String _$favoritesHash() => r'placeholder_hash';

/// See also [favorites].
@ProviderFor(favorites)
final favoritesProvider = AutoDisposeFutureProvider<List<Place>>.internal(
  favorites,
  name: r'favoritesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$favoritesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FavoritesRef = AutoDisposeFutureProviderRef<List<Place>>;
