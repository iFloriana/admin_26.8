import 'package:flutter/material.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/ui/drawer/staff/staffDetailsController.dart';
import 'package:flutter_template/ui/drawer/staff/staffProofile.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:get/get.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import '../../../wiget/loading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../ui/drawer/staff/addNewStaffScreen.dart';

class Staffdetailsscreen extends StatelessWidget {
  final Staffdetailscontroller controller = Get.put(Staffdetailscontroller());

  Staffdetailsscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        title: 'Staff Members',
        actions: [
          Obx(() {
            final selectedBranchId = controller.selectedBranchId.value;

            // find selected branch name
            final selectedBranch = selectedBranchId.isEmpty
                ? null
                : controller.availableBranches
                    .firstWhereOrNull((b) => b.sId == selectedBranchId);

            // fallback label
            final String branchLabel = selectedBranch?.name?.isNotEmpty == true
                ? selectedBranch!.name!
                : "All";

            return PopupMenuButton<String>(
              onSelected: controller.onBranchChanged,
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: "",
                  child: Text("All Branches"),
                ),
                ...controller.availableBranches.map(
                  (branch) => PopupMenuItem(
                    value: branch.sId,
                    child: Text(branch.name ?? "Unknown Branch"),
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    branchLabel[0].toUpperCase(), // first letter
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            );
          }),
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
                  Icon(Icons.people_outline,
                      size: 90, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  Text(
                    controller.selectedBranchId.value.isEmpty
                        ? "No staff members available"
                        : "No staff found in this branch",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(Routes.addNewStaff),
                    icon: const Icon(Icons.add),
                    label: const Text("Add New Staff"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.filteredStaffList.length,
            itemBuilder: (context, index) {
              final staff = controller.filteredStaffList[index];

              return Slidable(
                key: ValueKey(staff.sId),
                startActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        Get.to(() => Addnewstaffscreen(staff: staff));
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        _confirmDelete(context, staff.sId ?? '', controller);
                      },
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    onTap: () {
                      Get.to(() => StaffProfileScreen(staff: staff));
                    },
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.deepPurple.shade100,
                      backgroundImage: staff.image != null
                          ? NetworkImage(
                              '${Apis.pdfUrl}${staff.image}?v=${DateTime.now().millisecondsSinceEpoch}',
                            )
                          : null,
                      child: staff.image == null
                          ? const Icon(Icons.person,
                              size: 30, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      staff.fullName ?? "Unknown Staff",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (staff.email != null)
                          Text(
                            staff.email!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (staff.phoneNumber != null)
                          Text(
                            staff.phoneNumber!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "New Staff",
          style: TextStyle(color: white),
        ),
        onPressed: () => Get.toNamed(Routes.addNewStaff),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, String staffId, Staffdetailscontroller controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 48, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                "Delete Staff?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Are you sure you want to delete this staff member? This action cannot be undone.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        controller.deleteStaff(staffId);
                      },
                      child: const Text("Delete"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
