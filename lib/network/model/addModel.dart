class AddBranch {
  String? message;
  Data? data;

  AddBranch({this.message, this.data});

  AddBranch.fromJson(Map<String, dynamic> json) {
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
  double? latitude;
  double? longitude;
  String? description;
  String? image;
  int? ratingStar;
  int? totalReview;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.name,
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
      this.latitude,
      this.longitude,
      this.description,
      this.image,
      this.ratingStar,
      this.totalReview,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
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
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
    description = json['description'];
    image = json['image'];
    ratingStar = json['rating_star'];
    totalReview = json['total_review'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['description'] = this.description;
    data['image'] = this.image;
    data['rating_star'] = this.ratingStar;
    data['total_review'] = this.totalReview;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
