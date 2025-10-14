class ProductSubCategory {
  final String id;
  final List<Branch> branchId;
  final String image;
  final String name;
  final ProductCategory productCategoryId;
  final List<Brand> brandId;
  final int status;
  final String salonId;
  final String createdAt;
  final String updatedAt;

  ProductSubCategory({
    required this.id,
    required this.branchId,
    required this.image,
    required this.name,
    required this.productCategoryId,
    required this.brandId,
    required this.status,
    required this.salonId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductSubCategory.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';
    if (json['image_url'] != null) {
      if (json['image_url'] is String) {
        imageUrl = json['image_url'].toString();
      } else if (json['image_url'] is Map &&
          json['image_url']['data'] != null) {
        imageUrl = json['image_url']['data'].toString();
      }
    }
    return ProductSubCategory(
      id: json['_id']?.toString() ?? '',
      branchId: (json['branch_id'] as List<dynamic>?)
              ?.map((branch) => Branch.fromJson(branch))
              .toList() ??
          [],
      image: imageUrl,
      name: json['name']?.toString() ?? '',
      productCategoryId:
          ProductCategory.fromJson(json['product_category_id'] ?? {}),
      brandId: (json['brand_id'] as List<dynamic>?)
              ?.map((brand) => Brand.fromJson(brand))
              .toList() ??
          [],
      status: json['status'] is int ? json['status'] : 0,
      salonId: json['salon_id']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
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
  final String image;
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
    required this.image,
    required this.ratingStar,
    required this.totalReview,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';
    if (json['image_url'] != null) {
      if (json['image_url'] is String) {
        imageUrl = json['image_url'].toString();
      } else if (json['image_url'] is Map &&
          json['image_url']['data'] != null) {
        imageUrl = json['image_url']['data'].toString();
      }
    }
    return Branch(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      salonId: json['salon_id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : 0,
      contactEmail: json['contact_email']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      paymentMethod: List<String>.from(
          json['payment_method']?.map((x) => x.toString()) ?? []),
      serviceId:
          List<String>.from(json['service_id']?.map((x) => x.toString()) ?? []),
      address: json['address']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      latitude: (json['latitude'] is num
              ? json['latitude']
              : double.tryParse(json['latitude']?.toString() ?? '0.0')) ??
          0.0,
      longitude: (json['longitude'] is num
              ? json['longitude']
              : double.tryParse(json['longitude']?.toString() ?? '0.0')) ??
          0.0,
      description: json['description']?.toString() ?? '',
      image: imageUrl,
      ratingStar: json['rating_star'] is int ? json['rating_star'] : 0,
      totalReview: json['total_review'] is int ? json['total_review'] : 0,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

class ProductCategory {
  final String id;
  final List<String> branchId;
  final String image;
  final String name;
  final List<String> brandId;
  final int status;
  final String salonId;
  final String createdAt;
  final String updatedAt;

  ProductCategory({
    required this.id,
    required this.branchId,
    required this.image,
    required this.name,
    required this.brandId,
    required this.status,
    required this.salonId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';
    if (json['image_url'] != null) {
      if (json['image_url'] is String) {
        imageUrl = json['image_url'].toString();
      } else if (json['image_url'] is Map &&
          json['image_url']['data'] != null) {
        imageUrl = json['image_url']['data'].toString();
      }
    }
    return ProductCategory(
      id: json['_id']?.toString() ?? '',
      branchId:
          List<String>.from(json['branch_id']?.map((x) => x.toString()) ?? []),
      image: imageUrl,
      name: json['name']?.toString() ?? '',
      brandId:
          List<String>.from(json['brand_id']?.map((x) => x.toString()) ?? []),
      status: json['status'] is int ? json['status'] : 0,
      salonId: json['salon_id']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
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
  final String createdAt;
  final String updatedAt;

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
    String imageUrl = '';
    if (json['image_url'] != null) {
      if (json['image_url'] is String) {
        imageUrl = json['image_url'].toString();
      } else if (json['image_url'] is Map &&
          json['image_url']['data'] != null) {
        imageUrl = json['image_url']['data'].toString();
      }
    }
    return Brand(
      id: json['_id']?.toString() ?? '',
      branchId:
          List<String>.from(json['branch_id']?.map((x) => x.toString()) ?? []),
      image: imageUrl,
      name: json['name']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : 0,
      salonId: json['salon_id']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}
