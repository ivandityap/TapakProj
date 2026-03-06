import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/data/auth_repository.dart';
import '../../../features/map/data/places_repository.dart';
import '../../../shared/models/place.dart';

part 'profile_screen.g.dart';

@riverpod
Future<List<Place>> userSubmissions(UserSubmissionsRef ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  return ref.read(placesRepositoryProvider).getUserSubmissions(user.uid);
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final profileAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (userAsync.valueOrNull != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/');
              },
            ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) {
            return _GuestView(
              onSignIn: () => context.push('/login'),
              onSignUp: () => context.push('/signup'),
            );
          }

          return profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (profile) => SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header
                  Container(
                    width: double.infinity,
                    color: AppColors.primary,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: Text(
                            (profile?.displayName ?? user.email ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile?.displayName ?? user.email ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            profile?.role.name.toUpperCase() ?? 'CONTRIBUTOR',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Actions
                  _ProfileAction(
                    icon: Icons.favorite_outline,
                    label: 'My Favorites',
                    onTap: () => context.push('/favorites'),
                  ),
                  _ProfileAction(
                    icon: Icons.add_location_alt_outlined,
                    label: 'Suggest a Place',
                    onTap: () => context.push('/suggest'),
                  ),
                  _ProfileAction(
                    icon: Icons.history,
                    label: 'My Submissions',
                    onTap: () => _showSubmissions(context, ref),
                  ),

                  // Admin panel (role-gated)
                  if (profile?.role.canEdit == true) ...[
                    const Divider(height: 32),
                    _ProfileAction(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Admin: Pending Submissions',
                      onTap: () => context.push('/admin/queue'),
                      color: AppColors.secondary,
                    ),
                    _ProfileAction(
                      icon: Icons.photo_library_outlined,
                      label: 'Admin: Photo Queue',
                      onTap: () => context.push('/admin/photos'),
                      color: AppColors.secondary,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSubmissions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            AppBar(
              title: const Text('My Submissions'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final submissionsAsync = ref.watch(userSubmissionsProvider);
                  return submissionsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (submissions) => submissions.isEmpty
                        ? const Center(
                            child: Text('No submissions yet'),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: submissions.length,
                            itemBuilder: (context, index) {
                              final place = submissions[index];
                              return ListTile(
                                leading: Text(
                                  place.category.emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                title: Text(place.name),
                                subtitle: Text(place.address),
                                trailing: _StatusBadge(status: place.status),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestView extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  const _GuestView({required this.onSignIn, required this.onSignUp});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐾', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Join Tapak',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to save favorites, write reviews, '
              'and suggest pet-friendly places.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onSignIn,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onSignUp,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PlaceStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case PlaceStatus.verified:
        color = AppColors.verified;
        label = 'Verified';
      case PlaceStatus.pending:
        color = AppColors.pending;
        label = 'Pending';
      case PlaceStatus.rejected:
        color = AppColors.rejected;
        label = 'Rejected';
      case PlaceStatus.closed:
        color = AppColors.textSecondary;
        label = 'Closed';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
