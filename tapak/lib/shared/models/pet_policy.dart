import '../../core/constants/app_constants.dart';

class PetPolicy {
  final String id;
  final String placeId;
  final PetType petType;
  final AllowedZone allowedZone;
  final String? conditions;
  final DateTime createdAt;

  const PetPolicy({
    required this.id,
    required this.placeId,
    required this.petType,
    required this.allowedZone,
    this.conditions,
    required this.createdAt,
  });

  factory PetPolicy.fromJson(Map<String, dynamic> json) {
    return PetPolicy(
      id: json['id'] as String,
      placeId: json['place_id'] as String,
      petType: PetType.fromDb(json['pet_type'] as String),
      allowedZone: AllowedZone.values.firstWhere(
        (z) => z.name == json['allowed_zone'],
        orElse: () => AllowedZone.outdoor,
      ),
      conditions: json['conditions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'place_id': placeId,
        'pet_type': petType.dbValue,
        'allowed_zone': allowedZone.name,
        'conditions': conditions,
      };
}
