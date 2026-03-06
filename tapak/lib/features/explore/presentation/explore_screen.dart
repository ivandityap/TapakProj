import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/map/data/places_repository.dart';
import '../../../shared/models/place.dart';
import '../../../shared/widgets/place_card.dart';

part 'explore_screen.g.dart';

class ExploreFilter {
  final String query;
  final PetType? petType;
  final PlaceCategory? category;

  const ExploreFilter({
    this.query = '',
    this.petType,
    this.category,
  });
}

@riverpod
class ExploreState extends _$ExploreState {
  @override
  ExploreFilter build() => const ExploreFilter();

  void setQuery(String q) => state = ExploreFilter(
        query: q,
        petType: state.petType,
        category: state.category,
      );

  void setPetType(PetType? t) => state = ExploreFilter(
        query: state.query,
        petType: t,
        category: state.category,
      );

  void setCategory(PlaceCategory? c) => state = ExploreFilter(
        query: state.query,
        petType: state.petType,
        category: c,
      );
}

@riverpod
Future<List<Place>> explorePlaces(ExplorePlacesRef ref) async {
  final filter = ref.watch(exploreStateProvider);
  final repo = ref.read(placesRepositoryProvider);
  return repo.searchPlaces(
    query: filter.query.isEmpty ? null : filter.query,
    petTypeFilter: filter.petType?.dbValue,
    categoryFilter: filter.category?.name,
  );
}

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(exploreStateProvider);
    final notifier = ref.read(exploreStateProvider.notifier);
    final placesAsync = ref.watch(explorePlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filter.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: notifier.setQuery,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filters
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                ...PetType.values.where((p) => p != PetType.all).map((pet) {
                  final selected = filter.petType == pet;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${pet.emoji} ${pet.displayName}'),
                      selected: selected,
                      onSelected: (v) => notifier.setPetType(v ? pet : null),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
                ...PlaceCategory.values.map((cat) {
                  final selected = filter.category == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${cat.emoji} ${cat.displayName}'),
                      selected: selected,
                      onSelected: (v) => notifier.setCategory(v ? cat : null),
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Results
          Expanded(
            child: placesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (places) {
                if (places.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🐾', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 16),
                        Text('No places found'),
                        SizedBox(height: 8),
                        Text(
                          'Try a different search or remove filters',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: places.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PlaceCard(
                      place: places[index],
                      onTap: () => context.push('/place/${places[index].id}'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
