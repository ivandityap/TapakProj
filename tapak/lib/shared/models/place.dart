import '../../core/constants/app_constants.dart';
import 'pet_policy.dart';

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});
}

class Place {
  final String id;
  final String name;
  final PlaceCategory category;
  final String address;
  final LatLng location;
  final String? phone;
  final String? googleMapsUrl;
  final String? instagramUrl;
  final String? websiteUrl;
  final PlaceStatus status;
  final String? submittedBy;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined from places_summary view
  final double? avgRating;
  final int reviewCount;
  final String? coverPhotoPath;

  // Joined pet policies
  final List<PetPolicy> petPolicies;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.location,
    this.phone,
    this.googleMapsUrl,
    this.instagramUrl,
    this.websiteUrl,
    required this.status,
    this.submittedBy,
    this.verifiedBy,
    this.verifiedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.avgRating,
    this.reviewCount = 0,
    this.coverPhotoPath,
    this.petPolicies = const [],
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    // Parse PostGIS geography point
    // Supabase returns the location as GeoJSON when using ST_AsGeoJSON
    // or as a string like "POINT(lng lat)"
    LatLng location;
    final locationData = json['location'];
    if (locationData is Map) {
      // GeoJSON format: {"type": "Point", "coordinates": [lng, lat]}
      final coords = locationData['coordinates'] as List;
      location = LatLng(
        latitude: (coords[1] as num).toDouble(),
        longitude: (coords[0] as num).toDouble(),
      );
    } else if (locationData is String) {
      // WKT format: "POINT(lng lat)"
      final match = RegExp(r'POINT\(([^ ]+) ([^ )]+)\)').firstMatch(locationData);
      if (match != null) {
        location = LatLng(
          latitude: double.parse(match.group(2)!),
          longitude: double.parse(match.group(1)!),
        );
      } else {
        location = const LatLng(latitude: -6.2088, longitude: 106.8456);
      }
    } else {
      location = const LatLng(latitude: -6.2088, longitude: 106.8456);
    }

    final policiesJson = json['pet_policies'] as List<dynamic>? ?? [];

    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      category: PlaceCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => PlaceCategory.other,
      ),
      address: json['address'] as String,
      location: location,
      phone: json['phone'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      websiteUrl: json['website_url'] as String?,
      status: PlaceStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PlaceStatus.pending,
      ),
      submittedBy: json['submitted_by'] as String?,
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      coverPhotoPath: json['cover_photo_path'] as String?,
      petPolicies: policiesJson
          .map((p) => PetPolicy.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
