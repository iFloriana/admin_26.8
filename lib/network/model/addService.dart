class AddService {
  String? message;
  Data? data;

  AddService({this.message, this.data});

  AddService.fromJson(Map<String, dynamic> json) {
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
  String? sId;
  String? image;
  String? name;
  int? serviceDuration;
  int? regularPrice;
  int? membersPrice;
  String? categoryId;
  String? description;
  int? status;
  String? salonId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.image,
      this.name,
      this.serviceDuration,
      this.regularPrice,
      this.membersPrice,
      this.categoryId,
      this.description,
      this.status,
      this.salonId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    image = json['image'];
    name = json['name'];
    serviceDuration = json['service_duration'];
    regularPrice = json['regular_price'];
    membersPrice = json['members_price'];
    categoryId = json['category_id'];
    description = json['description'];
    status = json['status'];
    salonId = json['salon_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['image'] = this.image;
    data['name'] = this.name;
    data['service_duration'] = this.serviceDuration;
    data['regular_price'] = this.regularPrice;
    data['members_price'] = this.membersPrice;
    data['category_id'] = this.categoryId;
    data['description'] = this.description;
    data['status'] = this.status;
    data['salon_id'] = this.salonId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
