import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/map/data/places_repository.dart';
import '../../../features/map/domain/places_providers.dart';

class AdminPlaceReviewScreen extends ConsumerStatefulWidget {
  final String placeId;

  const AdminPlaceReviewScreen({super.key, required this.placeId});

  @override
  ConsumerState<AdminPlaceReviewScreen> createState() =>
      _AdminPlaceReviewScreenState();
}

class _AdminPlaceReviewScreenState
    extends ConsumerState<AdminPlaceReviewScreen> {
  bool _loading = false;
  final _rejectReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectReasonController.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(placesRepositoryProvider)
          .approvePlace(widget.placeId, user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Place approved and published!'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reject() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Submission'),
        content: TextField(
          controller: _rejectReasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Reason for rejection (shown to submitter)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, _rejectReasonController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason == null) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(placesRepositoryProvider)
          .rejectPlace(widget.placeId, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Place rejected.'),
            backgroundColor: AppColors.error,
          ),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeAsync = ref.watch(placeDetailProvider(widget.placeId));

    return Scaffold(
      appBar: AppBar(title: const Text('Review Submission')),
      body: placeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (place) {
          if (place == null) {
            return const Center(child: Text('Place not found'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    _DetailRow('Category',
                        '${place.category.emoji} ${place.category.displayName}'),
                    _DetailRow('Address', place.address),
                    if (place.phone != null)
                      _DetailRow('Phone', place.phone!),
                    if (place.googleMapsUrl != null)
                      _DetailRow('Google Maps', place.googleMapsUrl!),
                    if (place.instagramUrl != null)
                      _DetailRow('Instagram', place.instagramUrl!),
                    if (place.notes != null)
                      _DetailRow('Notes', place.notes!),
                    _DetailRow(
                      'Location',
                      '${place.location.latitude.toStringAsFixed(5)}, '
                          '${place.location.longitude.toStringAsFixed(5)}',
                    ),

                    if (place.petPolicies.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Pet Policies',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ...place.petPolicies.map(
                        (p) => ListTile(
                          leading: Text(
                            p.petType.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            '${p.petType.displayName} · ${p.allowedZone.displayName}',
                          ),
                          subtitle: p.conditions != null
                              ? Text(p.conditions!)
                              : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _loading ? null : _reject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: const Size(0, 48),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _approve,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
