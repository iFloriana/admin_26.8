import 'package:flutter/material.dart';
import 'package:flutter_template/manager_ui/ManagerProducts/product_list/product_list_controller.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'product_list_model.dart';

class ManagerUpdateStockSheet extends StatefulWidget {
  final Product product;
  const ManagerUpdateStockSheet({Key? key, required this.product}) : super(key: key);

  @override
  _UpdateStockSheetState createState() => _UpdateStockSheetState();
}

class _UpdateStockSheetState extends State<ManagerUpdateStockSheet> {
  late List<TextEditingController> _stockControllers;
  final ManagerProductListController controller = Get.find();

  @override
  void initState() {
    super.initState();
    if (widget.product.hasVariations == 1 &&
        widget.product.variants.isNotEmpty) {
      _stockControllers = widget.product.variants
          .map((v) => TextEditingController(text: v.stock.toString()))
          .toList();
    } else {
      _stockControllers = [
        TextEditingController(text: widget.product.stock?.toString() ?? '0')
      ];
    }
  }

  @override
  void dispose() {
    for (var c in _stockControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16)
          .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white, // Light mode background
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Update Stock:  ${widget.product.productName}',
                    style: TextStyle(
                        color: Colors.black, // Dark text for light mode
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // IconButton(
                //   icon: Icon(Icons.close, color: Colors.red[700]),
                //   onPressed: () => Get.back(),
                // )
              ],
            ),
            SizedBox(height: 20),
            _buildTableHeader(),
            SizedBox(height: 10),
            _buildTableRows(),
            SizedBox(height: 20),
            _buildSheetActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Text('Variation',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold))),
        Expanded(
            child: Text('Current Stock',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold))),
        Expanded(
            child: Text('New Stock',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildTableRows() {
    if (widget.product.hasVariations == 1 &&
        widget.product.variants.isNotEmpty) {
      return Column(
        children: List.generate(widget.product.variants.length, (index) {
          final variant = widget.product.variants[index];
          final variationDetails = variant.combination
              .map((c) => '${c.variationType}: ${c.variationValue}')
              .join(', ');
          return _buildTableRow(variationDetails, variant.stock.toString(),
              _stockControllers[index]);
        }),
      );
    } else {
      return _buildTableRow('Default', widget.product.stock?.toString() ?? '0',
          _stockControllers[0]);
    }
  }

  Widget _buildTableRow(String variation, String currentStock,
      TextEditingController newStockController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(variation, style: TextStyle(color: Colors.black))),
          Expanded(
              child: Text(currentStock, style: TextStyle(color: Colors.black))),
          Expanded(
            child: Container(
              height: 40,
              child: TextField(
                controller: newStockController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  filled: true,
                  fillColor: Colors.grey[200], // Light fill for input
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetActionButtons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: _onUpdateStock,
          child: Text('Update Stock', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, // More visible in light mode
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(width: 10),
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel', style: TextStyle(color: primaryColor)),
        ),
      ],
    );
  }

  void _onUpdateStock() {
    if (widget.product.hasVariations == 1) {
      List<Map<String, dynamic>> updatedStocks = [];
      for (int i = 0; i < widget.product.variants.length; i++) {
        updatedStocks.add({
          'sku': widget.product.variants[i].sku,
          'stock': _stockControllers[i].text,
        });
      }
      controller.updateStock(widget.product.id, updatedStocks: updatedStocks);
    } else {
      controller.updateStock(widget.product.id,
          stock: int.parse(_stockControllers[0].text));
    }
  }
}
