import 'package:get/get.dart';

class Branch {
  final String id;
  final String name;
  final String salonId;
  final String category;
  final int status;
  final String contactEmail;
  final String contactNumber;
  final List<String> paymentMethod;
  final List<String> serviceId;
  final String address;
  final String landmark;
  final String country;
  final String state;
  final String city;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String description;
  final String image;
  final int ratingStar;
  final int totalReview;
  final DateTime createdAt;
  final DateTime updatedAt;

  Branch({
    required this.id,
    required this.name,
    required this.salonId,
    required this.category,
    required this.status,
    required this.contactEmail,
    required this.contactNumber,
    required this.paymentMethod,
    required this.serviceId,
    required this.address,
    required this.landmark,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.image,
    required this.ratingStar,
    required this.totalReview,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      salonId: json['salon_id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : 0,
      contactEmail: json['contact_email']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      paymentMethod: List<String>.from(json['payment_method']?.map((x) => x.toString()) ?? []),
      serviceId: List<String>.from(json['service_id']?.map((x) => x.toString()) ?? []),
      address: json['address']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      latitude: (json['latitude'] is num
          ? json['latitude']
          : double.tryParse(json['latitude']?.toString() ?? '0.0')) ?? 0.0,
      longitude: (json['longitude'] is num
          ? json['longitude']
          : double.tryParse(json['longitude']?.toString() ?? '0.0')) ?? 0.0,
      description: json['description']?.toString() ?? '',
      image: json['image_url']?.toString() ?? '',
      ratingStar: json['rating_star'] is int ? json['rating_star'] : 0,
      totalReview: json['total_review'] is int ? json['total_review'] : 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class Brand {
  final String id;
  final List<String> branchId;
  final String image;
  final String name;
  final int status;
  final String salonId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Brand({
    required this.id,
    required this.branchId,
    required this.image,
    required this.name,
    required this.status,
    required this.salonId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id']?.toString() ?? '',
      branchId: List<String>.from(json['branch_id']?.map((x) => x.toString()) ?? []),
      image: json['image_url']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : 0,
      salonId: json['salon_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}