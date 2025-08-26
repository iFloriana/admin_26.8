import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/manager_ui/services_manager/manager_serviceController.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import '../../../../network/network_const.dart';

class ManagerServicescreen extends StatelessWidget {
  ManagerServicescreen({super.key});

  final getController = Get.put(ManagerServicecontroller());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Obx(() {
          return CustomAppBar(
            backgroundColor: primaryColor,
            title: getController.isSearching.value ? '' : 'Services',
            actions: [
              if (getController.isSearching.value)
                SizedBox(
                  width: 220.w,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Search by Service Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      onChanged: (val) => getController.setSearchQuery(val),
                      onSubmitted: (val) {
                        getController.setSearchQuery(val);
                        getController.isSearching.value = false;
                      },
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  getController.isSearching.value ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (getController.isSearching.value) {
                    getController.isSearching.value = false;
                    getController.setSearchQuery('');
                  } else {
                    getController.isSearching.value = true;
                  }
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'filter_category') {
                    _showCategoryFilterDialog(context);
                  } else if (value == 'clear_filters') {
                    getController.clearFilters();
                  } else if (value == 'sort_asc') {
                    getController.setSortOrder('asc');
                  } else if (value == 'sort_desc') {
                    getController.setSortOrder('desc');
                  } else if (value == 'export_excel') {
                    await getController.exportToExcel();
                  } else if (value == 'export_pdf') {
                    await getController.exportToPdf();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'filter_category',
                    child: Text('Filter by Category'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'sort_asc',
                    child: Text('Sort A → Z'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'sort_desc',
                    child: Text('Sort Z → A'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'clear_filters',
                    child: Text('Clear Filters'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'export_excel',
                    child: Text('Export Excel'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'export_pdf',
                    child: Text('Export PDF'),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
      drawer: ManagerDrawerScreen(),
      body: Obx(() {
        final list = getController.filteredServiceList.isNotEmpty ||
                getController.searchQuery.isNotEmpty ||
                (getController.selectedCategoryId.value ?? '').isNotEmpty
            ? getController.filteredServiceList
            : getController.serviceList;

        if (list.isEmpty) {
          return Center(child: Text("No services found."));
        }
        return ListView.builder(
          padding: EdgeInsets.only(bottom: 80.h),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return Card(
              color: white,
              margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
              child: ListTile(
                leading: item.image_url != null && item.image_url!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          '${Apis.pdfUrl}${item.image_url}?v=${DateTime.now().millisecondsSinceEpoch}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image_not_supported),
                      ),
                title: Text(item.name ?? 'No Name'),
                subtitle: Text(
                    '${(item.status == 1) ? "Active" : "Deactive"}${(item.categoryName != null && item.categoryName!.isNotEmpty) ? " • ${item.categoryName}" : ""}'),
              ),
            );
          },
        );
      }),
    );
  }

  void _showCategoryFilterDialog(BuildContext context) {
    final controller = getController;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Category'),
          content: Obx(() {
            final options = controller.categoryOptions;
            return SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: const Text('All categories'),
                    onTap: () {
                      controller.setCategoryFilter(null);
                      Navigator.of(context).pop();
                    },
                    trailing: (controller.selectedCategoryId.value == null)
                        ? const Icon(Icons.check)
                        : null,
                  ),
                  ...options.map((opt) {
                    final id = opt['id'] ?? '';
                    final name = opt['name'] ?? 'Unknown';
                    final selected = controller.selectedCategoryId.value == id;
                    return ListTile(
                      title: Text(name),
                      onTap: () {
                        controller.setCategoryFilter(id);
                        Navigator.of(context).pop();
                      },
                      trailing: selected ? const Icon(Icons.check) : null,
                    );
                  }).toList(),
                ],
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
