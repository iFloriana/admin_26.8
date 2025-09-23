import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import 'product_list_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Product Details",
          // title: product.productName,
          bottom: const TabBar(
            indicatorColor: secondaryColor,
            labelColor: Colors.white,
            splashBorderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20.0),
            ),
            unselectedLabelColor: secondaryColor,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Stock History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // First Tab: Product Details
            _buildProductDetailsTab(context),

            ProductStockHistoryTab(productId: product.id),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProductImage(context),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${product.price ?? 0}',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                _buildProductInfoRow(
                  context,
                  'Brand',
                  product.brandId?.name ?? 'N/A',
                  Icons.sell,
                ),
                _buildProductInfoRow(
                  context,
                  'Category',
                  product.categoryId?.name ?? 'N/A',
                  Icons.category,
                ),
                _buildProductInfoRow(
                  context,
                  'Stock',
                  '${product.stock ?? 0}',
                  Icons.inventory,
                ),
                _buildProductInfoRow(
                  context,
                  'Status',
                  product.status == 1 ? 'Active' : 'Inactive',
                  product.status == 1
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  isStatus: true,
                ),
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: product.imageUrl != null && product.imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: product.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.image_not_supported,
                      size: 80, color: Colors.grey),
                ),
              )
            : const Center(
                child: Icon(Icons.inventory_2, size: 80, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildProductInfoRow(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(width: 16),
          Text(
            '$title:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: isStatus
                    ? (value == 'Active' ? Colors.green : Colors.red)
                    : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductStockHistoryTab extends StatelessWidget {
  final String productId;

  const ProductStockHistoryTab({Key? key, required this.productId})
      : super(key: key);

  Future<List<dynamic>> _fetchStockHistory() async {
    try {
      final response = await dioClient.dio
          .get('${Apis.baseUrl}/products/stock-history/$productId');

      if (response.statusCode == 200) {
        return response.data['history'];
      } else {
        throw Exception('Failed to load stock history');
      }
    } catch (e) {
      throw Exception('Failed to load stock history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchStockHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No stock history available.'));
        } else {
          final historyList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final historyItem = historyList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    'Quantity: ${historyItem['quantity_received']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Date: ${historyItem['date']}'),
                ),
              );
            },
          );
        }
      },
    );
  }
}
