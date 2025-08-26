class StaffServiceReportModel {
  String? message;
  List<StaffServiceReportData>? data;

  StaffServiceReportModel({this.message, this.data});

  StaffServiceReportModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <StaffServiceReportData>[];
      json['data'].forEach((v) {
        data!.add(StaffServiceReportData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StaffServiceReportData {
  String? sId;
  num? commissionEarn;
  num? tipsEarn;
  int? services;
  num? totalEarning;
  String? staffId;
  String? staffName;
  String? staffImage;
  String? staffEmail;
  num? totalAmount;

  StaffServiceReportData(
      {this.sId,
      this.commissionEarn,
      this.tipsEarn,
      this.services,
      this.totalEarning,
      this.staffId,
      this.staffName,
      this.staffImage,
      this.staffEmail,
      this.totalAmount});

  StaffServiceReportData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    commissionEarn = json['commission_earn'];
    tipsEarn = json['tips_earn'];
    services = json['services'];
    totalEarning = json['total_earning'];
    staffId = json['staff_id'];
    staffName = json['staff_name'];
    staffImage = json['staff_image'];
    staffEmail = json['staff_email'];
    totalAmount = json['total_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['commission_earn'] = commissionEarn;
    data['tips_earn'] = tipsEarn;
    data['services'] = services;
    data['total_earning'] = totalEarning;
    data['staff_id'] = staffId;
    data['staff_name'] = staffName;
    data['staff_image'] = staffImage;
    data['staff_email'] = staffEmail;
    data['total_amount'] = totalAmount;
    return data;
  }
}
