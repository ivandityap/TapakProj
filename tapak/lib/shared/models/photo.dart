class Photo {
  final String id;
  final String placeId;
  final String? uploadedBy;
  final String storagePath;
  final bool isCover;
  final bool isApproved;
  final DateTime createdAt;

  const Photo({
    required this.id,
    required this.placeId,
    this.uploadedBy,
    required this.storagePath,
    required this.isCover,
    required this.isApproved,
    required this.createdAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      placeId: json['place_id'] as String,
      uploadedBy: json['uploaded_by'] as String?,
      storagePath: json['storage_path'] as String,
      isCover: json['is_cover'] as bool? ?? false,
      isApproved: json['is_approved'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String publicUrl(String supabaseUrl) {
    return '$supabaseUrl/storage/v1/object/public/place-photos/$storagePath';
  }
}
