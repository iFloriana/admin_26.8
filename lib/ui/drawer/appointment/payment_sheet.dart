import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/colors.dart';
import '../../../wiget/appbar/commen_appbar.dart';
import 'appointmentController.dart';

class PaymentSummaryScreen extends StatefulWidget {
  final dynamic a; // pass appointment object

  const PaymentSummaryScreen({Key? key, required this.a}) : super(key: key);

  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  final controller = Get.find<AppointmentController>();

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

        // Recalculate totals
        controller.calculateGrandTotal(
          servicePrice: widget.a.amount.toDouble(),
          memberDiscount: memberDiscount,
          taxValue: taxValue,
          tip: tips,
          couponDiscount: couponDiscount,
          additionalDiscount: addAdditionalDiscount ? discountValue : 0.0,
          discountType: discountType,
        );

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
                      hint: const Text("Select Tax"),
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
                      decoration: const InputDecoration(labelText: "Tips"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // PAYMENT METHOD (blank until user selects)
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: state.paymentMethod.value.isEmpty
                          ? null
                          : state.paymentMethod.value, // null => blank
                      hint: const Text("Select Payment Method"),
                      items: ["UPI", "Cash", "Card"]
                          .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) state.paymentMethod.value = val;
                      },
                      decoration:
                          const InputDecoration(labelText: "Payment Method"),
                    ),
                  ),
                ],
              ),
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
                        hint: const Text("Select Discount Type"),
                        items: const [
                          DropdownMenuItem(
                              value: "percentage", child: Text("Percentage")),
                          DropdownMenuItem(
                              value: "amount", child: Text("Amount")),
                        ],
                        onChanged: (val) {
                          if (val != null) state.discountType.value = val;
                        },
                        decoration:
                            const InputDecoration(labelText: "Discount Type"),
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
                    onPressed: () {
                      // TODO: generate bill API
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[300]),
                    child: const Text("Generate Bill"),
                  )
                ],
              )
            ],
          ),
        );
      }),
    );
  }
}
