import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import '../../utils/custom_text_styles.dart';
import '../../wiget/appbar/drawer_appbar.dart';
import '../../wiget/custome_snackbar.dart';
import 'buy_product_controller.dart';
import '../../wiget/custome_dropdown.dart';
import '../../wiget/Custome_textfield.dart';
import 'package:flutter_template/wiget/Custome_button.dart';
import '../../wiget/loading.dart';

class BuyProductScreen extends StatelessWidget {
  final BuyProductController controller = Get.put(BuyProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarWithDrawer(title: "Buy Product"),
      body: Obx(() {
        if (controller.isDataLoading) {
          return Center(child: CustomLoadingAvatar());
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Date Selection
              SizedBox(height: 5.h),
              Obx(() => TextFormField(
                    controller: TextEditingController(
                      text: controller.selectedDate.value != null
                          ? "${controller.selectedDate.value!.day.toString().padLeft(2, '0')}/${controller.selectedDate.value!.month.toString().padLeft(2, '0')}/${controller.selectedDate.value!.year}"
                          : '',
                    ),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Select Date",
                      labelStyle: CustomTextStyles.textFontMedium(
                          size: 14.sp, color: grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
                          color: primaryColor,
                          width: 2.0,
                        ),
                      ),
                      suffixIcon:
                          Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: Get.context!,
                        initialDate:
                            controller.selectedDate.value ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        controller.selectDate(picked);
                      }
                    },
                  )),
              SizedBox(height: 20.h),
              // Branch and Customer Selection (Fixed at top)
              _buildBranchCustomerSection(),
              SizedBox(height: 20.h),
              // Product Selection Section
              _buildProductSelectionSection(),
              SizedBox(height: 20.h),
              // Add Product Button
              ElevatedButtonExample(
                text: "Add Product to Cart",
                onPressed: _canAddProduct()
                    ? () {
                        controller.addToCart();
                        controller.resetProductFilter();
                      }
                    : () {},
                icon: Icon(Icons.add, color: Colors.white),
              ),
              SizedBox(height: 20.h),
              // Cart Items Section
              if (controller.cart.isNotEmpty) ...[
                _buildCartSection(),
              ],
              // Payment and Order Section
              if (controller.cart.isNotEmpty) ...[
                // Staff Selection Switch
                Row(
                  children: [
                    Text(
                      "Assign Staff",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    Obx(() => Switch(
                          value: controller.showStaffSelection.value,
                          onChanged: (value) {
                            controller.showStaffSelection.value = value;
                            if (!value) {
                              controller.selectedStaff.value = null;
                            }
                          },
                          activeColor: primaryColor,
                        )),
                  ],
                ),
                SizedBox(height: 20.h),
                // Staff Dropdown (conditional)
                Obx(() => controller.showStaffSelection.value
                    ? Column(
                        children: [
                          CustomDropdown<dynamic>(
                            value: controller.selectedStaff.value,
                            items: controller.staff,
                            labelText: "Select Staff *",
                            onChanged: (v) =>
                                controller.selectedStaff.value = v,
                            itemToString: (s) => s['full_name'],
                          ),
                          SizedBox(height: 15.h),
                        ],
                      )
                    : SizedBox.shrink()),

                // Discount Selection
                Row(
                  children: [
                    Obx(() => Checkbox(
                          value: controller.showDiscount.value,
                          onChanged: (value) {
                            controller.showDiscount.value = value ?? false;
                            if (!value!) {
                              controller.discountController.text = '';
                              controller.discountValue.value = '';
                            }
                          },
                          activeColor: primaryColor,
                        )),
                    Text(
                      "Apply Discount",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Discount Type and Input Field (conditional)
                Obx(() => controller.showDiscount.value
                    ? Column(
                        children: [
                          // Discount Type Dropdown
                          CustomDropdown<String>(
                            value: controller.selectedDiscountType.value,
                            items: controller.discountTypes,
                            labelText: "Discount Type",
                            onChanged: (value) {
                              if (value != null) {
                                controller.setDiscountType(value);
                              }
                            },
                            itemToString: (type) => type,
                          ),
                          SizedBox(height: 15.h),
                          // Discount Value Input
                          Obx(() => CustomTextFormField(
                                controller: controller.discountController,
                                labelText:
                                    controller.selectedDiscountType.value ==
                                            "Percentage"
                                        ? "Discount Percentage (%)"
                                        : "Discount Amount (₹)",
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  controller.updateDiscountValue(value);
                                },
                              )),
                          SizedBox(height: 15.h),
                        ],
                      )
                    : SizedBox.shrink()),
                SizedBox(height: 20.h),

                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor),
                  ),
                  child: Column(
                    children: [
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Sub total:",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: black,
                            ),
                          ),
                          Text(
                            "₹${controller.totalAmount.value}",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: black,
                            ),
                          ),
                        ],
                      ),
                      // Discount (if applied)
                      Obx(() => controller.showDiscount.value &&
                              controller.discountValue.value.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.selectedDiscountType.value ==
                                            "Percentage"
                                        ? "Discount (${controller.discountValue.value}%):"
                                        : "Discount (₹${controller.discountValue.value}):",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: black,
                                    ),
                                  ),
                                  Text(
                                    "-₹${controller.getDiscountAmount().toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink()),
                      // Final Total
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Final Total:",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: black,
                              ),
                            ),
                            Obx(() => Text(
                                  "₹${controller.getFinalAmount().toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: black,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                _buildPaymentSection(),
                SizedBox(height: 20.h),
                _buildPlaceOrderButton(),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBranchCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Branch & Customer Selection",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 15.h),

        // Branch Dropdown
        CustomDropdown<dynamic>(
          value: controller.selectedBranch.value,
          items: controller.branches,
          labelText: "Select Branch *",
          onChanged: (v) {
            controller.selectedBranch.value = v;
            controller.filterStaffByBranch();
          },
          itemToString: (b) => b['name'],
        ),
        SizedBox(height: 15.h),

        // Customer Autocomplete
        Obx(() {
          final customers = controller.customers;
          return RawAutocomplete<Object>(
            textEditingController: TextEditingController(
              text: controller.selectedCustomer.value != null
                  ? (controller.selectedCustomer.value
                      as Map<String, dynamic>)['full_name']
                  : '',
            ),
            focusNode: FocusNode(),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<Object>.empty();
              }
              return customers
                  .where((c) => (c as Map<String, dynamic>)['full_name']
                      .toString()
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()))
                  .cast<Object>();
            },
            displayStringForOption: (option) =>
                (option as Map<String, dynamic>)['full_name'],
            fieldViewBuilder:
                (context, textController, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Select Customer *',
                  labelStyle:
                      CustomTextStyles.textFontMedium(size: 14.sp, color: grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 2.0,
                    ),
                  ),
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (v) {
                  // Optionally clear selection if user types
                  controller.selectedCustomer.value = null;
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: SizedBox(
                    height: 200.0,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final option =
                            options.elementAt(index) as Map<String, dynamic>;
                        return ListTile(
                          title: Text(option['full_name']),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            onSelected: (Object selection) {
              controller.selectedCustomer.value = selection;
            },
          );
        }),
        SizedBox(height: 15.h),
      ],
    );
  }

  Widget _buildProductSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Product Selection",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: Icon(Icons.qr_code_scanner, color: primaryColor),
              tooltip: 'Scan Barcode',
              onPressed: () => controller.filterByBarcode(),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _productDropdown(controller),
        SizedBox(height: 15.h),
        _quantityField(controller),
      ],
    );
  }

  Widget _buildCartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cart Items (${controller.cart.length})",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 15.h),
        ...controller.cart.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['name'],
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => controller.removeFromCart(index),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Branch: ${item['branch']}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    "Customer: ${item['customer']}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    "Staff: ${item['staff']}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    "Date: ${item['date']}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Quantity: ${item['quantity']}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        "Price: ₹${item['price']}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "₹${item['total']}",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: 15.h),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Method",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            _radio(controller, "Cash"),
            _radio(controller, "Card"),
            _radio(controller, "Upi"),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return Obx(() => ElevatedButtonExample(
          text:
              "Place Order \t - \t ₹ ${controller.getFinalAmount().toStringAsFixed(2)}",
          onPressed: controller.isLoading.value
              ? () {}
              : () {
                  () async {
                    final success = await controller.placeOrder();
                    if (success) {
                      Get.back(result: true);
                      CustomSnackbar.showSuccess(
                        'Order Placed',
                        'Your order has been successfully placed.',
                      );
                      // Clear all controllers after success
                      controller.selectedBranch.value = null;
                      controller.selectedCustomer.value = null;
                      controller.selectedProduct.value = null;
                      controller.selectedVariant.value = null;
                      controller.selectedStaff.value = null;
                      controller.showStaffSelection.value = false;
                      controller.selectedDate.value = null;
                      controller.showDiscount.value = false;
                      controller.discountController.text = '';
                      controller.discountValue.value = '';
                      controller.selectedDiscountType.value = "Percentage";
                      controller.quantityController.text = '1';
                      controller.cart.clear();
                      controller.totalAmount.value = 0;
                    } else {
                      CustomSnackbar.showError(
                        'Order Failed',
                        'Failed to place order. Please try again.',
                      );
                    }
                  }();
                },
          icon: controller.isLoading.value
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomLoadingAvatar(),
                )
              : Icon(Icons.shopping_cart, color: Colors.white),
        ));
  }

  bool _canAddProduct() {
    final parsedQuantity =
        int.tryParse(controller.quantityController.text) ?? 1;
    return controller.selectedProduct.value != null &&
        controller.selectedBranch.value != null &&
        controller.selectedCustomer.value != null &&
        parsedQuantity > 0;
  }

  Widget _productDropdown(BuyProductController controller) {
    return Obx(() {
      final product = controller.selectedProduct.value;
      final hasVariations = product != null && product['has_variations'] == 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RawAutocomplete<Object>(
            textEditingController: TextEditingController(
              text: product != null
                  ? (product as Map<String, dynamic>)['product_name']
                  : '',
            ),
            focusNode: FocusNode(),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<Object>.empty();
              }
              return controller.products
                  .where((p) => (p as Map<String, dynamic>)['product_name']
                      .toString()
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()))
                  .cast<Object>();
            },
            displayStringForOption: (option) =>
                (option as Map<String, dynamic>)['product_name'],
            fieldViewBuilder:
                (context, textController, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Select Product *',
                  labelStyle:
                      CustomTextStyles.textFontMedium(size: 14.sp, color: grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 2.0,
                    ),
                  ),
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (v) {
                  controller.selectedProduct.value = null;
                  controller.selectedVariant.value = null;
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: SizedBox(
                    height: 200.0,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final option =
                            options.elementAt(index) as Map<String, dynamic>;
                        return ListTile(
                          title: Text(option['product_name']),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            onSelected: (Object selection) {
              controller.selectedProduct.value = selection;
              controller.selectedVariant.value = null;
            },
          ),
          if (hasVariations) ...[
            SizedBox(height: 15.h),
            CustomDropdown<dynamic>(
              value: controller.selectedVariant.value,
              items: product['variants'],
              labelText: "Select Variation *",
              onChanged: (v) => controller.selectedVariant.value = v,
              itemToString: (v) =>
                  v['combination'].map((c) => c['variation_value']).join(' - '),
            ),
          ],
        ],
      );
    });
  }

  Widget _quantityField(BuyProductController controller) {
    return CustomTextFormField(
      controller: controller.quantityController,
      labelText: "Quantity *",
      keyboardType: TextInputType.number,
      onFieldSubmitted: (v) {}, // No need to update any RxInt
    );
  }

  Widget _radio(BuyProductController controller, String value) {
    return Obx(() => Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: controller.paymentMethod.value,
              onChanged: (v) => controller.setPaymentMethod(v ?? ''),
              activeColor: primaryColor,
            ),
            Text(value, style: TextStyle(color: Colors.black)),
          ],
        ));
  }
}
