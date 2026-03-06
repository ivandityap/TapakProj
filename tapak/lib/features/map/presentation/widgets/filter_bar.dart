import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/places_providers.dart';

class FilterBar extends ConsumerWidget {
  final VoidCallback onListToggle;
  final bool isListView;

  const FilterBar({
    super.key,
    required this.onListToggle,
    required this.isListView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(mapFilterProvider);
    final notifier = ref.read(mapFilterProvider.notifier);

    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          // Top bar: search + list toggle
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tapak',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isListView ? Icons.map_outlined : Icons.list,
                    color: AppColors.primary,
                  ),
                  onPressed: onListToggle,
                  tooltip: isListView ? 'Map view' : 'List view',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // Pet type filter
                ...PetType.values.where((p) => p != PetType.all).map((pet) {
                  final selected = filter.petType == pet;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${pet.emoji} ${pet.displayName}'),
                      selected: selected,
                      onSelected: (v) =>
                          notifier.setPetType(v ? pet : null),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  );
                }),
                const SizedBox(width: 4),
                // Category filter
                ...PlaceCategory.values.map((cat) {
                  final selected = filter.category == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${cat.emoji} ${cat.displayName}'),
                      selected: selected,
                      onSelected: (v) =>
                          notifier.setCategory(v ? cat : null),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
