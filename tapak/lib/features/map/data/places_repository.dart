import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/place.dart';
import '../../../shared/models/review.dart';
import '../../../shared/models/photo.dart';

part 'places_repository.g.dart';

@riverpod
PlacesRepository placesRepository(PlacesRepositoryRef ref) =>
    PlacesRepository();

class PlacesRepository {
  /// Fetch verified places within [radiusMeters] of the given coordinates.
  /// Uses PostGIS ST_DWithin for efficient radius queries.
  Future<List<Place>> getPlacesNearby({
    required double latitude,
    required double longitude,
    int radiusMeters = AppConstants.defaultRadius,
    String? petTypeFilter,
    String? categoryFilter,
  }) async {
    // We use Supabase RPC (stored function) for PostGIS radius query
    final response = await supabase.rpc(
      'get_places_nearby',
      params: {
        'lat': latitude,
        'lng': longitude,
        'radius_meters': radiusMeters,
        'pet_type_filter': petTypeFilter,
        'category_filter': categoryFilter,
      },
    );

    return (response as List)
        .map((json) => Place.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch all verified places (for explore/search)
  Future<List<Place>> searchPlaces({
    String? query,
    String? petTypeFilter,
    String? categoryFilter,
    int page = 0,
  }) async {
    var queryBuilder = supabase
        .from('places')
        .select('''
          *,
          pet_policies(*),
          reviews(rating)
        ''')
        .eq('status', 'verified')
        .range(
          page * AppConstants.placesPageSize,
          (page + 1) * AppConstants.placesPageSize - 1,
        );

    if (query != null && query.isNotEmpty) {
      queryBuilder = queryBuilder.or(
        'name.ilike.%$query%,address.ilike.%$query%',
      );
    }

    if (categoryFilter != null) {
      queryBuilder = queryBuilder.eq('category', categoryFilter);
    }

    final response = await queryBuilder;
    return (response as List)
        .map((json) => Place.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single place with full detail (policies, photos, reviews)
  Future<Place?> getPlaceDetail(String placeId) async {
    final response = await supabase
        .from('places')
        .select('''
          *,
          pet_policies(*),
          photos(*)
        ''')
        .eq('id', placeId)
        .maybeSingle();

    if (response == null) return null;
    return Place.fromJson(response as Map<String, dynamic>);
  }

  /// Fetch approved photos for a place
  Future<List<Photo>> getPlacePhotos(String placeId) async {
    final response = await supabase
        .from('photos')
        .select()
        .eq('place_id', placeId)
        .eq('is_approved', true)
        .order('is_cover', ascending: false)
        .order('created_at');

    return (response as List)
        .map((json) => Photo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch reviews for a place
  Future<List<Review>> getPlaceReviews(String placeId) async {
    final response = await supabase
        .from('reviews')
        .select('''
          *,
          profiles(display_name, avatar_url)
        ''')
        .eq('place_id', placeId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Review.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Submit a review
  Future<void> submitReview({
    required String placeId,
    required String userId,
    required int rating,
    String? comment,
    DateTime? visitDate,
  }) async {
    await supabase.from('reviews').upsert({
      'place_id': placeId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'visit_date': visitDate?.toIso8601String().split('T').first,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Toggle favorite
  Future<void> addFavorite(String userId, String placeId) async {
    await supabase.from('favorites').insert({
      'user_id': userId,
      'place_id': placeId,
    });
  }

  Future<void> removeFavorite(String userId, String placeId) async {
    await supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('place_id', placeId);
  }

  Future<bool> isFavorite(String userId, String placeId) async {
    final response = await supabase
        .from('favorites')
        .select('place_id')
        .eq('user_id', userId)
        .eq('place_id', placeId)
        .maybeSingle();
    return response != null;
  }

  Future<List<Place>> getFavorites(String userId) async {
    final response = await supabase
        .from('favorites')
        .select('''
          places(
            *,
            pet_policies(*)
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Place.fromJson(
              (json as Map<String, dynamic>)['places'] as Map<String, dynamic>,
            ))
        .toList();
  }

  /// Submit a new place suggestion
  Future<String> submitPlace({
    required String name,
    required String category,
    required String address,
    required double latitude,
    required double longitude,
    required String submittedBy,
    String? phone,
    String? googleMapsUrl,
    String? instagramUrl,
    String? notes,
  }) async {
    final response = await supabase.from('places').insert({
      'name': name,
      'category': category,
      'address': address,
      'location': 'SRID=4326;POINT($longitude $latitude)',
      'submitted_by': submittedBy,
      'phone': phone,
      'google_maps_url': googleMapsUrl,
      'instagram_url': instagramUrl,
      'notes': notes,
      'status': 'pending',
    }).select('id').single();

    return response['id'] as String;
  }

  /// Get pending submissions (editor/admin only)
  Future<List<Place>> getPendingSubmissions() async {
    final response = await supabase
        .from('places')
        .select('*, pet_policies(*)')
        .eq('status', 'pending')
        .order('created_at');

    return (response as List)
        .map((json) => Place.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Approve a place submission
  Future<void> approvePlace(String placeId, String verifiedBy) async {
    await supabase.from('places').update({
      'status': 'verified',
      'verified_by': verifiedBy,
      'verified_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', placeId);
  }

  /// Reject a place submission
  Future<void> rejectPlace(String placeId, String reason) async {
    await supabase.from('places').update({
      'status': 'rejected',
      'notes': reason,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', placeId);
  }

  /// Mark a place as closed
  Future<void> markClosed(String placeId) async {
    await supabase.from('places').update({
      'status': 'closed',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', placeId);
  }

  /// Get user's own submissions
  Future<List<Place>> getUserSubmissions(String userId) async {
    final response = await supabase
        .from('places')
        .select('*, pet_policies(*)')
        .eq('submitted_by', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Place.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get pending photos for review (editor/admin only)
  Future<List<Photo>> getPendingPhotos() async {
    final response = await supabase
        .from('photos')
        .select()
        .eq('is_approved', false)
        .order('created_at');

    return (response as List)
        .map((json) => Photo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> approvePhoto(String photoId) async {
    await supabase.from('photos').update({'is_approved': true}).eq('id', photoId);
  }

  Future<void> rejectPhoto(String photoId) async {
    await supabase.from('photos').delete().eq('id', photoId);
  }
}
