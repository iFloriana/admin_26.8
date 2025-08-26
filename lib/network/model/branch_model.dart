class BranchModel {
  final String id;
  final String name;
  final Salon? salon;
  final String category;
  final int status;
  final String contactEmail;
  final String contactNumber;
  final List<String> paymentMethods;
  final List<Service> services;
  final String address;
  final String landmark;
  final String country;
  final String state;
  final String city;
  final String postalCode;
  final String description;
  final int ratingStar;
  final int totalReview;
  final int staffCount;
  final String imageUrl;

  BranchModel({
    required this.id,
    required this.name,
    required this.salon,
    required this.category,
    required this.status,
    required this.contactEmail,
    required this.contactNumber,
    required this.paymentMethods,
    required this.services,
    required this.address,
    required this.landmark,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
    required this.description,
    required this.ratingStar,
    required this.totalReview,
    required this.staffCount,
    required this.imageUrl,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      salon: json['salon_id'] != null && json['salon_id'] is Map
          ? Salon.fromJson(json['salon_id'])
          : null,
      category: json['category'] ?? '',
      status: json['status'] ?? 0,
      contactEmail: json['contact_email'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      paymentMethods: (json['payment_method'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      services: (json['service_id'] as List<dynamic>?)
              ?.map((e) => Service.fromJson(e))
              .toList() ??
          [],
      address: json['address'] ?? '',
      landmark: json['landmark'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postal_code'] ?? '',
      description: json['description'] ?? '',
      ratingStar: json['rating_star'] ?? 0,
      totalReview: json['total_review'] ?? 0,
      staffCount: json['staff_count'] ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class Salon {
  final String id;
  final String salonName;
  final String imageName;

  Salon({
    required this.id,
    required this.salonName,
    required this.imageName,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    String imageName = '';
    if (json['image'] != null &&
        json['image'] is Map &&
        json['image']['originalName'] != null) {
      imageName = json['image']['originalName'];
    }
    return Salon(
      id: json['_id'] ?? '',
      salonName: json['salon_name'] ?? '',
      imageName: imageName,
    );
  }
}

class Service {
  final String id;
  final String name;
  final int serviceDuration;
  final int regularPrice;
  final String? categoryName;

  Service({
    required this.id,
    required this.name,
    required this.serviceDuration,
    required this.regularPrice,
    this.categoryName,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      serviceDuration: json['service_duration'] ?? 0,
      regularPrice: json['regular_price'] ?? 0,
      categoryName: json['category_id'] != null && json['category_id'] is Map
          ? json['category_id']['name']
          : null,
    );
  }
}
