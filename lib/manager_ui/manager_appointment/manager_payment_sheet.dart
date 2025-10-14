import 'package:flutter/material.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/manager_ui/manager_appointment/manager_appointmentController.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/colors.dart';
import '../../../wiget/Custome_button.dart';
import '../../../wiget/appbar/commen_appbar.dart';
import '../../../wiget/custome_snackbar.dart';
import '../../../main.dart';
import '../../../network/network_const.dart';

class ManagerPaymentSummaryScreen extends StatefulWidget {
  final dynamic a;

  const ManagerPaymentSummaryScreen({Key? key, required this.a})
      : super(key: key);

  @override
  State<ManagerPaymentSummaryScreen> createState() =>
      _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<ManagerPaymentSummaryScreen> {
  final controller = Get.find<ManagerAppointmentcontroller>();
  final _additionalChargesCtrl = TextEditingController(text: '0');
  String _invoiceFormat = 'gst_invoice';
  bool _showAdditionalCharges = false;
  List<Map<String, String>> _splitPayments = [
    {"method": '', "amount": ''},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = controller.paymentSummaryState;
      state.selectedTax.value = null;
      state.paymentMethod.value = '';
      state.discountType.value = '';
    });
  }

  double getServiceAmount() {
    if (widget.a is! Map) {
      return (widget.a.amount ?? 0).toDouble();
    }
    final appointmentMap = widget.a as Map<String, dynamic>;
    return (appointmentMap['service_total_amount'] ?? 0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final state = controller.paymentSummaryState;

    return Scaffold(
      appBar: CustomAppBar(title: "Payment Summary"),
      drawer: ManagerDrawerScreen(),
      body: Obx(() {
        final selectedTax = state.selectedTax.value;
        final tips = double.tryParse(state.tips.value) ?? 0.0;
        final paymentMethod = state.paymentMethod.value;
        final couponMap = controller.appliedCoupon.value;
        final isCouponApplied = controller.couponApplied.value;
        final addAdditionalDiscount = state.addAdditionalDiscount.value;
        final discountType = state.discountType.value;
        final discountValue = double.tryParse(state.discountValue.value) ?? 0.0;

        Map<String, dynamic>? appointmentMap =
            (widget.a is Map) ? widget.a as Map<String, dynamic> : null;
        List<dynamic> packageAndMembership = [];
        if (appointmentMap != null) {
          final customer = appointmentMap['customer'];
          if (customer is Map<String, dynamic>) {
            final pam = customer['package_and_membership'];
            if (pam is List) packageAndMembership = pam;
          }
        }

        double derivedMemberDiscount = 0.0;
        String? derivedMemberType;
        if (packageAndMembership.isNotEmpty) {
          final now = DateTime.now();
          final memberships = packageAndMembership.where((item) {
            if (item is! Map) return false;
            final hasMembership = item['branch_membership'] != null;
            final end = item['end_date'];
            DateTime? endDate;
            if (end is String) {
              endDate = DateTime.tryParse(end);
            }
            return hasMembership && (endDate == null || !endDate.isBefore(now));
          }).toList();
          if (memberships.isNotEmpty) {
            final m = memberships.first as Map;
            final disc = m['discount'];
            final dtype = m['discount_type'];
            derivedMemberDiscount = (disc is num)
                ? disc.toDouble()
                : double.tryParse('$disc') ?? 0.0;
            derivedMemberType = (dtype is String) ? dtype : dtype?.toString();
          }
        }

        bool hasActivePackage = false;
        if (packageAndMembership.isNotEmpty) {
          final now = DateTime.now();
          hasActivePackage = packageAndMembership.any((item) {
            if (item is! Map) return false;
            final branchPackage = item['branch_package'];
            final hasPackage =
                branchPackage is List && branchPackage.isNotEmpty;
            final end = item['end_date'];
            DateTime? endDate;
            if (end is String) {
              endDate = DateTime.tryParse(end);
            }
            return hasPackage && (endDate == null || !endDate.isBefore(now));
          });
        }

        final memberDiscount = packageAndMembership.isNotEmpty
            ? derivedMemberDiscount
            : (widget.a.branchMembershipDiscount ?? 0.0).toDouble();
        final memberType = packageAndMembership.isNotEmpty
            ? derivedMemberType
            : widget.a.branchMembershipDiscountType;

        double productTotal = 0.0;
        List<dynamic> productsList = const [];
        if (widget.a is Map && (widget.a as Map).containsKey('products')) {
          final dynamic raw = (widget.a as Map)['products'];
          if (raw is List) {
            productsList = raw;
          }
        }
        if (productsList.isNotEmpty) {
          for (final p in productsList) {
            final qty = (p['quantity'] ?? 0) as num;
            final price = (p['unit_price'] ?? 0) as num;
            productTotal += (qty * price).toDouble();
          }
        }

        final double serviceAmount = (widget.a.amount ?? 0).toDouble();
        final double additionalCharges = _showAdditionalCharges
            ? (double.tryParse(_additionalChargesCtrl.text) ?? 0)
            : 0;
        double amountForDiscountsAndTax = serviceAmount + additionalCharges;

        double membershipDeduction = 0;
        if (memberDiscount > 0) {
          final isPercent =
              (memberType ?? '').toLowerCase().startsWith('percent');
          membershipDeduction = isPercent
              ? (memberDiscount * amountForDiscountsAndTax / 100.0)
              : memberDiscount;
        }
        amountForDiscountsAndTax -= membershipDeduction;

        double couponDeduction = 0;
        if (couponMap != null) {
          final String cType =
              (couponMap['discount_type'] ?? '').toString().toLowerCase();
          final num cAmount = (couponMap['discount_amount'] ?? 0) as num;
          couponDeduction = cType == 'percent'
              ? (cAmount.toDouble() * amountForDiscountsAndTax / 100.0)
              : cAmount.toDouble();
        }
        amountForDiscountsAndTax -= couponDeduction;

        double additionalDeduction = 0;
        if (addAdditionalDiscount && discountValue > 0) {
          final isPercent = discountType.toLowerCase().startsWith('percent');
          additionalDeduction = isPercent
              ? (discountValue * amountForDiscountsAndTax / 100.0)
              : discountValue;
        }
        amountForDiscountsAndTax -= additionalDeduction;

        amountForDiscountsAndTax =
            amountForDiscountsAndTax < 0 ? 0 : amountForDiscountsAndTax;

        double taxAmount = 0;
        if (selectedTax != null) {
          taxAmount = amountForDiscountsAndTax * (selectedTax.value / 100.0);
        }

        double serviceTotal = amountForDiscountsAndTax + taxAmount;
        serviceTotal += tips;
        final grandTotal = serviceTotal + productTotal;
        state.grandTotal.value = grandTotal < 0 ? 0 : grandTotal;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Customer Details",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Name: ${widget.a.clientName}",
                      style: const TextStyle(color: Colors.black87)),
                  Text("Date: ${widget.a.date}",
                      style: TextStyle(color: Colors.black87, fontSize: 14.sp)),
                ],
              ),
              Text("Phone: ${widget.a.clientPhone ?? ''}",
                  style: const TextStyle(color: Colors.black87)),
              Text("Service Amount: ₹ $serviceAmount",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500)),
              if (productsList.isNotEmpty) ...[
                const Text('Product Details',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 6),
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                    3: FlexColumnWidth(),
                  },
                  children: [
                    const TableRow(children: [
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Product',
                              style: TextStyle(fontWeight: FontWeight.w600))),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Qty',
                              style: TextStyle(fontWeight: FontWeight.w600))),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Price (₹)',
                              style: TextStyle(fontWeight: FontWeight.w600))),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Total (₹)',
                              style: TextStyle(fontWeight: FontWeight.w600))),
                    ]),
                    ...(productsList.map<TableRow>((prod) {
                      final name = prod['name'] ?? '';
                      final qty = (prod['quantity'] ?? 0).toString();
                      final price = (prod['unit_price'] ?? 0).toString();
                      final total =
                          ((prod['quantity'] ?? 0) * (prod['unit_price'] ?? 0))
                              .toString();
                      return TableRow(children: [
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(name)),
                        Padding(
                            padding: const EdgeInsets.all(8), child: Text(qty)),
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(price)),
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(total)),
                      ]);
                    }).toList()),
                  ],
                ),
              ],
              Divider(color: Colors.grey[400]),
              Text("Billing Details",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor)),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          value: state.selectedTax.value,
                          items: controller.taxes
                              .map((tax) => DropdownMenuItem(
                                    value: tax,
                                    child: Text('${tax.title} (${tax.value}%)'),
                                  ))
                              .toList(),
                          onChanged: (val) => state.selectedTax.value = val,
                          decoration: const InputDecoration(
                            labelText: "Tax",
                            labelStyle: TextStyle(color: grey),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: grey, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide:
                                  BorderSide(color: primaryColor, width: 2.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: red, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: state.tips.value,
                          onChanged: (val) => state.tips.value = val,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Tips (₹)",
                            labelStyle: TextStyle(color: grey),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: grey, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide:
                                  BorderSide(color: primaryColor, width: 2.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: red, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: state.couponCode.value,
                          onChanged: (val) => state.couponCode.value = val,
                          decoration: InputDecoration(
                            labelText: "Coupon Code",
                            labelStyle: const TextStyle(color: grey),
                            suffixIcon: isCouponApplied
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : IconButton(
                                    icon: const Icon(Icons.qr_code_scanner,
                                        color: grey),
                                    onPressed: () async {
                                      // Implement QR code scanning logic if needed
                                    },
                                  ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: grey, width: 1.0),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide:
                                  BorderSide(color: primaryColor, width: 2.0),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: red, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          if (state.couponCode.value.isNotEmpty) {
                            await controller
                                .applyCoupon(state.couponCode.value);
                            setState(() {});
                          } else {
                            CustomSnackbar.showError(
                                'Error', 'Please enter a coupon code');
                          }
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: state.paymentMethod.value.isEmpty
                        ? null
                        : state.paymentMethod.value,
                    items: ["Cash", "Card", "UPI", "Split"]
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      state.paymentMethod.value = val ?? '';
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: "Payment Method",
                      labelStyle: TextStyle(color: grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: primaryColor, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: red, width: 1.0),
                      ),
                    ),
                  ),
                  if (state.paymentMethod.value == 'Split') ...[
                    const SizedBox(height: 12),
                    ..._splitPayments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final split = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: split['method']!.isEmpty
                                  ? null
                                  : split['method'],
                              items: ["Cash", "Card", "UPI"]
                                  .map((m) => DropdownMenuItem(
                                      value: m, child: Text(m)))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _splitPayments[index]['method'] = val ?? '';
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: "Method",
                                labelStyle: TextStyle(color: grey),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  borderSide:
                                      BorderSide(color: grey, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: split['amount'],
                              onChanged: (val) {
                                setState(() {
                                  _splitPayments[index]['amount'] = val;
                                });
                              },
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Amount",
                                labelStyle: TextStyle(color: grey),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  borderSide:
                                      BorderSide(color: grey, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (_splitPayments.length > 1) {
                                  _splitPayments.removeAt(index);
                                }
                              });
                            },
                          ),
                        ],
                      );
                    }).toList(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _splitPayments.add({"method": '', "amount": ''});
                        });
                      },
                      child: const Text('Add Another Payment Method'),
                    ),
                  ],
                  Row(
                    children: [
                      Checkbox(
                        value: state.addAdditionalDiscount.value,
                        activeColor: primaryColor,
                        onChanged: (v) {
                          state.addAdditionalDiscount.value = v ?? false;
                          setState(() {});
                        },
                      ),
                      const Text('Add Additional Discount'),
                    ],
                  ),
                  if (state.addAdditionalDiscount.value)
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: state.discountType.value.isEmpty
                                ? null
                                : state.discountType.value,
                            items: ["percentage", "flat"]
                                .map((m) =>
                                    DropdownMenuItem(value: m, child: Text(m)))
                                .toList(),
                            onChanged: (val) =>
                                state.discountType.value = val ?? '',
                            decoration: const InputDecoration(
                              labelText: "Discount Type",
                              labelStyle: TextStyle(color: grey),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(color: grey, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                borderSide:
                                    BorderSide(color: primaryColor, width: 2.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(color: red, width: 1.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: state.discountValue.value,
                            onChanged: (val) => state.discountValue.value = val,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Discount Value",
                              labelStyle: TextStyle(color: grey),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(color: grey, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                borderSide:
                                    BorderSide(color: primaryColor, width: 2.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(color: red, width: 1.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Checkbox(
                        value: _showAdditionalCharges,
                        activeColor: primaryColor,
                        onChanged: (v) {
                          setState(() => _showAdditionalCharges = v ?? false);
                        },
                      ),
                      const Text('Want to add additional charges?'),
                    ],
                  ),
                  if (_showAdditionalCharges)
                    TextFormField(
                      controller: _additionalChargesCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Additional Charge Amount (₹)',
                        labelStyle: TextStyle(color: grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(color: grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide:
                              BorderSide(color: primaryColor, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(color: red, width: 1.0),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  Divider(color: Colors.grey[400]),
                  if (memberDiscount > 0)
                    Row(
                      children: [
                        const Text('Customer have a membership - ',
                            style: TextStyle(color: Colors.black87)),
                        Text(
                          (memberType ?? '').toLowerCase().startsWith('percent')
                              ? '$memberDiscount%'
                              : '₹ $memberDiscount',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  else
                    const Text('Customer has no membership',
                        style: TextStyle(color: Colors.orange)),
                  Text(
                    hasActivePackage || (widget.a.package == 'Yes')
                        ? 'Customer have active package'
                        : 'Customer has no package',
                    style: TextStyle(
                      color: hasActivePackage || (widget.a.package == 'Yes')
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Grand Total",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "₹ ${state.grandTotal.value.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invoice Format'),
                      Row(
                        children: [
                          Row(
                            children: [
                              Radio<String>(
                                activeColor: primaryColor,
                                value: 'gst_invoice',
                                groupValue: _invoiceFormat,
                                onChanged: (v) =>
                                    setState(() => _invoiceFormat = v!),
                              ),
                              const Text('GST Invoice'),
                            ],
                          ),
                          Row(
                            children: [
                              Radio<String>(
                                activeColor: primaryColor,
                                value: 'fullpage',
                                groupValue: _invoiceFormat,
                                onChanged: (v) =>
                                    setState(() => _invoiceFormat = v!),
                              ),
                              const Text('Full Page'),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              Radio<String>(
                                activeColor: primaryColor,
                                value: 'halfpage',
                                groupValue: _invoiceFormat,
                                onChanged: (v) =>
                                    setState(() => _invoiceFormat = v!),
                              ),
                              const Text('Half Page'),
                            ],
                          ),
                          Row(
                            children: [
                              Radio<String>(
                                activeColor: primaryColor,
                                value: 'receipt',
                                groupValue: _invoiceFormat,
                                onChanged: (v) =>
                                    setState(() => _invoiceFormat = v!),
                              ),
                              const Text('Receipt'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButtonExample(
                    onPressed: () async {
                      if (state.paymentMethod.value.isEmpty) {
                        CustomSnackbar.showError(
                            'Error', 'Please select a payment method');
                        return;
                      }
                      List<Map<String, dynamic>>? paymentSplit;
                      if (state.paymentMethod.value == 'Split') {
                        if (_splitPayments.any((r) =>
                            (r['method'] ?? '').isEmpty ||
                            (r['amount'] ?? '').isEmpty)) {
                          CustomSnackbar.showError(
                              'Error', 'Please fill all split payment fields');
                          return;
                        }
                        final sum = _splitPayments.fold<double>(0.0,
                            (s, r) => s + (double.tryParse(r['amount']!) ?? 0));
                        final expected = double.tryParse(
                                state.grandTotal.value.toStringAsFixed(2)) ??
                            state.grandTotal.value;
                        if ((sum - expected).abs() > 0.01) {
                          CustomSnackbar.showError('Error',
                              'Split amounts must match the grand total');
                          return;
                        }
                        paymentSplit = _splitPayments
                            .map((r) => {
                                  'method': r['method'],
                                  'amount': double.tryParse(r['amount']!) ?? 0,
                                })
                            .toList();
                      }

                      final loginUser = await prefs.getManagerUser();
                      final payload = <String, dynamic>{
                        'salon_id': loginUser?.manager?.salonId,
                        'branch_id': loginUser?.manager?.branchId,
                        'appointment_id': widget.a.appointmentId,
                        'tax_id': state.selectedTax.value?.id,
                        'tips': tips,
                        'payment_method': state.paymentMethod.value,
                        'coupon_id': state.appliedCoupon.value?.id,
                        'additional_discount_type':
                            state.discountType.value.isEmpty
                                ? 'percentage'
                                : state.discountType.value,
                        'additional_discount': addAdditionalDiscount
                            ? (double.tryParse(state.discountValue.value) ?? 0)
                            : 0,
                        'additional_charges': _showAdditionalCharges
                            ? (double.tryParse(_additionalChargesCtrl.text) ??
                                0)
                            : 0,
                        'invoice_format': _invoiceFormat,
                        if (paymentSplit != null) 'payment_split': paymentSplit,
                      };
                      try {
                        final res =
                            await dioClient.postData<Map<String, dynamic>>(
                          '${Apis.baseUrl}/payments',
                          payload,
                          (json) => json,
                        );
                        CustomSnackbar.showSuccess(
                            'Success', 'Bill generated successfully');
                        final url = res['invoice_pdf_url'];
                        if (url != null) {
                          final fullUrl = '${Apis.pdfUrl}$url';
                          await controller.openPdf(fullUrl);
                        }
                        Get.put(ManagerAppointmentcontroller())
                            .getAppointment();
                        Get.back();
                      } catch (e) {
                        CustomSnackbar.showError(
                            'Error', 'Failed to generate bill: $e');
                      }
                    },
                    text: 'Generate Bill',
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
