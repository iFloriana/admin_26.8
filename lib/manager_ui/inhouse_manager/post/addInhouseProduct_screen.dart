import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import '../../../utils/custom_text_styles.dart';
import '../../../wiget/appbar/drawer_appbar.dart';
import '../../../wiget/custome_dropdown.dart';
import '../../../wiget/loading.dart';
import '../../../wiget/Custome_textfield.dart';
import '../../../wiget/custome_snackbar.dart';
import '../../../wiget/Custome_button.dart';
import 'addInhouseProduct_controller.dart';

class AddInhouseproductScreen extends StatelessWidget {
  AddInhouseproductScreen({super.key});
  final AddinhouseproductController controller =
      Get.put(AddinhouseproductController());

  @override
  Widget build(BuildContext context) {
    // Controller already fetches in onInit; avoid duplicate fetches

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarWithDrawer(title: "Product Utilization Entry"),
      drawer: ManagerDrawerScreen(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CustomLoadingAvatar());
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // SizedBox(height: 10.h),

              // Branch Selection
              // CustomDropdown<dynamic>(
              //   value: controller.selectedBranch.value,
              //   items: controller.branches,
              //   labelText: "Select Branch *",
              //   onChanged: (v) {
              //     controller.selectedBranch.value = v;
              //     controller.filterStaffByBranch();
              //   },
              //   itemToString: (b) => b['name'],
              //   getId: (b) => (b as Map<String, dynamic>)['_id'] ?? '',
              // ),
              // SizedBox(height: 20.h),

              // Staff Selection
              CustomDropdown<dynamic>(
                value: controller.selectedStaff.value,
                items: controller.staff,
                labelText: "Select Staff",
                onChanged: (v) => controller.selectedStaff.value = v,
                itemToString: (s) => s['full_name'],
                getId: (s) => (s as Map<String, dynamic>)['_id'] ?? '',
              ),
              SizedBox(height: 20.h),

              // Product Selection Section
              _buildProductSelectionSection(),
              SizedBox(height: 20.h),

              // Add Product Button
              ElevatedButtonExample(
                onPressed: _canAddProduct()
                    ? () {
                        controller.addToCart();
                      }
                    : () {},
                text: "Add Product to Cart",
                icon: Icon(Icons.add, color: Colors.white),
              ),
              SizedBox(height: 20.h),

              // Cart Items Section
              if (controller.cart.isNotEmpty) ...[
                _buildCartSection(),
                SizedBox(height: 20.h),
                _buildSubmitSection(),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProductSelectionSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Product Details",
                style: TextStyle(
                  fontSize: 16.sp,
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

          // Product Dropdown with Autocomplete
          _productDropdown(controller),
          SizedBox(height: 15.h),

          // Quantity Field
          CustomTextFormField(
            controller: controller.quantityController,
            labelText: "Quantity *",
            keyboardType: TextInputType.number,
            onFieldSubmitted: (v) {},
          ),
        ],
      ),
    );
  }

  Widget _productDropdown(AddinhouseproductController controller) {
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

  bool _canAddProduct() {
    final parsedQuantity =
        int.tryParse(controller.quantityController.text) ?? 1;
    return controller.selectedProduct.value != null &&
        controller.selectedStaff.value != null &&
        parsedQuantity > 0;
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
                    "Staff: ${item['staff']}",
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
        // Total Amount
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount:",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: black,
                ),
              ),
              Obx(() => Text(
                    "₹${controller.totalAmount.value.toStringAsFixed(2)}",
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
    );
  }

  Widget _buildSubmitSection() {
    return Obx(() => ElevatedButtonExample(
          onPressed: controller.isSubmitting.value
              ? () {} // Disable button while submitting
              : () async {
                  final success = await controller.submitCart();
                  if (success) {
                    Get.back(result: true);
                    CustomSnackbar.showSuccess(
                      'Success',
                      'All products have been submitted successfully.',
                    );
                  }
                },
          text: controller.isSubmitting.value
              ? "Submitting..."
              : "Submit All Products",
          icon: controller.isSubmitting.value
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomLoadingAvatar(),
                )
              : Icon(Icons.send, color: Colors.white),
        ));
  }
}
