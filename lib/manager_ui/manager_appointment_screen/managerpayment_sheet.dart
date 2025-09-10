import 'package:flutter/material.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/manager_ui/manager_appointment_screen/getappointmentManagerController.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/colors.dart';
import '../../../wiget/appbar/commen_appbar.dart';
import '../../utils/custom_text_styles.dart';
import '../../wiget/custome_snackbar.dart';
import '../../wiget/custome_text.dart';
import '../../main.dart';
import '../../network/network_const.dart';

class ManagerPaymentSummaryScreen extends StatefulWidget {
  final dynamic a; // pass appointment object

  const ManagerPaymentSummaryScreen({Key? key, required this.a})
      : super(key: key);

  @override
  State<ManagerPaymentSummaryScreen> createState() =>
      _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<ManagerPaymentSummaryScreen> {
  final controller = Get.find<Getappointmentmanagercontroller>();
  final _additionalChargesCtrl = TextEditingController(text: '0');
  String _invoiceFormat = 'fullpage';
  bool _showAdditionalCharges = false;
  List<Map<String, String>> _splitPayments = [
    {"method": '', "amount": ''},
  ];

  /// Reset preselected values to blank exactly once on first frame.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = controller.paymentSummaryState;

      // Make dropdowns blank:
      state.selectedTax.value = null; // TaxModel? -> null is blank
      state.paymentMethod.value = ''; // String  -> empty shows blank
      state.discountType.value = ''; // String  -> empty shows blank

      // Optional: start empty for text fields too
      // state.tips.value = '';
      // state.couponCode.value = '';
      // state.discountValue.value = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = controller.paymentSummaryState;

    return Scaffold(
      appBar: CustomAppBar(title: "Payment Summary"),
      drawer: ManagerDrawerScreen(),
      body: Obx(() {
        final selectedTax = state.selectedTax.value; // TaxModel? (can be null)
        final tips = double.tryParse(state.tips.value) ?? 0.0;
        final paymentMethod = state.paymentMethod.value; // '' means blank
        final coupon = state.appliedCoupon.value;
        final couponDiscount = coupon != null
            ? (coupon.discountType == 'percentage'
                ? widget.a.amount * coupon.discountAmount / 100
                : coupon.discountAmount)
            : 0.0;
        final addAdditionalDiscount = state.addAdditionalDiscount.value;
        final discountType = state.discountType.value; // '' means blank
        final discountValue = double.tryParse(state.discountValue.value) ?? 0.0;
        final memberDiscount = widget.a.branchMembershipDiscount ?? 0.0;
        final taxValue = selectedTax != null
            ? selectedTax.value * widget.a.amount / 100
            : 0.0;

        // Recalculate totals (align with web logic)
        double serviceAmount = (widget.a.amount ?? 0).toDouble();
        final double additionalCharges = _showAdditionalCharges
            ? (double.tryParse(_additionalChargesCtrl.text) ?? 0)
            : 0;

        double amountForDiscountsAndTax = serviceAmount + additionalCharges;

        // Membership discount if available
        double membershipDeduction = 0;
        final String? memberType = widget.a.branchMembershipDiscountType;
        if (widget.a.branchMembershipDiscount != null) {
          if (memberType != null && memberType.toLowerCase().startsWith('percent')) {
            membershipDeduction =
                (widget.a.branchMembershipDiscount.toDouble()) * amountForDiscountsAndTax / 100.0;
          } else {
            membershipDeduction = widget.a.branchMembershipDiscount.toDouble();
          }
        }
        amountForDiscountsAndTax -= membershipDeduction;

        // Coupon discount
        double couponDeduction = 0;
        if (coupon != null) {
          final cType = (coupon.discountType).toLowerCase();
          if (cType.contains('percent')) {
            couponDeduction = (coupon.discountAmount) * amountForDiscountsAndTax / 100.0;
          } else {
            couponDeduction = coupon.discountAmount;
          }
        }
        amountForDiscountsAndTax -= couponDeduction;

        // Additional discount
        if (addAdditionalDiscount && discountValue > 0) {
          if ((discountType).toLowerCase().startsWith('percent')) {
            amountForDiscountsAndTax -= (discountValue * amountForDiscountsAndTax / 100.0);
          } else {
            amountForDiscountsAndTax -= discountValue;
          }
        }
        if (amountForDiscountsAndTax < 0) amountForDiscountsAndTax = 0;

        // Tax on discounted base
        final taxPercent = selectedTax?.value ?? 0.0;
        final taxAmount = amountForDiscountsAndTax * taxPercent / 100.0;

        // Tips
        final totalAfterTax = amountForDiscountsAndTax + taxAmount + tips;
        state.grandTotal.value = totalAfterTax;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Date: ${widget.a.date}",
                  style: TextStyle(color: Colors.black87, fontSize: 14.sp)),
              const SizedBox(height: 6),
              Text("Customer Details",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp)),
              Text("Name: ${widget.a.clientName}",
                  style: const TextStyle(color: Colors.black87)),
              Text("Phone: ${widget.a.clientPhone ?? ''}",
                  style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 10),
              Text("Service Amount: ₹ ${widget.a.amount}",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              if (widget.a.branchMembershipDiscount != null)
                Row(children: [
                  const Text('Membership Discount: ', style: TextStyle(color: Colors.black87)),
                  Text(
                    (widget.a.branchMembershipDiscountType?.toLowerCase().startsWith('percent') ?? false)
                        ? '${widget.a.branchMembershipDiscount}%'
                        : '₹ ${widget.a.branchMembershipDiscount}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                  )
                ])
              else
                const Text('Customer has no membership', style: TextStyle(color: Colors.orange)),
              const SizedBox(height: 6),
              Text(
                (widget.a.package == 'Yes') ? 'Customer have active package' : 'Customer has no package',
                style: TextStyle(
                  color: (widget.a.package == 'Yes') ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Optional product details if present in payload
              if (widget.a.products != null && widget.a.products is List && (widget.a.products as List).isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Product Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
                const SizedBox(height: 6),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                    3: FlexColumnWidth(),
                  },
                  children: [
                    const TableRow(children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('Product', style: TextStyle(fontWeight: FontWeight.w600))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Qty', style: TextStyle(fontWeight: FontWeight.w600))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Price (₹)', style: TextStyle(fontWeight: FontWeight.w600))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Total (₹)', style: TextStyle(fontWeight: FontWeight.w600))),
                    ]),
                    ...((widget.a.products as List).map<TableRow>((prod) {
                      final name = prod['name'] ?? '';
                      final qty = (prod['quantity'] ?? 0).toString();
                      final price = (prod['unit_price'] ?? 0).toString();
                      final total = ((prod['quantity'] ?? 0) * (prod['unit_price'] ?? 0)).toString();
                      return TableRow(children: [
                        Padding(padding: const EdgeInsets.all(8), child: Text('$name')),
                        Padding(padding: const EdgeInsets.all(8), child: Text(qty)),
                        Padding(padding: const EdgeInsets.all(8), child: Text(price)),
                        Padding(padding: const EdgeInsets.all(8), child: Text(total)),
                      ]);
                    })).toList()
                  ],
                )
              ],
              const SizedBox(height: 6),
              Text(
                widget.a.package == 'Yes'
                    ? 'Customer have active package'
                    : 'Customer has no package',
                style: TextStyle(
                  color: widget.a.package == 'Yes' ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Divider(color: Colors.grey[400]),
              Text("Billing Details",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor)),
              const SizedBox(height: 12),

              /// TAX + TIPS + PAYMENT METHOD
              Row(
                children: [
                  // TAX (blank until user selects)
                  Expanded(
                    child: DropdownButtonFormField(
                      value: state.selectedTax.value, // null => blank
                      hint: CustomTextWidget(
                          text: "Select Tax",
                          textStyle: CustomTextStyles.textFontMedium(
                              size: 14.sp, color: grey)),
                      items: controller.taxes
                          .map((tax) => DropdownMenuItem(
                                value: tax,
                                child: Text('${tax.title} (${tax.value}%)'),
                              ))
                          .toList(),
                      onChanged: (val) => state.selectedTax.value = val,
                      decoration: const InputDecoration(labelText: "Tax"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: state.tips.value,
                      onChanged: (val) => state.tips.value = val,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Tips",
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(
                            color: grey,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(
                            color: red,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // PAYMENT METHOD (blank until user selects)
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: state.paymentMethod.value.isEmpty
                          ? null
                          : state.paymentMethod.value, // null => blank
                      hint: CustomTextWidget(
                          text: "Select Payment Method",
                          textStyle: CustomTextStyles.textFontMedium(
                              size: 14.sp, color: grey)),
                      items: ["Cash", "Card", "UPI", "Split"]
                          .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) state.paymentMethod.value = val;
                      },
                      decoration: const InputDecoration(
                        labelText: "Payment Method",
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(
                            color: grey,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(
                            color: red,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (paymentMethod == 'Split') ...[
                const SizedBox(height: 8),
                Column(
                  children: List.generate(_splitPayments.length, (index) {
                    final row = _splitPayments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Spacer(),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: row['method']!.isEmpty ? null : row['method'],
                              items: const [
                                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                                DropdownMenuItem(value: 'Card', child: Text('Card')),
                                DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                              ],
                              onChanged: (v) {
                                setState(() => row['method'] = v ?? '');
                              },
                              hint: const Text('Select Method'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Amount'),
                              initialValue: row['amount'],
                              onChanged: (v) => row['amount'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(children: [
                            if (index == _splitPayments.length - 1)
                              ElevatedButton(
                                onPressed: () => setState(() => _splitPayments.add({"method": '', "amount": ''})),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('+'),
                              ),
                            const SizedBox(width: 6),
                            if (_splitPayments.length > 1)
                              OutlinedButton(
                                onPressed: () => setState(() => _splitPayments.removeAt(index)),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('×'),
                              ),
                          ]),
                        ],
                      ),
                    );
                  }),
                )
              ],
              Divider(color: Colors.grey[400]),

              /// DISCOUNTS
              Text("Discounts",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 18)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: state.couponCode.value,
                      onChanged: (val) => state.couponCode.value = val,
                      decoration:
                          const InputDecoration(labelText: "Coupon Code"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        controller.applyCoupon(state.couponCode.value),
                    child: const Text("Apply"),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                      value: addAdditionalDiscount,
                      onChanged: (val) =>
                          state.addAdditionalDiscount.value = val ?? false),
                  const Text("Add additional discount?",
                      style: TextStyle(color: Colors.black87)),
                ],
              ),
              if (addAdditionalDiscount)
                Row(
                  children: [
                    // DISCOUNT TYPE (blank until user selects)
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: state.discountType.value.isEmpty
                            ? null
                            : state.discountType.value, // null => blank
                        hint: CustomTextWidget(
                            text: "Select Discount Type",
                            textStyle: CustomTextStyles.textFontMedium(
                                size: 14.sp, color: grey)),
                        items: const [
                          DropdownMenuItem(
                              value: "percentage", child: Text("Percentage")),
                          DropdownMenuItem(
                              value: "amount", child: Text("Amount")),
                        ],
                        onChanged: (val) {
                          if (val != null) state.discountType.value = val;
                        },
                        decoration: const InputDecoration(
                          labelText: "Discount Type",
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: grey,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: red,
                              width: 1.0,
                            ),
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
                        decoration:
                            const InputDecoration(labelText: "Discount Value"),
                      ),
                    )
                  ],
                ),
              Row(
                children: [
                  Checkbox(
                    value: _showAdditionalCharges,
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
                    labelText: 'Additional Charge Amount (₹)'
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              Divider(color: Colors.grey[400]),

              /// GRAND TOTAL
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Grand Total",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18)),
                  Text("₹ ${state.grandTotal.value.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 22)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.red))),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (state.paymentMethod.value.isEmpty) {
                        CustomSnackbar.showError('Error', 'Please select a payment method');
                        return;
                      }
                      List<Map<String, dynamic>>? paymentSplit;
                      if (state.paymentMethod.value == 'Split') {
                        if (_splitPayments.any((r) => (r['method'] ?? '').isEmpty || (r['amount'] ?? '').isEmpty)) {
                          CustomSnackbar.showError('Error', 'Please fill all split payment fields');
                          return;
                        }
                        final sum = _splitPayments.fold<double>(0.0, (s, r) => s + (double.tryParse(r['amount']!) ?? 0));
                        if (sum.toStringAsFixed(2) != state.grandTotal.value.toStringAsFixed(2)) {
                          CustomSnackbar.showError('Error', 'Split amounts must match the grand total');
                          return;
                        }
                        paymentSplit = _splitPayments
                            .map((r) => {
                                  'method': r['method'],
                                  'amount': double.tryParse(r['amount']!) ?? 0,
                                })
                            .toList();
                      }

                      final manager = await prefs.getManagerUser();
                      final payload = <String, dynamic>{
                        'salon_id': manager?.manager?.salonId,
                        'appointment_id': widget.a.appointmentId,
                        'tax_id': state.selectedTax.value?.id,
                        'tips': tips,
                        'payment_method': state.paymentMethod.value,
                        'coupon_id': state.appliedCoupon.value?.id,
                        'additional_discount_type': state.discountType.value.isEmpty ? 'percentage' : state.discountType.value,
                        'additional_discount': addAdditionalDiscount ? (double.tryParse(state.discountValue.value) ?? 0) : 0,
                        'additional_charges': _showAdditionalCharges ? (double.tryParse(_additionalChargesCtrl.text) ?? 0) : 0,
                        'invoice_format': _invoiceFormat,
                        if (paymentSplit != null) 'payment_split': paymentSplit,
                      };
                      try {
                        final res = await dioClient.postData<Map<String, dynamic>>(
                          '${Apis.baseUrl}/payments',
                          payload,
                          (json) => json,
                        );
                        CustomSnackbar.showSuccess('Success', 'Bill generated successfully');
                        final url = res['invoice_pdf_url'];
                        if (url != null) {
                          final fullUrl = '${Apis.pdfUrl}$url';
                          await controller.openPdf(fullUrl);
                        }
                        Get.back();
                      } catch (e) {
                        CustomSnackbar.showError('Error', 'Failed to generate bill: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[300]),
                    child: const Text("Generate Bill"),
                  )
                ],
              )
              ,
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Invoice Format:'),
                  const SizedBox(width: 12),
                  Row(children: [
                    Radio<String>(
                        value: 'fullpage',
                        groupValue: _invoiceFormat,
                        onChanged: (v) => setState(() => _invoiceFormat = v!)),
                    const Text('Full Page'),
                  ]),
                  Row(children: [
                    Radio<String>(
                        value: 'halfpage',
                        groupValue: _invoiceFormat,
                        onChanged: (v) => setState(() => _invoiceFormat = v!)),
                    const Text('Half Page'),
                  ]),
                  Row(children: [
                    Radio<String>(
                        value: 'receipt',
                        groupValue: _invoiceFormat,
                        onChanged: (v) => setState(() => _invoiceFormat = v!)),
                    const Text('Receipt'),
                  ]),
                ],
              )
            ],
          ),
        );
      }),
    );
  }
}
