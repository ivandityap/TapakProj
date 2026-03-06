import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/map/data/places_repository.dart';
import '../../../shared/models/photo.dart';

part 'admin_photo_queue_screen.g.dart';

@riverpod
Future<List<Photo>> pendingPhotos(PendingPhotosRef ref) async {
  final profile = await ref.watch(currentUserProvider.future);
  if (profile == null || !profile.role.canEdit) return [];
  return ref.read(placesRepositoryProvider).getPendingPhotos();
}

class AdminPhotoQueueScreen extends ConsumerWidget {
  const AdminPhotoQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(pendingPhotosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Photo Approval Queue')),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('✅', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 16),
                  Text('No photos pending review'),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return _PhotoCard(
                photo: photo,
                onApprove: () async {
                  await ref
                      .read(placesRepositoryProvider)
                      .approvePhoto(photo.id);
                  ref.invalidate(pendingPhotosProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo approved'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
                onReject: () async {
                  await ref
                      .read(placesRepositoryProvider)
                      .rejectPhoto(photo.id);
                  ref.invalidate(pendingPhotosProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo rejected'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final Photo photo;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PhotoCard({
    required this.photo,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              photo.storagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.broken_image, size: 48),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Reject', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
