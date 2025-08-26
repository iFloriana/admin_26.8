class Branch {
  String? id;
  String? name;

  Branch({this.id, this.name});

  Branch.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
  }
}

class ProductVariation {
  String? message;
  Data? data;

  ProductVariation({this.message, this.data});

  ProductVariation.fromJson(Map<String, dynamic> json) {
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
  List<Branch>? branchId;
  String? name;
  List<String>? value;
  String? type;
  int? status;
  String? salonId;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.branchId,
      this.name,
      this.value,
      this.type,
      this.status,
      this.salonId,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['branch_id'] != null && json['branch_id'] is List) {
      branchId =
          (json['branch_id'] as List).map((e) => Branch.fromJson(e)).toList();
    }
    name = json['name'];
    value = json['value'] != null ? List<String>.from(json['value']) : null;
    type = json['type'];
    status = json['status'];
    salonId = json['salon_id'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['branch_id'] = this.branchId?.map((b) => b.id).toList();
    data['name'] = this.name;
    data['value'] = this.value;
    data['type'] = this.type;
    data['status'] = this.status;
    data['salon_id'] = this.salonId;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
