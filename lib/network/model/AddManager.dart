class AddManaget {
  String? message;
  Data? data;

  AddManaget({this.message, this.data});

  AddManaget.fromJson(Map<String, dynamic> json) {
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
  String? firstName;
  String? lastName;
  String? image;
  String? email;
  String? contactNumber;
  String? password;
  String? gender;
  String? branchId;
  String? salonId;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.firstName,
      this.lastName,
      this.image,
      this.email,
      this.contactNumber,
      this.password,
      this.gender,
      this.branchId,
      this.salonId,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    image = json['image'];
    email = json['email'];
    contactNumber = json['contact_number'];
    password = json['password'];
    gender = json['gender'];
    branchId = json['branch_id'];
    salonId = json['salon_id'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['image'] = this.image;
    data['email'] = this.email;
    data['contact_number'] = this.contactNumber;
    data['password'] = this.password;
    data['gender'] = this.gender;
    data['branch_id'] = this.branchId;
    data['salon_id'] = this.salonId;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
