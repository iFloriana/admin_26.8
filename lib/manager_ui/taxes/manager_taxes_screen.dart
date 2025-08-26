import 'package:flutter/material.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/taxes/manager_taxes_controller.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/loading.dart';

class ManagerTaxesScreen extends StatelessWidget {
  ManagerTaxesScreen({super.key});

  final ManagerTaxesController controller = Get.put(ManagerTaxesController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Obx(() {
          return CustomAppBar(
            title: controller.isSearching.value ? '' : 'Taxes',
            actions: [
              if (controller.isSearching.value)
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
                        hintText: 'Search by tax title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      onChanged: controller.setSearchQuery,
                      onSubmitted: (value) {
                        controller.setSearchQuery(value);
                        controller.isSearching.value = false;
                      },
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  controller.isSearching.value ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (controller.isSearching.value) {
                    controller.isSearching.value = false;
                    searchController.clear();
                    controller.clearSearch();
                  } else {
                    controller.isSearching.value = true;
                  }
                },
              ),
            ],
          );
        }),
      ),
      drawer: ManagerDrawerScreen(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CustomLoadingAvatar());
        }
        if (controller.filteredTaxes.isEmpty) {
          return const Center(child: Text('No taxes found'));
        }
        return RefreshIndicator(
          color: primaryColor,
          onRefresh: () async => controller.getTaxes(),
          child: ListView.builder(
            itemCount: controller.filteredTaxes.length,
            itemBuilder: (context, index) {
              final tax = controller.filteredTaxes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                child: ExpansionTile(
                  title: Text(
                    '${tax.title ?? '-'} - ${tax.value ?? 0}${tax.type == 'percent' ? '%' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Module: ${tax.taxType ?? '-'} | Status: ${tax.status == 1 ? 'Active' : 'Inactive'}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Branches:',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tax.branches
                                .map((b) => Chip(label: Text(b.name ?? '-')))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
