class MakePayment {
  String? message;
  Payment? payment;
  String? invoicePdfUrl;

  MakePayment({this.message, this.payment, this.invoicePdfUrl});

  MakePayment.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    payment =
        json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
    invoicePdfUrl = json['invoice_pdf_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.payment != null) {
      data['payment'] = this.payment!.toJson();
    }
    data['invoice_pdf_url'] = this.invoicePdfUrl;
    return data;
  }
}

class Payment {
  String? salonId;
  String? branchId;
  String? appointmentId;
  int? serviceAmount;
  int? productAmount;
  int? subTotal;
  int? couponDiscount;
  int? additionalDiscount;
  int? additionalDiscountValue;
  int? taxAmount;
  int? tips;
  int? finalTotal;
  String? paymentMethod;
  String? sId;
  String? createdAt;
  int? iV;

  Payment(
      {this.salonId,
      this.branchId,
      this.appointmentId,
      this.serviceAmount,
      this.productAmount,
      this.subTotal,
      this.couponDiscount,
      this.additionalDiscount,
      this.additionalDiscountValue,
      this.taxAmount,
      this.tips,
      this.finalTotal,
      this.paymentMethod,
      this.sId,
      this.createdAt,
      this.iV});

  Payment.fromJson(Map<String, dynamic> json) {
    salonId = json['salon_id'];
    branchId = json['branch_id'];
    appointmentId = json['appointment_id'];
    serviceAmount = json['service_amount'];
    productAmount = json['product_amount'];
    subTotal = json['sub_total'];
    couponDiscount = json['coupon_discount'];
    additionalDiscount = json['additional_discount'];
    additionalDiscountValue = json['additional_discount_value'];
    taxAmount = json['tax_amount'];
    tips = json['tips'];
    finalTotal = json['final_total'];
    paymentMethod = json['payment_method'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['salon_id'] = this.salonId;
    data['branch_id'] = this.branchId;
    data['appointment_id'] = this.appointmentId;
    data['service_amount'] = this.serviceAmount;
    data['product_amount'] = this.productAmount;
    data['sub_total'] = this.subTotal;
    data['coupon_discount'] = this.couponDiscount;
    data['additional_discount'] = this.additionalDiscount;
    data['additional_discount_value'] = this.additionalDiscountValue;
    data['tax_amount'] = this.taxAmount;
    data['tips'] = this.tips;
    data['final_total'] = this.finalTotal;
    data['payment_method'] = this.paymentMethod;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['__v'] = this.iV;
    return data;
  }
}
