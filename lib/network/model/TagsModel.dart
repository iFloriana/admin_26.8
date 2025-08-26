class Tags {
  String? message;
  Data? data;

  Tags({this.message, this.data});

  Tags.fromJson(Map<String, dynamic> json) {
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
  List<String>? branchId;
  String? name;
  int? status;
  String? salonId;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.branchId,
      this.name,
      this.status,
      this.salonId,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    branchId = json['branch_id'].cast<String>();
    name = json['name'];
    status = json['status'];
    salonId = json['salon_id'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['branch_id'] = this.branchId;
    data['name'] = this.name;
    data['status'] = this.status;
    data['salon_id'] = this.salonId;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
