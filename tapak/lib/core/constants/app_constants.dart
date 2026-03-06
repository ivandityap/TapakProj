class AppConstants {
  static const String appName = 'Tapak';
  static const String storageBucket = 'place-photos';

  // Default map center: Jakarta
  static const double defaultLatitude = -6.2088;
  static const double defaultLongitude = 106.8456;

  // Radius options in meters
  static const List<int> radiusOptions = [1000, 2000, 5000, 10000];
  static const int defaultRadius = 5000;

  // Max photo size before compression (bytes)
  static const int maxPhotoBytes = 1024 * 1024; // 1 MB

  // Pagination
  static const int placesPageSize = 20;
}

enum PlaceStatus { pending, verified, rejected, closed }

enum PlaceCategory {
  cafe,
  restaurant,
  mall,
  park,
  hotel,
  store,
  vet,
  grooming,
  other;

  String get displayName {
    switch (this) {
      case PlaceCategory.cafe:
        return 'Cafe';
      case PlaceCategory.restaurant:
        return 'Restaurant';
      case PlaceCategory.mall:
        return 'Mall';
      case PlaceCategory.park:
        return 'Park';
      case PlaceCategory.hotel:
        return 'Hotel';
      case PlaceCategory.store:
        return 'Store';
      case PlaceCategory.vet:
        return 'Vet';
      case PlaceCategory.grooming:
        return 'Grooming';
      case PlaceCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case PlaceCategory.cafe:
        return '☕';
      case PlaceCategory.restaurant:
        return '🍽️';
      case PlaceCategory.mall:
        return '🏬';
      case PlaceCategory.park:
        return '🌳';
      case PlaceCategory.hotel:
        return '🏨';
      case PlaceCategory.store:
        return '🛍️';
      case PlaceCategory.vet:
        return '🏥';
      case PlaceCategory.grooming:
        return '✂️';
      case PlaceCategory.other:
        return '📍';
    }
  }
}

enum PetType {
  cat,
  smallDog,
  largeDog,
  rabbit,
  bird,
  all;

  String get dbValue {
    switch (this) {
      case PetType.cat:
        return 'cat';
      case PetType.smallDog:
        return 'small_dog';
      case PetType.largeDog:
        return 'large_dog';
      case PetType.rabbit:
        return 'rabbit';
      case PetType.bird:
        return 'bird';
      case PetType.all:
        return 'all';
    }
  }

  String get displayName {
    switch (this) {
      case PetType.cat:
        return 'Cat';
      case PetType.smallDog:
        return 'Small Dog';
      case PetType.largeDog:
        return 'Large Dog';
      case PetType.rabbit:
        return 'Rabbit';
      case PetType.bird:
        return 'Bird';
      case PetType.all:
        return 'All Pets';
    }
  }

  String get emoji {
    switch (this) {
      case PetType.cat:
        return '🐱';
      case PetType.smallDog:
        return '🐶';
      case PetType.largeDog:
        return '🐕';
      case PetType.rabbit:
        return '🐰';
      case PetType.bird:
        return '🐦';
      case PetType.all:
        return '🐾';
    }
  }

  static PetType fromDb(String value) {
    return PetType.values.firstWhere((e) => e.dbValue == value);
  }
}

enum AllowedZone {
  indoor,
  outdoor,
  both;

  String get displayName {
    switch (this) {
      case AllowedZone.indoor:
        return 'Indoor';
      case AllowedZone.outdoor:
        return 'Outdoor';
      case AllowedZone.both:
        return 'Indoor & Outdoor';
    }
  }
}

enum UserRole {
  contributor,
  editor,
  admin;

  bool get canEdit => this == UserRole.editor || this == UserRole.admin;
  bool get isAdmin => this == UserRole.admin;

  static UserRole fromDb(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.contributor,
    );
  }
}
