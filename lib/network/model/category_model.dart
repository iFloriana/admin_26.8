class CategoryResponse {
  final String message;
  final List<Category> data;

  CategoryResponse({
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((category) => Category.fromJson(category))
              .toList() ??
          [],
    );
  }
}

class Category {
  final String id;
  final List<Branch> branchId;
  final String image_url;
  final String name;
  final List<Brand> brandId;
  final int status;
  final String salonId;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.branchId,
    required this.image_url,
    required this.name,
    required this.brandId,
    required this.status,
    required this.salonId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      branchId: (json['branch_id'] as List<dynamic>?)
              ?.map((branch) => Branch.fromJson(branch))
              .toList() ??
          [],
      image_url: json['image_url'] ?? '',
      name: json['name'] ?? '',
      brandId: (json['brand_id'] as List<dynamic>?)
              ?.map((brand) => Brand.fromJson(brand))
              .toList() ??
          [],
      status: json['status'] ?? 0,
      salonId: json['salon_id'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

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
  final String image_url;
  final int ratingStar;
  final int totalReview;
  final String createdAt;
  final String updatedAt;

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
    required this.image_url,
    required this.ratingStar,
    required this.totalReview,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';
    if (json['image_url'] is Map) {
      imageUrl = json['image_url']['data'] ?? '';
    } else if (json['image_url'] is String) {
      imageUrl = json['image_url'] ?? '';
    }
    return Branch(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      salonId: json['salon_id'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 0,
      contactEmail: json['contact_email'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      paymentMethod: List<String>.from(json['payment_method'] ?? []),
      serviceId: List<String>.from(json['service_id'] ?? []),
      address: json['address'] ?? '',
      landmark: json['landmark'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postal_code'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      image_url: imageUrl,
      ratingStar: json['rating_star'] ?? 0,
      totalReview: json['total_review'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class Brand {
  final String id;
  final List<String> branchId;
  final String image_url;
  final String name;
  final int status;
  final String salonId;
  final String createdAt;
  final String updatedAt;

  Brand({
    required this.id,
    required this.branchId,
    required this.image_url,
    required this.name,
    required this.status,
    required this.salonId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';
    if (json['image_url'] is Map) {
      imageUrl = json['image_url']['data'] ?? '';
    } else if (json['image_url'] is String) {
      imageUrl = json['image_url'] ?? '';
    }
    return Brand(
      id: json['_id'] ?? '',
      branchId: List<String>.from(json['branch_id'] ?? []),
      image_url: imageUrl,
      name: json['name'] ?? '',
      status: json['status'] ?? 0,
      salonId: json['salon_id'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
