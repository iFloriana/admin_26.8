import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_template/manager_ui/ManagerProducts/product_list/product_list_controller.dart';
import 'package:flutter_template/manager_ui/ManagerProducts/product_list/product_list_model.dart';
import 'package:flutter_template/manager_ui/ManagerProducts/product_list/update_stock_sheet.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:get/get.dart';
import '../../../network/network_const.dart';
import '../../../route/app_route.dart';
import '../../../utils/colors.dart';
import '../../../wiget/appbar/commen_appbar.dart';
import '../../../wiget/loading.dart';

class ManagerProductListScreen extends StatelessWidget {
  final controller = Get.put(ManagerProductListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Products",
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'barcode_filter') {
                controller.filterByBarcode();
              } else if (value == 'clear') {
                controller.resetFilter();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'barcode_filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_alt, color: Colors.grey, size: 16),
                    SizedBox(width: 8),
                    Text('Sort Newest First'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.grey, size: 16),
                      SizedBox(width: 8),
                      Text('Clear Filters'),
                    ],
                  )),
            ],
          ),
        ], 
      ),
      drawer: ManagerDrawerScreen(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CustomLoadingAvatar());
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: _createColumns(),
                    rows: _createRows(),
                    columnSpacing: 30,
                    horizontalMargin: 16,
                  ),
                )),
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Get.toNamed(Routes.ManagerAddProductScreen);
        },
        child: Icon(
          Icons.add,
          color: white,
        ),
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
          label: Text("Product",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text("Brand",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text("Category",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text("Price",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text("Quantity",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text("Status",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text("Action",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
    ];
  }

  List<DataRow> _createRows() {
    return controller.productList
        .map((product) => DataRow(cells: [
              DataCell(_ProductListItem(product: product)._buildProductInfo()),
              DataCell(Text(product.brandId?.name ?? 'N/A',
                  style: TextStyle(color: Colors.black))),
              DataCell(Text(product.categoryId?.name ?? 'N/A',
                  style: TextStyle(color: Colors.black))),
              DataCell(Text(_ProductListItem(product: product).getPrice(),
                  style: TextStyle(color: Colors.black))),
              DataCell(Text(_ProductListItem(product: product).getQuantity(),
                  style: TextStyle(color: Colors.black))),
              DataCell(_ProductListItem(product: product)._buildStatus()),
              DataCell(_buildActionButtons(Get.context!, product)),
            ]))
        .toList();
  }

  Widget _buildActionButtons(BuildContext context, Product product) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Get.bottomSheet(
              ManagerUpdateStockSheet(product: product),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.brown[400],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('+ Stock',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit_outlined, color: primaryColor),
          onPressed: () {
            Get.toNamed(Routes.ManagerAddProductScreen, arguments: product);
          },
        ),
        IconButton(
            icon: Icon(Icons.delete_outline, color: primaryColor),
            onPressed: () {
              controller.deleteProduct(product.id);
            }),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text("Product",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text("Brand",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text("Category",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text("Price",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text("Quantity",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text("Status",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text("Action",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  final Product product;

  const _ProductListItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This widget is now only used for its helper methods.
    // The actual row is built in _createRows.
    return Container();
  }

  Widget _buildProductInfo() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 40,
            height: 40,
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(
                    '${Apis.pdfUrl}${product.imageUrl}?v=${DateTime.now().millisecondsSinceEpoch}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported, size: 20),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, size: 20),
                  ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            product.productName,
            style: TextStyle(color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatus() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: product.status == 1 ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        product.status == 1 ? 'Active' : 'Inactive',
        style: TextStyle(color: Colors.white, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // This method is now in ProductListScreen
    return Container();
  }

  String getPrice() {
    if (product.hasVariations == 1 && product.variants.isNotEmpty) {
      final prices = product.variants.map((v) => v.price).toList();
      final minPrice = prices.reduce(min);
      final maxPrice = prices.reduce(max);
      if (minPrice == maxPrice) {
        return '₹ $minPrice';
      }
      return '₹ $minPrice - $maxPrice';
    } else {
      return '₹ ${product.price ?? 0}';
    }
  }

  String getQuantity() {
    if (product.hasVariations == 1 && product.variants.isNotEmpty) {
      return product.variants
          .map((v) => v.stock)
          .reduce((a, b) => a + b)
          .toString();
    } else {
      return product.stock?.toString() ?? '0';
    }
  }
}
