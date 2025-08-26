import 'package:flutter/material.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/ui/drawer/staff/staffDetailsController.dart';
import 'package:flutter_template/utils/app_images.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:get/get.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';

import '../../../wiget/loading.dart';
import '../../../ui/drawer/staff/addNewStaffScreen.dart';

class Staffdetailsscreen extends StatelessWidget {
  final Staffdetailscontroller controller = Get.put(Staffdetailscontroller());

  Staffdetailsscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Staff Details',
        actions: [
          // Branch filter popup menu
          PopupMenuButton<String>(
            onSelected: controller.onBranchChanged,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: '',
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: primaryColor),
                    SizedBox(width: 8),
                    Text('All Branches'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ...controller.availableBranches
                  .map(
                    (branch) => PopupMenuItem<String>(
                      value: branch.sId,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              branch.name ?? 'Unknown Branch',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          if (controller.selectedBranchId.value == branch.sId)
                            const Icon(Icons.check,
                                color: primaryColor, size: 16),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.more_vert, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: DrawerScreen(),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async {
          controller.getCustomerDetails();
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CustomLoadingAvatar());
          }

          if (controller.filteredStaffList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    controller.selectedBranchId.value.isEmpty
                        ? "No staff found"
                        : "No staff found for selected branch",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.filteredStaffList.length,
            itemBuilder: (context, index) {
              final staff = controller.filteredStaffList[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: staff.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '${Apis.pdfUrl}${staff.image}?v=${DateTime.now().millisecondsSinceEpoch}',
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
                  title: Text(
                    staff.fullName ?? "Unknown",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (staff.email != null) Text("Email: ${staff.email}"),
                      if (staff.branchId?.name != null)
                        Text("Branch: ${staff.branchId!.name}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: primaryColor),
                        onPressed: () {
                          Get.to(() => Addnewstaffscreen(staff: staff));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: primaryColor),
                        onPressed: () {
                          _confirmDelete(context, staff.sId ?? '', controller);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Get.toNamed(Routes.addNewStaff);
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, String staffId, Staffdetailscontroller controller) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this staff?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                controller.deleteStaff(staffId);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
