import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/place.dart';
import '../../../../shared/widgets/place_card.dart';

class PlacesListView extends ConsumerWidget {
  final List<Place> places;

  const PlacesListView({super.key, required this.places});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (places.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🐾', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              Text('No pet-friendly places found nearby'),
              SizedBox(height: 8),
              Text(
                'Try expanding the search radius or removing filters',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppColors.background,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PlaceCard(
              place: place,
              onTap: () => context.push('/place/${place.id}'),
            ),
          );
        },
      ),
    );
  }
}
