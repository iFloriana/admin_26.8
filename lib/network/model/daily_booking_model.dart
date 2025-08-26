class DailyBookingModel {
  String? message;
  List<DailyBookingData>? data;

  DailyBookingModel({this.message, this.data});

  DailyBookingModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <DailyBookingData>[];
      json['data'].forEach((v) {
        data!.add(DailyBookingData.fromJson(v));
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

num? _toNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

class DailyBookingData {
  String? date;
  int? appointmentsCount;
  int? servicesCount;
  int? usedPackageCount;
  num? serviceAmount;
  num? productAmount;
  num? taxAmount;
  num? additionalCharges;
  num? tipsEarning;
  num? additionalDiscount;
  num? membershipDiscount;
  num? finalAmount;
  PaymentBreakdown? paymentBreakdown;

  DailyBookingData(
      {this.date,
      this.appointmentsCount,
      this.servicesCount,
      this.usedPackageCount,
      this.serviceAmount,
      this.productAmount,
      this.taxAmount,
      this.additionalCharges,
      this.tipsEarning,
      this.additionalDiscount,
      this.membershipDiscount,
      this.finalAmount,
      this.paymentBreakdown});

  DailyBookingData.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    appointmentsCount = json['appointmentsCount'] is String
        ? int.tryParse(json['appointmentsCount'])
        : json['appointmentsCount'];
    servicesCount = json['servicesCount'] is String
        ? int.tryParse(json['servicesCount'])
        : json['servicesCount'];
    usedPackageCount = json['usedPackageCount'] is String
        ? int.tryParse(json['usedPackageCount'])
        : json['usedPackageCount'];
    serviceAmount = _toNum(json['serviceAmount']);
    productAmount = _toNum(json['productAmount']);
    taxAmount = _toNum(json['taxAmount']);
    tipsEarning = _toNum(json['tipsEarning']);
    additionalCharges = _toNum(json['additionalCharges']);
    additionalDiscount = _toNum(json['additionalDiscount']);
    membershipDiscount = _toNum(json['membershipDiscount']);
    finalAmount = _toNum(json['finalAmount']);
    paymentBreakdown = json['paymentBreakdown'] is Map<String, dynamic>
        ? PaymentBreakdown.fromJson(json['paymentBreakdown'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['appointmentsCount'] = appointmentsCount;
    data['servicesCount'] = servicesCount;
    data['usedPackageCount'] = usedPackageCount;
    data['serviceAmount'] = serviceAmount;
    data['productAmount'] = productAmount;
    data['taxAmount'] = taxAmount;
    data['additionalCharges'] = additionalCharges;
    data['tipsEarning'] = tipsEarning;
    data['additionalDiscount'] = additionalDiscount;
    data['membershipDiscount'] = membershipDiscount;
    data['finalAmount'] = finalAmount;
    if (paymentBreakdown != null) {
      data['paymentBreakdown'] = paymentBreakdown!.toJson();
    }
    return data;
  }
}

class PaymentBreakdown {
  num? cash;
  num? card;
  num? upi;

  PaymentBreakdown({this.cash, this.card, this.upi});

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdown(
      cash: _toNum(json['cash']),
      card: _toNum(json['card']),
      upi: _toNum(json['upi']),
    );
  }

  Map<String, dynamic> toJson() => {
        'cash': cash,
        'card': card,
        'upi': upi,
      };
}
