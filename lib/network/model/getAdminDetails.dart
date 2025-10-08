class GetAdminDetails {
  final Admin? admin;
  final SalonDetails? salonDetails;

  GetAdminDetails({this.admin, this.salonDetails});

  factory GetAdminDetails.fromJson(Map<String, dynamic> json) {
    return GetAdminDetails(
      admin: json['admin'] != null ? Admin.fromJson(json['admin']) : null,
      salonDetails: json['salonDetails'] != null
          ? SalonDetails.fromJson(json['salonDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin': admin?.toJson(),
      'salonDetails': salonDetails?.toJson(),
    };
  }
}

class Admin {
  final String? id;
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final List<AdminPackage>? packageId;
  final String? password;
  final int? v;
  final String? updatedAt;

  Admin({
    this.id,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.address,
    this.packageId,
    this.password,
    this.v,
    this.updatedAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['_id'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
      packageId: json['package_id'] != null
          ? (json['package_id'] as List)
              .map((e) => AdminPackage.fromJson(e))
              .toList()
          : [],
      password: json['password'],
      v: json['__v'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'package_id': packageId?.map((e) => e.toJson()).toList(),
      'password': password,
      '__v': v,
      'updatedAt': updatedAt,
    };
  }
}

class AdminPackage {
  final PackageDetails? packageId;
  final String? packageStartDate;
  final String? packageExpirationDate;
  final int? status;
  final String? id;
  final String? buffer; // For entries that only contain buffer

  AdminPackage({
    this.packageId,
    this.packageStartDate,
    this.packageExpirationDate,
    this.status,
    this.id,
    this.buffer,
  });

  factory AdminPackage.fromJson(Map<String, dynamic> json) {
    return AdminPackage(
      packageId: json['package_id'] != null &&
              json['package_id'] is Map<String, dynamic>
          ? PackageDetails.fromJson(json['package_id'])
          : null,
      packageStartDate: json['package_start_date'],
      packageExpirationDate: json['package_expiration_date'],
      status: json['status'],
      id: json['_id'],
      buffer: json['buffer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId?.toJson(),
      'package_start_date': packageStartDate,
      'package_expiration_date': packageExpirationDate,
      'status': status,
      '_id': id,
      'buffer': buffer,
    };
  }
}

class PackageDetails {
  final String? status;
  final String? id;
  final String? packageName;
  final String? description;
  final num? price;
  final List<String>? servicesIncluded;
  final String? subscriptionPlan;
  final String? expirationDate;
  final int? v;

  PackageDetails({
    this.status,
    this.id,
    this.packageName,
    this.description,
    this.price,
    this.servicesIncluded,
    this.subscriptionPlan,
    this.expirationDate,
    this.v,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) {
    return PackageDetails(
      status: json['status'],
      id: json['_id'],
      packageName: json['package_name'],
      description: json['description'],
      price: json['price'],
      servicesIncluded: json['services_included'] != null
          ? List<String>.from(json['services_included'])
          : [],
      subscriptionPlan: json['subscription_plan'],
      expirationDate: json['expiration_date'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      '_id': id,
      'package_name': packageName,
      'description': description,
      'price': price,
      'services_included': servicesIncluded,
      'subscription_plan': subscriptionPlan,
      'expiration_date': expirationDate,
      '__v': v,
    };
  }
}

class SalonDetails {
  final String? id;
  final String? salonName;
  final String? description;
  final String? address;
  final String? contactNumber;
  final String? contactEmail;
  final String? openingTime;
  final String? closingTime;
  final String? category;
  final int? status;
  final String? packageId;
  final String? signupId;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final String? gstNumber;
  final String? imageUrl;

  SalonDetails({
    this.id,
    this.salonName,
    this.description,
    this.address,
    this.contactNumber,
    this.contactEmail,
    this.openingTime,
    this.closingTime,
    this.category,
    this.status,
    this.packageId,
    this.signupId,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.gstNumber,
    this.imageUrl,
  });

  factory SalonDetails.fromJson(Map<String, dynamic> json) {
    return SalonDetails(
      id: json['_id'],
      salonName: json['salon_name'],
      description: json['description'],
      address: json['address'],
      contactNumber: json['contact_number'],
      contactEmail: json['contact_email'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      category: json['category'],
      status: json['status'],
      packageId: json['package_id'],
      signupId: json['signup_id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      gstNumber: json['gst_number'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'salon_name': salonName,
      'description': description,
      'address': address,
      'contact_number': contactNumber,
      'contact_email': contactEmail,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'category': category,
      'status': status,
      'package_id': packageId,
      'signup_id': signupId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'gst_number': gstNumber,
      'image_url': imageUrl,
    };
  }
}
