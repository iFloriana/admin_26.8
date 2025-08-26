import 'package:intl/intl.dart';

class StaffPayout {
  final String paymentDate;
  final String staffName;
  final num commissionAmount;
  final num tips;
  final String paymentType;
  final num totalPay;

  StaffPayout({
    required this.paymentDate,
    required this.staffName,
    required this.commissionAmount,
    required this.tips,
    required this.paymentType,
    required this.totalPay,
  });

  factory StaffPayout.fromJson(Map<String, dynamic> json) {
    return StaffPayout(
      paymentDate: json['payment_date'] ?? '',
      staffName: json['staff']?['name'] ?? '',
      commissionAmount: json['commission_amount'] ?? 0,
      tips: json['tips'] ?? 0,
      paymentType: json['payment_type'] ?? '',
      totalPay: json['total_pay'] ?? 0,
    );
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(paymentDate);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return paymentDate;
    }
  }
}
