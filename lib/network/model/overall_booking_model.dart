class OverallBookingModel {
  bool? success;
  List<OverallBookingData>? data;

  OverallBookingModel({this.success, this.data});

  OverallBookingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <OverallBookingData>[];
      json['data'].forEach((v) {
        data!.add(OverallBookingData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OverallBookingData {
  String? staffName;
  String? staffEmail;
  String? staffImage;
  String? appointmentDate;
  int? serviceCount;
  num? totalServiceAmount;
  num? taxAmount;
  num? tipsAmount;
  num? totalAmount;
  String? invoiceId;

  OverallBookingData(
      {this.staffName,
      this.staffEmail,
      this.staffImage,
      this.appointmentDate,
      this.serviceCount,
      this.totalServiceAmount,
      this.taxAmount,
      this.tipsAmount,
      this.totalAmount,
      this.invoiceId});

  OverallBookingData.fromJson(Map<String, dynamic> json) {
    staffName = json['staff_name'];
    staffEmail = json['staff_email'];
    staffImage = json['staff_image'];
    appointmentDate = json['appointment_date'];
    serviceCount = json['service_count'];
    totalServiceAmount = json['total_service_amount'];
    taxAmount = json['tax_amount'];
    tipsAmount = json['tips_amount'];
    totalAmount = json['total_amount'];
    invoiceId = json['invoice_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['staff_name'] = staffName;
    data['staff_email'] = staffEmail;
    data['staff_image'] = staffImage;
    data['appointment_date'] = appointmentDate;
    data['service_count'] = serviceCount;
    data['total_service_amount'] = totalServiceAmount;
    data['tax_amount'] = taxAmount;
    data['tips_amount'] = tipsAmount;
    data['total_amount'] = totalAmount;
    data['invoice_id'] = invoiceId;
    return data;
  }
}
