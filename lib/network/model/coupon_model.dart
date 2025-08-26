class CouponModel {
  String? message;
  List<Data>? data;

  CouponModel({this.message, this.data});

  CouponModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  List<BranchId>? branchId;
  String? description;
  String? startDate;
  String? endDate;
  String? couponType;
  String? couponCode;
  String? discountType;
  int? discountAmount;
  int? useLimit;
  int? status;
  String? salonId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? imageUrl;

  Data(
      {this.sId,
      this.name,
      this.branchId,
      this.description,
      this.startDate,
      this.endDate,
      this.couponType,
      this.couponCode,
      this.discountType,
      this.discountAmount,
      this.useLimit,
      this.status,
      this.salonId,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.imageUrl});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    if (json['branch_id'] != null) {
      branchId = <BranchId>[];
      json['branch_id'].forEach((v) {
        branchId!.add(new BranchId.fromJson(v));
      });
    }
    description = json['description'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    couponType = json['coupon_type'];
    couponCode = json['coupon_code'];
    discountType = json['discount_type'];
    discountAmount = json['discount_amount'];
    useLimit = json['use_limit'];
    status = json['status'];
    salonId = json['salon_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    if (this.branchId != null) {
      data['branch_id'] = this.branchId!.map((v) => v.toJson()).toList();
    }
    data['description'] = this.description;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['coupon_type'] = this.couponType;
    data['coupon_code'] = this.couponCode;
    data['discount_type'] = this.discountType;
    data['discount_amount'] = this.discountAmount;
    data['use_limit'] = this.useLimit;
    data['status'] = this.status;
    data['salon_id'] = this.salonId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['image_url'] = this.imageUrl;
    return data;
  }
}

class BranchId {
  Image? image;
  String? sId;
  String? name;
  String? salonId;
  String? category;
  int? status;
  String? contactEmail;
  String? contactNumber;
  List<String>? paymentMethod;
  List<String>? serviceId;
  String? address;
  String? landmark;
  String? country;
  String? state;
  String? city;
  String? postalCode;
  String? description;
  int? ratingStar;
  int? totalReview;
  String? createdAt;
  String? updatedAt;
  int? iV;

  BranchId(
      {this.image,
      this.sId,
      this.name,
      this.salonId,
      this.category,
      this.status,
      this.contactEmail,
      this.contactNumber,
      this.paymentMethod,
      this.serviceId,
      this.address,
      this.landmark,
      this.country,
      this.state,
      this.city,
      this.postalCode,
      this.description,
      this.ratingStar,
      this.totalReview,
      this.createdAt,
      this.updatedAt,
      this.iV});

  BranchId.fromJson(Map<String, dynamic> json) {
    image = json['image'] != null ? new Image.fromJson(json['image']) : null;
    sId = json['_id'];
    name = json['name'];
    salonId = json['salon_id'];
    category = json['category'];
    status = json['status'];
    contactEmail = json['contact_email'];
    contactNumber = json['contact_number'];
    paymentMethod = json['payment_method'].cast<String>();
    serviceId = json['service_id'].cast<String>();
    address = json['address'];
    landmark = json['landmark'];
    country = json['country'];
    state = json['state'];
    city = json['city'];
    postalCode = json['postal_code'];
    description = json['description'];
    ratingStar = json['rating_star'];
    totalReview = json['total_review'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.image != null) {
      data['image'] = this.image!.toJson();
    }
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['salon_id'] = this.salonId;
    data['category'] = this.category;
    data['status'] = this.status;
    data['contact_email'] = this.contactEmail;
    data['contact_number'] = this.contactNumber;
    data['payment_method'] = this.paymentMethod;
    data['service_id'] = this.serviceId;
    data['address'] = this.address;
    data['landmark'] = this.landmark;
    data['country'] = this.country;
    data['state'] = this.state;
    data['city'] = this.city;
    data['postal_code'] = this.postalCode;
    data['description'] = this.description;
    data['rating_star'] = this.ratingStar;
    data['total_review'] = this.totalReview;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Image {
  String? data;
  String? contentType;
  String? originalName;
  String? extension;

  Image({this.data, this.contentType, this.originalName, this.extension});

  Image.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    contentType = json['contentType'];
    originalName = json['originalName'];
    extension = json['extension'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = this.data;
    data['contentType'] = this.contentType;
    data['originalName'] = this.originalName;
    data['extension'] = this.extension;
    return data;
  }
}
