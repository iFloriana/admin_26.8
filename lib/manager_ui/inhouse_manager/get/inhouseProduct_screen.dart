import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import '../../../wiget/appbar/drawer_appbar.dart';
import '../../../wiget/loading.dart';
import '../../../network/model/inhouseProduct_model.dart';
import '../../drawer/drawerscreen.dart';
import '../post/addInhouseProduct_screen.dart';
import 'inhouseProduct_controller.dart';

class ManagerGetInHouseProductScreen extends StatelessWidget {
  ManagerGetInHouseProductScreen({super.key});
  final controller =
      Get.put(ManagerGetInHouseProductController());

  @override
  Widget build(BuildContext context) {
    final RxBool isSearching = false.obs;
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Obx(() {
          return CustomAppBarWithDrawer(
            title: isSearching.value
                ? ''
                : "In-House Product Usage${controller.sortOrder.value == 'asc' ? ' (Oldest Updated)' : ' (Newest Updated)'}",
            actions: [
              if (isSearching.value)
                SizedBox(
                  width: 220.w,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Search by Product, Staff, Branch',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      onSubmitted: (value) {
                        controller.updateSearchQuery(value);
                        isSearching.value = false;
                      },
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(isSearching.value ? Icons.close : Icons.search,
                    color: white),
                onPressed: () {
                  if (isSearching.value) {
                    isSearching.value = false;
                    searchController.clear();
                    controller.updateSearchQuery('');
                  } else {
                    isSearching.value = true;
                  }
                },
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: white),
                onSelected: (value) async {
                  if (value == 'date') {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      controller.selectDate(picked);
                    }
                  } else if (value == 'range') {
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      controller.selectDateRange(picked);
                    }
                  } else if (value == 'sort_asc') {
                    controller.setSortOrder('asc');
                  } else if (value == 'sort_desc') {
                    controller.setSortOrder('desc');
                  } else if (value == 'clear') {
                    controller.clearFilters();
                  } else if (value == 'export') {
                    _showExportDialog(context, controller);
                  } else if (value == 'debug') {
                    controller.debugSorting();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'date',
                    child: Text('Filter by Date'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'range',
                    child: Text('Filter by Date Range'),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'sort_asc',
                    child: Obx(() => Row(
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 16,
                              color: controller.sortOrder.value == 'asc'
                                  ? primaryColor
                                  : grey,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sort Oldest Updated',
                              style: TextStyle(
                                color: controller.sortOrder.value == 'asc'
                                    ? primaryColor
                                    : Colors.black,
                                fontWeight: controller.sortOrder.value == 'asc'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        )),
                  ),
                  PopupMenuItem<String>(
                    value: 'sort_desc',
                    child: Obx(() => Row(
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              size: 16,
                              color: controller.sortOrder.value == 'desc'
                                  ? primaryColor
                                  : grey,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sort Newest Updated',
                              style: TextStyle(
                                color: controller.sortOrder.value == 'desc'
                                    ? primaryColor
                                    : Colors.black,
                                fontWeight: controller.sortOrder.value == 'desc'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        )),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(
                          Icons.file_download,
                          size: 16,
                          color: grey,
                        ),
                        SizedBox(width: 8),
                        Text('Export Data'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'clear',
                    child: Text('Clear Filters'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'debug',
                    child: Text('Debug Sorting'),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
      drawer: ManagerDrawerScreen(),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                controller.getInhouseProductUseageData();
              },
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CustomLoadingAvatar());
                }

                if (controller.inhouseProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No in-house products found',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Products will appear here once they are used',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No products found with current filters',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Try adjusting your search criteria or filters',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Data Table
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingTextStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                          dataTextStyle: TextStyle(
                            color: Colors.black87,
                            fontSize: 13.sp,
                          ),
                          columnSpacing: 20.w,
                          horizontalMargin: 16.w,
                          dataRowHeight: 50.h,
                          headingRowHeight: 50.h,
                          columns: [
                            DataColumn(label: Text('Sr. No.')),
                            DataColumn(label: Text('Product')),
                            DataColumn(label: Text('Quantity')),
                            DataColumn(label: Text('Staff')),
                            DataColumn(label: Text('Branch')),
                            DataColumn(label: Text('Used On')),
                            DataColumn(label: Text('Updated On')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows:
                              controller.filteredProducts.map((groupedProduct) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    groupedProduct['sr_no'].toString(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 4.h),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: (groupedProduct['product_names']
                                              as List<String>)
                                          .map((name) => Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 1.h),
                                                child: Text(
                                                  name,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 4.h),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: (groupedProduct['quantities']
                                              as List<String>)
                                          .map((quantity) => Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 1.h),
                                                child: Text(
                                                  quantity,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    groupedProduct['staff'],
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    groupedProduct['branch'],
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    groupedProduct['used_on'],
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    groupedProduct['updated_on'],
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        deleteGroupedProducts(groupedProduct),
                                    tooltip: 'Delete',
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddInhouseproductScreen());
        },
        child: Icon(
          Icons.add,
          color: white,
        ),
        backgroundColor: primaryColor,
      ),
    );
  }

  void deleteGroupedProducts(Map<String, dynamic> groupedProduct) async {
    final products = groupedProduct['products'] as List<InhouseProductData>;

    // Delete all products in the group
    for (var product in products) {
      await controller.deleteInhouseProduct(product.id);
    }
  }

  void _showExportDialog(
      BuildContext context, ManagerGetInHouseProductController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text(
            'Export Data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: primaryColor,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose your preferred export format:',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildExportOption(
                    context,
                    icon: Icons.table_chart,
                    label: 'Excel',
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.exportToExcel();
                    },
                  ),
                  _buildExportOption(
                    context,
                    icon: Icons.picture_as_pdf,
                    label: 'PDF',
                    color: Colors.red,
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.exportToPdf();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
          actionsPadding: const EdgeInsets.all(16.0),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
