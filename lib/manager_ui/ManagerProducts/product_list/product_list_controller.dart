import 'dart:convert';

import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:get/get.dart';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'product_list_model.dart';

class ManagerProductListController extends GetxController {
  var isLoading = true.obs;
  var productList = <Product>[].obs;
  List<Product> _allProducts = [];

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  void fetchProducts() async {
        final loginUser = await prefs.getManagerUser();
    try {
      isLoading(true);
      var response = await dioClient.dio
          .get('${Apis.baseUrl}/products?salon_id=${loginUser!.manager?.salonId}');
      if (response.statusCode == 200) {
        // The response has structure: {"message": "...", "data": [...]}
        var responseData = response.data;
        if (responseData is Map && responseData.containsKey('data')) {
          var products = productFromJson(jsonEncode(responseData['data']));
          productList.assignAll(products);
          _allProducts = products;
        } else {
          // Fallback: try to parse as direct array
          var products = productFromJson(jsonEncode(responseData));
          productList.assignAll(products);
          _allProducts = products;
        }
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> filterByBarcode() async {
    var result = await BarcodeScanner.scan();
    if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
      final filtered =
          _allProducts.where((p) => p.sku == result.rawContent).toList();
      productList.assignAll(filtered);
    }
  }

  void resetFilter() {
    productList.assignAll(_allProducts);
  }

  Future<void> updateStock(String productId,
      {int? stock, List<Map<String, dynamic>>? updatedStocks}) async {
    try {
      isLoading(true);
      final String baseUrl = '${Apis.baseUrl}${Endpoints.uploadProducts}';

      if (updatedStocks != null) {
        for (var variantStock in updatedStocks) {
          await dioClient.patchData(
            '$baseUrl/$productId/stock',
            {
              'variant_sku': variantStock['sku'],
              'variant_stock': variantStock['stock'],
            },
            (json) => json,
          );
        }
      } else if (stock != null) {
        // no variations
        await dioClient.patchData(
          '$baseUrl/$productId/stock',
          {'stock': stock},
          (json) => json,
        );
      }

      Get.back(); // Close bottom sheet
      Get.snackbar('Success', 'Stock updated successfully');
      fetchProducts(); // Refresh the list
    } catch (e) {
      Get.snackbar('Error', 'Failed to update stock: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      isLoading(true);
      final String baseUrl = '${Apis.baseUrl}${Endpoints.uploadProducts}';

      await dioClient.deleteData(
        '$baseUrl/$productId',
        (json) => json,
      );

      Get.snackbar('Success', 'Product deleted successfully');
      fetchProducts(); // Refresh the list
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
    } finally {
      isLoading(false);
    }
  }
}
