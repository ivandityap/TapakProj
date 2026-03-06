// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RiverpodGenerator
// **************************************************************************
// Run `flutter pub run build_runner build` to regenerate this file.

part of 'admin_queue_screen.dart';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

String _$pendingSubmissionsHash() => r'placeholder_hash';

/// See also [pendingSubmissions].
@ProviderFor(pendingSubmissions)
final pendingSubmissionsProvider =
    AutoDisposeFutureProvider<List<Place>>.internal(
  pendingSubmissions,
  name: r'pendingSubmissionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingSubmissionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PendingSubmissionsRef = AutoDisposeFutureProviderRef<List<Place>>;
