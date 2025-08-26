import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/staff/manager_staff_controller.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';

class ManagerStaffScreen extends StatelessWidget {
  ManagerStaffScreen({super.key});

  final ManagerStaffController controller = Get.put(ManagerStaffController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Obx(() {
          return CustomAppBar(
            title: controller.isSearching.value ? '' : 'Staff',
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
                        hintText: 'Search by Staff Name',
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
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: '',
                    child: Row(
                      children: [
                        Icon(Icons.segment, color: primaryColor),
                        SizedBox(width: 8),
                        Text('All Specializations'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  ...controller.specializations
                      .map(
                        (spec) => PopupMenuItem<String>(
                          value: spec,
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  color: primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  spec,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              if (controller.selectedSpecialization.value ==
                                  spec)
                                const Icon(Icons.check,
                                    color: primaryColor, size: 16),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
                onSelected: (value) =>
                    controller.applySpecializationFilter(value),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                ),
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
        if (controller.filteredStaff.isEmpty) {
          return const Center(child: Text('No staff found'));
        }
        return RefreshIndicator(
          color: primaryColor,
          onRefresh: () async => controller.getStaff(),
          child: ListView.builder(
            itemCount: controller.filteredStaff.length,
            itemBuilder: (context, index) {
              final staff = controller.filteredStaff[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                child: ExpansionTile(
                  leading: (staff.imageUrl != null &&
                          staff.imageUrl!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '${Apis.pdfUrl}${staff.imageUrl}?v=${DateTime.now().millisecondsSinceEpoch}',
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
                    staff.fullName ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Branch: ${staff.branch?.name ?? '-'}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((staff.email ?? '').isNotEmpty)
                            Text('Email: ${staff.email}'),
                          if ((staff.phoneNumber ?? '').isNotEmpty)
                            Text('Phone: ${staff.phoneNumber}'),
                          if ((staff.specialization ?? '').isNotEmpty)
                            Text('Specialization: ${staff.specialization}'),
                          if (staff.showInCalendar != null)
                            Text(
                                'Show in Calendar: ${staff.showInCalendar == true ? 'Yes' : 'No'}'),
                          const SizedBox(height: 8),
                          const Text('Services:',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          if (staff.services.isEmpty) const Text('-'),
                          if (staff.services.isNotEmpty)
                            Column(
                              children: staff.services.map((s) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(s.name ?? '-')),
                                    if (s.duration != null)
                                      Text('${s.duration} min'),
                                    if (s.price != null) Text('₹${s.price}'),
                                  ],
                                );
                              }).toList(),
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
