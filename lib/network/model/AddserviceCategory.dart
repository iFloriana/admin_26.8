// class CreateServiceCategory {
//   String? message;
//   Data? data;

//   CreateServiceCategory({this.message, this.data});

//   CreateServiceCategory.fromJson(Map<String, dynamic> json) {
//     message = json['message'];
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }

// class Data {
//   String? salonId;
//   String? name;
//   int? status;
//   String? sId;
//   String? createdAt;
//   String? updatedAt;
//   int? iV;

//   Data(
//       {this.salonId,
//       this.name,
//       this.status,
//       this.sId,
//       this.createdAt,
//       this.updatedAt,
//       this.iV});

//   Data.fromJson(Map<String, dynamic> json) {
//     salonId = json['salon_id'];
//     name = json['name'];
//     status = json['status'];
//     sId = json['_id'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     iV = json['__v'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['salon_id'] = this.salonId;
//     data['name'] = this.name;
//     data['status'] = this.status;
//     data['_id'] = this.sId;
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['__v'] = this.iV;
//     return data;
//   }
// }
