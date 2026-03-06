// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RiverpodGenerator
// **************************************************************************
// Run `flutter pub run build_runner build` to regenerate this file.

part of 'profile_screen.dart';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

String _$userSubmissionsHash() => r'placeholder_hash';

/// See also [userSubmissions].
@ProviderFor(userSubmissions)
final userSubmissionsProvider =
    AutoDisposeFutureProvider<List<Place>>.internal(
  userSubmissions,
  name: r'userSubmissionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userSubmissionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserSubmissionsRef = AutoDisposeFutureProviderRef<List<Place>>;
