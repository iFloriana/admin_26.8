class CustomerPackageReportModel {
  String? message;
  List<CustomerPackageReportData>? data;

  CustomerPackageReportModel({this.message, this.data});

  CustomerPackageReportModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <CustomerPackageReportData>[];
      json['data'].forEach((v) {
        data!.add(CustomerPackageReportData.fromJson(v));
      });
    }
  }
}

class CustomerPackageReportData {
  String? id;
  String? image;
  String? fullName;
  String? email;
  List<BranchPackage>? branchPackage;
  String? branchPackageValidTill;
  String? branchPackageBoughtAt;

  CustomerPackageReportData({
    this.id,
    this.image,
    this.fullName,
    this.email,
    this.branchPackage,
    this.branchPackageValidTill,
    this.branchPackageBoughtAt,
  });

  CustomerPackageReportData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    image = json['image'];
    fullName = json['full_name'];
    email = json['email'];
    branchPackageValidTill = json['branch_package_valid_till']?.toString();
    branchPackageBoughtAt = json['branch_package_bought_at']?.toString();
    if (json['branch_package'] != null) {
      branchPackage = <BranchPackage>[];
      json['branch_package'].forEach((v) {
        branchPackage!.add(BranchPackage.fromJson(v));
      });
    }
  }
}

class BranchPackage {
  String? id;
  String? packageName;
  num? packagePrice;
  int? status;

  BranchPackage({this.id, this.packageName, this.packagePrice, this.status});

  BranchPackage.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    packageName = json['package_name'];
    packagePrice = json['package_price'];
    status = json['status'];
  }
}
