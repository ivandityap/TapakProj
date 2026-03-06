import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/map/data/places_repository.dart';
import '../../../shared/models/place.dart';

part 'admin_queue_screen.g.dart';

@riverpod
Future<List<Place>> pendingSubmissions(PendingSubmissionsRef ref) async {
  final profile = await ref.watch(currentUserProvider.future);
  if (profile == null || !profile.role.canEdit) return [];
  return ref.read(placesRepositoryProvider).getPendingSubmissions();
}

class AdminQueueScreen extends ConsumerWidget {
  const AdminQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(pendingSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Submissions')),
      body: submissionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('✅', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 16),
                  Text('No pending submissions'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final place = submissions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Text(
                    place.category.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(place.name),
                  subtitle: Text(
                    '${place.category.displayName} · ${place.address}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(Icons.chevron_right),
                      Text(
                        _formatDate(place.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/admin/place/${place.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
