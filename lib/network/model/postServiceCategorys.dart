class PostServiceCategory {
  String? message;
  Data? data;

  PostServiceCategory({this.message, this.data});

  PostServiceCategory.fromJson(Map<String, dynamic> json) {
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
  int? serviceDuration;
  int? regularPrice;
  int? membersPrice;
  String? categoryId;
  String? description;
  int? status;
  String? salonId;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.image,
      this.name,
      this.serviceDuration,
      this.regularPrice,
      this.membersPrice,
      this.categoryId,
      this.description,
      this.status,
      this.salonId,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    name = json['name'];
    serviceDuration = json['service_duration'];
    regularPrice = json['regular_price'];
    membersPrice = json['members_price'];
    categoryId = json['category_id'];
    description = json['description'];
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
    data['service_duration'] = this.serviceDuration;
    data['regular_price'] = this.regularPrice;
    data['members_price'] = this.membersPrice;
    data['category_id'] = this.categoryId;
    data['description'] = this.description;
    data['status'] = this.status;
    data['salon_id'] = this.salonId;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
