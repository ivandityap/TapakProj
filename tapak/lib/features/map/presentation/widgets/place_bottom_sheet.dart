import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/widgets/rating_stars.dart';

class PlaceBottomSheet extends StatelessWidget {
  final Place place;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const PlaceBottomSheet({
    super.key,
    required this.place,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    place.category.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${place.category.displayName} • ${place.address}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingStars(rating: place.avgRating ?? 0, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          place.avgRating != null
                              ? '${place.avgRating!.toStringAsFixed(1)} (${place.reviewCount})'
                              : 'No reviews',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        // Pet policy summary
                        if (place.petPolicies.isNotEmpty)
                          Text(
                            place.petPolicies
                                .take(2)
                                .map((p) => p.petType.emoji)
                                .join(' '),
                            style: const TextStyle(fontSize: 14),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              // Close
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClose,
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
