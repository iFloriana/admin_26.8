import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

import '../../main.dart';
import '../../network/dio.dart';
import '../../network/network_const.dart';
import '../../wiget/custome_snackbar.dart';

class BuyProductController extends GetxController {
  final DioClient dioClient = DioClient();

  RxList branches = [].obs;
  RxList customers = [].obs;
  RxList products = [].obs;
  RxList staff = [].obs; // Add staff list
  List<dynamic> _allProducts = [];
  List<dynamic> _allStaff = []; // Store all staff for filtering

  Rxn selectedBranch = Rxn();
  Rxn selectedCustomer = Rxn();
  Rxn selectedProduct = Rxn();
  Rxn selectedVariant = Rxn();
  Rxn selectedStaff = Rxn(); // Add selected staff
  RxBool showStaffSelection = false.obs; // Add switch for staff selection
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null); // Add selected date
  RxBool showDiscount = false.obs; // Add checkbox for discount
  final TextEditingController discountController =
      TextEditingController(); // Add discount input controller
  RxString selectedDiscountType =
      "".obs; // Add discount type selection
  RxString discountValue = "".obs; // Add reactive discount value
  List<String> discountTypes = [
    "Percentage",
    "Flat"
  ]; // Add discount type options
  final TextEditingController quantityController = TextEditingController();
  // RxInt quantity = 1.obs;
  RxString paymentMethod = "Cash".obs;

  RxList cart = [].obs;
  RxInt totalAmount = 0.obs;
  RxBool isLoading = false.obs;

  bool get isDataLoading =>
      isLoading.value ||
      branches.isEmpty ||
      customers.isEmpty ||
      products.isEmpty ||
      staff.isEmpty; // Add staff to loading check

  @override
  void onInit() {
    super.onInit();
    // Set today's date as default
    selectedDate.value = DateTime.now();
    fetchBranches();
    fetchCustomers();
    fetchProducts();
    fetchStaff(); // Add staff fetching
  }

  void fetchBranches() async {
    final loginUser = await prefs.getUser();
    final data = await dioClient.getData<Map<String, dynamic>>(
        '${Apis.baseUrl}${Endpoints.getBranchName}${loginUser!.salonId}',
        (json) => json);
    branches.value = data['data'] ?? [];
  }

  void fetchCustomers() async {
    final loginUser = await prefs.getUser();
    final endpoint =
        '${Apis.baseUrl}${Endpoints.getCustomersName}${loginUser!.salonId}';
    final data =
        await dioClient.getData<Map<String, dynamic>>(endpoint, (json) => json);
    customers.value = data['data'] ?? [];
  }

  void fetchProducts() async {
    final loginUser = await prefs.getUser();
    final endpoint =
        '${Apis.baseUrl}${Endpoints.getProductsName}${loginUser!.salonId}';
    final data = await dioClient.getData<List<dynamic>>(
        endpoint, (json) => json as List<dynamic>);
    products.value = data;
    _allProducts = data; // Store all products for filtering
  }

  // Add staff fetching method
  void fetchStaff() async {
    final loginUser = await prefs.getUser();
    final endpoint =
        '${Apis.baseUrl}${Endpoints.getStaffDetails}${loginUser!.salonId}';
    final data =
        await dioClient.getData<Map<String, dynamic>>(endpoint, (json) => json);
    staff.value = data['data'] ?? [];
    _allStaff = data['data'] ?? []; // Store all staff for filtering
  }

  // Add method to filter staff by branch
  void filterStaffByBranch() {
    if (selectedBranch.value == null) {
      staff.value = _allStaff; // Show all staff if no branch selected
      return;
    }

    final selectedBranchId = selectedBranch.value['_id'];
    final filteredStaff = _allStaff.where((staffMember) {
      // Check if staff member has branch_id and it matches selected branch
      if (staffMember['branch_id'] != null) {
        // Handle both cases: branch_id as string or as object with _id
        if (staffMember['branch_id'] is String) {
          return staffMember['branch_id'] == selectedBranchId;
        } else if (staffMember['branch_id'] is Map) {
          return staffMember['branch_id']['_id'] == selectedBranchId;
        }
      }
      return false;
    }).toList();

    staff.value = filteredStaff;
    // Clear selected staff if it's not in the filtered list
    if (selectedStaff.value != null) {
      final isStillValid =
          filteredStaff.any((s) => s['_id'] == selectedStaff.value['_id']);
      if (!isStillValid) {
        selectedStaff.value = null;
      }
    }
  }

  // Add method to handle date selection
  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  // Add method to clear date
  void clearDate() {
    selectedDate.value = null;
  }

  // Add method to set discount type
  void setDiscountType(String type) {
    selectedDiscountType.value = type;
  }

  // Add method to update discount value
  void updateDiscountValue(String value) {
    discountValue.value = value;
  }

  // Add method to calculate discount amount
  double getDiscountAmount() {
    if (!showDiscount.value || discountValue.value.isEmpty) return 0.0;
    final discountAmount = double.tryParse(discountValue.value) ?? 0.0;
    final subtotal = totalAmount.value.toDouble();

    if (selectedDiscountType.value == "Percentage") {
      return (discountAmount / 100) *
          subtotal; // Calculate discount as percentage
    } else {
      return discountAmount; // Flat discount amount
    }
  }

  // Add method to get final amount after discount
  double getFinalAmount() {
    final subtotal = totalAmount.value.toDouble();
    final discountAmount = getDiscountAmount();
    return subtotal - discountAmount;
  }

  Future<void> filterByBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
        final scannedSku = result.rawContent;
        // Filter products by SKU
        final filteredProducts = _allProducts.where((product) {
          // Check main product SKU
          if (product['sku'] == scannedSku) {
            return true;
          }
          // Check variant SKUs if product has variations
          if (product['has_variations'] == 1 && product['variants'] != null) {
            final variants = product['variants'] as List;
            return variants.any((variant) => variant['sku'] == scannedSku);
          }
          return false;
        }).toList();
        if (filteredProducts.isNotEmpty) {
          products.value = filteredProducts;
          // If only one product, select it
          if (filteredProducts.length == 1) {
            selectedProduct.value = filteredProducts.first;
            // If it has variations, auto-select the matching variant
            if (filteredProducts.first['has_variations'] == 1 &&
                filteredProducts.first['variants'] != null) {
              final variants = filteredProducts.first['variants'] as List;
              final matchingVariant = variants
                  .firstWhereOrNull((variant) => variant['sku'] == scannedSku);
              if (matchingVariant != null) {
                selectedVariant.value = matchingVariant;
              } else {
                selectedVariant.value = null;
              }
            } else {
              selectedVariant.value = null;
            }
          }
          CustomSnackbar.showSuccess(
            'Success',
            'Found ${filteredProducts.length} product(s) with barcode: $scannedSku',
          );
        } else {
          CustomSnackbar.showError(
            'Not Found',
            'No product found with barcode: $scannedSku',
          );
        }
      }
    } catch (e) {
      CustomSnackbar.showError(
        'Error',
        'Failed to scan barcode: $e',
      );
    }
  }

  void resetProductFilter() {
    products.value = _allProducts;
  }

  void addToCart() {
    // Always parse from the text property
    final parsedQuantity = int.tryParse(quantityController.text) ?? 1;
    if (selectedProduct.value == null ||
        selectedBranch.value == null ||
        selectedCustomer.value == null ||
        parsedQuantity < 1) {
      CustomSnackbar.showError(
        'Error',
        'Please select all required fields (Product, Branch, Customer, Quantity)',
      );
      return;
    }
    final product = selectedProduct.value;
    final hasVariations = product['has_variations'] == 1;
    // Check if variation is selected when product has variations
    if (hasVariations && selectedVariant.value == null) {
      CustomSnackbar.showError(
        'Error',
        'Please select a variation for this product',
      );
      return;
    }
    final variant = hasVariations ? selectedVariant.value : null;
    final price = hasVariations ? variant['price'] : product['price'];
    final name = hasVariations
        ? "${product['product_name']} - ${variant['combination'].map((v) => v['variation_value']).join(' - ')}"
        : product['product_name'];
    cart.add({
      'product': product,
      'variant': variant,
      'name': name,
      'quantity': parsedQuantity,
      'price': price,
      'total': price * parsedQuantity,
      'branch': selectedBranch.value['name'],
      'customer': selectedCustomer.value['full_name'],
      'staff': showStaffSelection.value && selectedStaff.value != null
          ? selectedStaff.value['full_name']
          : 'Not Assigned',
      'date': selectedDate.value != null
          ? selectedDate.value!.toIso8601String().split('T')[0]
          : 'Not Set',
    });
    calculateTotal();
    clearControllers();
    // Clear quantity controller separately
    quantityController.text = '';
  }

  void clearControllers() {
    selectedProduct.value = null;
    selectedVariant.value = null;
    selectedStaff.value = null;
    // Don't clear selectedDate.value - keep the date
    showDiscount.value = false;
    discountController.text = '';
    discountValue.value = '';
    selectedDiscountType.value = "";
  }

  void removeFromCart(int index) {
    cart.removeAt(index);
    calculateTotal();
  }

  void calculateTotal() {
    totalAmount.value =
        cart.fold<int>(0, (sum, item) => sum + (item['total'] as int));
  }

  void setPaymentMethod(String value) {
    paymentMethod.value = value;
  }

  Future<bool> placeOrder() async {
    if (selectedBranch.value == null ||
        selectedCustomer.value == null ||
        cart.isEmpty) return false;
    isLoading.value = true;
    try {
      final endpoint = '${Apis.baseUrl}${Endpoints.postOrders}';
      final productsPayload = cart.map((item) {
        final hasVariations = item['variant'] != null;
        return {
          "product_id": item['product']['_id'],
          if (hasVariations) "variant_id": item['variant']['_id'],
          "quantity": item['quantity'],
        };
      }).toList();
      final loginUser = await prefs.getUser();
      final data = <String, dynamic>{
        "salon_id": loginUser!.salonId,
        "branch_id": selectedBranch.value['_id'],
        "customer_id": selectedCustomer.value['_id'],
        "products": productsPayload,
        "payment_method": paymentMethod.value.toLowerCase(),
      };

      // Add staff_id if staff is selected
      if (showStaffSelection.value && selectedStaff.value != null) {
        data["staff_id"] = selectedStaff.value['_id'];
        print("Adding staff_id: ${selectedStaff.value['_id']}");
      }

      // Add order_date if date is selected
      if (selectedDate.value != null) {
        data["order_date"] =
            selectedDate.value!.toIso8601String().split('T')[0];
        print("Adding order_date: ${data["order_date"]}");
      }

      // Add discount information if discount is applied
      if (showDiscount.value && discountValue.value.isNotEmpty) {
        data["discount_value"] = double.tryParse(discountValue.value) ?? 0.0;
        data["discount_type"] = selectedDiscountType.value.toLowerCase();
        print("Adding discount_value: ${data["discount_value"]}");
        print("Adding discount_type: ${data["discount_type"]}");
      }

      print("Order payload: $data");
      await dioClient.postData<Map<String, dynamic>>(
          endpoint, data, (json) => json);
      cart.clear();
      calculateTotal();
      isLoading.value = false;
      return true;
    } catch (e) {
      print("Error placing order: $e");
      isLoading.value = false;
      return false;
    }
  }
}
