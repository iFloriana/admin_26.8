import 'dart:convert';

import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:get/get.dart';

import 'package:barcode_scan2/barcode_scan2.dart';
import '../../../wiget/custome_snackbar.dart';
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
      var response = await dioClient.dio.get(
          '${Apis.baseUrl}/products/by-branch?salon_id=${loginUser!.manager?.salonId}&branch_id=${loginUser.manager?.branchId?.sId}');
      var responseData = response.data;
      if (responseData is Map && responseData.containsKey('data')) {
        var products = productFromJson(jsonEncode(responseData['data']));
        productList.assignAll(products);
        _allProducts = products;
      } else {
        var products = productFromJson(jsonEncode(responseData));
        productList.assignAll(products);
        _allProducts = products;
      }
      // }
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

      Get.back(); 
      CustomSnackbar.showSuccess('Success', 'Stock updated successfully');
      fetchProducts(); // Refresh the list
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to update stock: $e');
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

      CustomSnackbar.showSuccess('Success', 'Product deleted successfully');
      fetchProducts(); // Refresh the list
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete product: $e');
    } finally {
      isLoading(false);
    }
  }
}
