import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/place.dart';
import '../../../shared/models/review.dart';
import '../../../shared/models/photo.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../data/places_repository.dart';
import '../domain/places_providers.dart';

class PlaceDetailScreen extends ConsumerStatefulWidget {
  final String placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  bool _isFavorite = false;
  bool _favoriteLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    final isFav = await ref
        .read(placesRepositoryProvider)
        .isFavorite(user.uid, widget.placeId);
    if (mounted) setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      context.push('/login');
      return;
    }
    setState(() => _favoriteLoading = true);
    try {
      final repo = ref.read(placesRepositoryProvider);
      if (_isFavorite) {
        await repo.removeFavorite(user.uid, widget.placeId);
      } else {
        await repo.addFavorite(user.uid, widget.placeId);
      }
      if (mounted) setState(() => _isFavorite = !_isFavorite);
    } finally {
      if (mounted) setState(() => _favoriteLoading = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeAsync = ref.watch(placeDetailProvider(widget.placeId));
    final photosAsync = ref.watch(placePhotosProvider(widget.placeId));
    final reviewsAsync = ref.watch(placeReviewsProvider(widget.placeId));
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      body: placeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (place) {
          if (place == null) {
            return const Center(child: Text('Place not found'));
          }
          return CustomScrollView(
            slivers: [
              // Photo header
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                actions: [
                  _favoriteLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: Colors.white,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: photosAsync.when(
                    data: (photos) => photos.isNotEmpty
                        ? Image.network(
                            photos.first.storagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _PlaceholderHeader(
                              category: place.category,
                            ),
                          )
                        : _PlaceholderHeader(category: place.category),
                    loading: () =>
                        _PlaceholderHeader(category: place.category),
                    error: (_, __) =>
                        _PlaceholderHeader(category: place.category),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Name and category
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${place.category.emoji} ${place.category.displayName}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        RatingStars(rating: place.avgRating ?? 0, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          place.avgRating != null
                              ? '${place.avgRating!.toStringAsFixed(1)} · ${place.reviewCount} review${place.reviewCount != 1 ? 's' : ''}'
                              : 'No reviews yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Verified badge
                    if (place.status == PlaceStatus.verified &&
                        place.verifiedAt != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            color: AppColors.verified,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified place',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.verified),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Contact info
                    _InfoSection(
                      title: 'Info',
                      children: [
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          text: place.address,
                        ),
                        if (place.phone != null)
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            text: place.phone!,
                          ),
                        if (place.googleMapsUrl != null)
                          _InfoRow(
                            icon: Icons.map_outlined,
                            text: 'Open in Google Maps',
                            onTap: () => _launchUrl(place.googleMapsUrl!),
                            isLink: true,
                          ),
                        if (place.instagramUrl != null)
                          _InfoRow(
                            icon: Icons.camera_alt_outlined,
                            text: 'Instagram',
                            onTap: () => _launchUrl(place.instagramUrl!),
                            isLink: true,
                          ),
                        if (place.websiteUrl != null)
                          _InfoRow(
                            icon: Icons.language_outlined,
                            text: 'Website',
                            onTap: () => _launchUrl(place.websiteUrl!),
                            isLink: true,
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Pet policies
                    if (place.petPolicies.isNotEmpty) ...[
                      _InfoSection(
                        title: 'Pet Policies',
                        children: [
                          ...place.petPolicies.map(
                            (policy) => _PetPolicyRow(policy: policy),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Photo gallery
                    photosAsync.when(
                      data: (photos) => photos.length > 1
                          ? _PhotoGallery(photos: photos)
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    // Reviews
                    _InfoSection(
                      title: 'Reviews',
                      trailing: user != null
                          ? TextButton(
                              onPressed: () =>
                                  context.push('/place/${place.id}/review'),
                              child: const Text('Write a review'),
                            )
                          : null,
                      children: [],
                    ),
                    reviewsAsync.when(
                      data: (reviews) => reviews.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text('No reviews yet. Be the first!'),
                              ),
                            )
                          : Column(
                              children: reviews
                                  .map((r) => _ReviewCard(review: r))
                                  .toList(),
                            ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlaceholderHeader extends StatelessWidget {
  final PlaceCategory category;

  const _PlaceholderHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.2),
      child: Center(
        child: Text(
          category.emoji,
          style: const TextStyle(fontSize: 64),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final bool isLink;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.onTap,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isLink ? AppColors.primary : null,
                      decoration:
                          isLink ? TextDecoration.underline : null,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetPolicyRow extends StatelessWidget {
  final dynamic policy;

  const _PetPolicyRow({required this.policy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(policy.petType.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${policy.petType.displayName} · ${policy.allowedZone.displayName}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (policy.conditions != null)
                  Text(
                    policy.conditions,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  final List<dynamic> photos;

  const _PhotoGallery({required this.photos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    photos[index].storagePath,
                    width: 160,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 160,
                      height: 120,
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  (review.userDisplayName ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userDisplayName ?? 'Anonymous',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Row(
                      children: [
                        RatingStars(rating: review.rating.toDouble(), size: 12),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
