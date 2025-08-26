class BranchMemberShip {
  final String id;
  final String salonId;
  final String membershipName;
  final String description;
  final String subscriptionPlan;
  final int status;
  final int discount;
  final String discountType;
  final int membershipAmount;
  final SalonInfo? salonInfo;

  BranchMemberShip({
    required this.id,
    required this.salonId,
    required this.membershipName,
    required this.description,
    required this.subscriptionPlan,
    required this.status,
    required this.discount,
    required this.discountType,
    required this.membershipAmount,
    this.salonInfo,
  });

  factory BranchMemberShip.fromJson(Map<String, dynamic> json) {
    String salonIdValue = '';
    SalonInfo? salonInfoValue;
    if (json['salon_id'] is Map) {
      salonIdValue = json['salon_id']['_id']?.toString() ?? '';
      salonInfoValue = SalonInfo.fromJson(json['salon_id']);
    } else {
      salonIdValue = json['salon_id']?.toString() ?? '';
      salonInfoValue = null;
    }
    return BranchMemberShip(
      id: json['_id']?.toString() ?? '',
      salonId: salonIdValue,
      membershipName: json['membership_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      subscriptionPlan: json['subscription_plan']?.toString() ?? '',
      status: json['status'] ?? 0,
      discount: json['discount'] ?? 0,
      discountType: json['discount_type']?.toString() ?? '',
      membershipAmount: json['membership_amount'] ?? 0,
      salonInfo: salonInfoValue,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.id;
    data['salon_id'] = this.salonId;
    data['membership_name'] = this.membershipName;
    data['description'] = this.description;
    data['subscription_plan'] = this.subscriptionPlan;
    data['status'] = this.status;
    data['discount'] = this.discount;
    data['discount_type'] = this.discountType;
    data['membership_amount'] = this.membershipAmount;
    if (this.salonInfo != null) {
      data['salon_info'] = this.salonInfo!.toJson();
    }
    return data;
  }
}

class SalonInfo {
  final String id;
  final String salonName;
  final String description;
  final String address;
  final String contactNumber;
  final String contactEmail;
  final String openingTime;
  final String closingTime;
  final String category;
  final int status;
  final String image;

  SalonInfo({
    required this.id,
    required this.salonName,
    required this.description,
    required this.address,
    required this.contactNumber,
    required this.contactEmail,
    required this.openingTime,
    required this.closingTime,
    required this.category,
    required this.status,
    required this.image,
  });

  factory SalonInfo.fromJson(Map<String, dynamic> json) {
    return SalonInfo(
      id: json['_id']?.toString() ?? '',
      salonName: json['salon_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      contactEmail: json['contact_email']?.toString() ?? '',
      openingTime: json['opening_time']?.toString() ?? '',
      closingTime: json['closing_time']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      status: json['status'] ?? 0,
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.id;
    data['salon_name'] = this.salonName;
    data['description'] = this.description;
    data['address'] = this.address;
    data['contact_number'] = this.contactNumber;
    data['contact_email'] = this.contactEmail;
    data['opening_time'] = this.openingTime;
    data['closing_time'] = this.closingTime;
    data['category'] = this.category;
    data['status'] = this.status;
    data['image'] = this.image;
    return data;
  }
}
