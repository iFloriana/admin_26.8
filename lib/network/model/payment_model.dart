class PaymentModel {
  final String? message;
  final List<PaymentData>? data;

  PaymentModel({this.message, this.data});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      message: json['message']?.toString(),
      data: json['data'] != null
          ? List<PaymentData>.from(
              json['data'].map((x) => PaymentData.fromJson(x)))
          : null,
    );
  }
}

num? _toNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

class PaymentData {
  final num? additionalCharges;
  final String? id;
  final String? appointmentId;
  final num? serviceAmount;
  final num? productAmount;
  final num? packageDiscount;
  final String? couponId;
  final num? couponDiscount;
  final String? additionalDiscountType;
  final String? taxId;
  final num? taxAmount;
  final num? tips;
  final num? subTotal;
  final num? finalTotal;
  final String? paymentMethod;
  final SalonId? salonId;
  final String? createdAt;
  final String? updatedAt;
  final num? v;
  final num? additionalDiscount;
  final String? invoicePdfUrl;
  final String? invoiceFileName;
  final num? serviceCount;
  final List<StaffTip>? staffTips;
  final num? membershipDiscount;
  final String? membershipDiscountType;

  PaymentData({
    this.additionalCharges,
    this.id,
    this.appointmentId,
    this.serviceAmount,
    this.productAmount,
    this.packageDiscount,
    this.couponId,
    this.couponDiscount,
    this.additionalDiscountType,
    this.taxId,
    this.taxAmount,
    this.tips,
    this.subTotal,
    this.finalTotal,
    this.paymentMethod,
    this.salonId,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.additionalDiscount,
    this.invoicePdfUrl,
    this.invoiceFileName,
    this.serviceCount,
    this.staffTips,
    this.membershipDiscount,
    this.membershipDiscountType,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      additionalCharges: _toNum(json['additional_charges']),
      id: json['_id']?.toString(),
      appointmentId: json['appointment_id'] is Map
          ? (json['appointment_id']['_id']?.toString())
          : json['appointment_id']?.toString(),
      serviceAmount: _toNum(json['service_amount']),
      productAmount: _toNum(json['product_amount']),
      packageDiscount: _toNum(json['package_discount']),
      couponId: json['coupon_id'] is Map
          ? (json['coupon_id']['_id']?.toString())
          : json['coupon_id']?.toString(),
      couponDiscount: _toNum(json['coupon_discount']),
      additionalDiscountType: json['additional_discount_type'],
      taxId: json['tax_id'] is Map
          ? (json['tax_id']['_id']?.toString())
          : json['tax_id']?.toString(),
      taxAmount: _toNum(json['tax_amount']),
      tips: _toNum(json['tips']),
      subTotal: _toNum(json['sub_total']),
      finalTotal: _toNum(json['final_total']),
      paymentMethod: json['payment_method']?.toString(),
      salonId: json['salon_id'] == null
          ? null
          : (json['salon_id'] is Map<String, dynamic>
              ? SalonId.fromJson(json['salon_id'])
              : SalonId(id: json['salon_id']?.toString())),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      v: json['__v'],
      additionalDiscount: _toNum(json['additional_discount']),
      invoicePdfUrl: json['invoice_pdf_url'] is Map
          ? (json['invoice_pdf_url']['url']?.toString() ??
              json['invoice_pdf_url']['path']?.toString() ??
              json['invoice_pdf_url']['file']?.toString())
          : json['invoice_pdf_url']?.toString(),
      invoiceFileName: json['invoice_file_name']?.toString(),
      serviceCount: _toNum(json['service_count']),
      staffTips: json['staff_tips'] is List
          ? List<StaffTip>.from(
              (json['staff_tips'] as List).map((x) => StaffTip.fromJson(x)))
          : null,
      membershipDiscount: _toNum(
          json['branch_membership_discount'] ?? json['membership_discount']),
      membershipDiscountType: (json['branch_membership_discount_type'] ??
              json['membership_discount_type'])
          ?.toString(),
    );
  }

  String get formattedDate {
    if (createdAt == null) return '';
    try {
      final date = DateTime.parse(createdAt!);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return createdAt!;
    }
  }

  String get invoiceId {
    if (id == null) return '';
    final parsedDate =
        DateTime.tryParse(createdAt ?? DateTime.now().toIso8601String()) ??
            DateTime.now();
    final suffix = id!.length >= 2 ? id!.substring(id!.length - 2) : id!;
    return 'IFL-${parsedDate.year}${parsedDate.month.toString().padLeft(2, '0')}-${suffix}';
  }
}

class SalonId {
  final String? id;

  SalonId({this.id});

  factory SalonId.fromJson(Map<String, dynamic> json) {
    return SalonId(id: json['_id']);
  }
}

class StaffTip {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? image;
  final num? tip;

  StaffTip({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.image,
    this.tip,
  });

  factory StaffTip.fromJson(Map<String, dynamic> json) {
    return StaffTip(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      image: json['image']?.toString(),
      tip: _toNum(json['tip']),
    );
  }
}
