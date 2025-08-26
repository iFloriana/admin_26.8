class AddCoupons {
  String? message;
  Data? data;

  AddCoupons({this.message, this.data});

  AddCoupons.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? image;
  String? name;
  List<String>? branchId;
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
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.image,
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
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    name = json['name'];
    branchId = json['branch_id'].cast<String>();
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
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['name'] = this.name;
    data['branch_id'] = this.branchId;
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
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
