// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RiverpodGenerator
// **************************************************************************
// Run `flutter pub run build_runner build` to regenerate this file.

part of 'admin_photo_queue_screen.dart';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

String _$pendingPhotosHash() => r'placeholder_hash';

/// See also [pendingPhotos].
@ProviderFor(pendingPhotos)
final pendingPhotosProvider = AutoDisposeFutureProvider<List<Photo>>.internal(
  pendingPhotos,
  name: r'pendingPhotosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingPhotosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PendingPhotosRef = AutoDisposeFutureProviderRef<List<Photo>>;
