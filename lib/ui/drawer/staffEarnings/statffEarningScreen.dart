import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';

import '../../../wiget/Custome_button.dart';
import '../../../wiget/appbar/commen_appbar.dart';
import '../../../wiget/loading.dart';
import '../drawer_screen.dart';
import 'statffEarningController.dart';
import '../../../network/network_const.dart';

class Statffearningscreen extends StatelessWidget {
  Statffearningscreen({super.key});
  final Statffearningcontroller getController =
      Get.put(Statffearningcontroller());

  final RxBool isSearching = false.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.h),
          child: Obx(() {
            return CustomAppBar(
              title: isSearching.value ? '' : 'Staff Earning',
              actions: [
                if (isSearching.value)
                  SizedBox(
                    width: 270.w,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0),
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
                          hintStyle: TextStyle(color: grey),
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        onSubmitted: (value) {
                          getController.updateSearchQuery(value);
                          isSearching.value = false;
                        },
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(isSearching.value ? Icons.close : Icons.search,
                      color: Colors.white),
                  onPressed: () {
                    if (isSearching.value) {
                      isSearching.value = false;
                      searchController.clear();
                      getController.updateSearchQuery('');
                    } else {
                      isSearching.value = true;
                    }
                  },
                ),
              ],
            );
          }),
        ),
          drawer: DrawerScreen(),
        body: Obx(() {
          if (getController.isLoading.value) {
            return Center(child: CustomLoadingAvatar());
          }
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: primaryColor,
                  onRefresh: getController.getStaffEarningData,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Total Booking')),
                          DataColumn(label: Text('Service Amount')),
                          DataColumn(label: Text('Commission Earning')),
                          DataColumn(label: Text('Tip Earning')),
                          DataColumn(label: Text('Staff Earning')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: getController.filteredStaffEarnings
                            .map<DataRow>((staff) {
                          return DataRow(
                            cells: [
                              DataCell(Row(
                                children: [
                                  (staff['staff_image'] != null &&
                                          staff['staff_image']
                                              .toString()
                                              .isNotEmpty)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            '${Apis.pdfUrl}${staff['staff_image']}?v=${DateTime.now().millisecondsSinceEpoch}',
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                    Icons.image_not_supported),
                                              );
                                            },
                                          ),
                                        )
                                      : Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            color: Color.fromARGB(
                                                255, 177, 177, 177),
                                          ),
                                        ),
                                  SizedBox(width: 8),
                                  Text(staff['staff_name'] ?? ''),
                                ],
                              )),
                              DataCell(Text('${staff['total_booking']}')),
                              DataCell(Text('₹ ${staff['service_amount']}')),
                              DataCell(
                                  Text('₹ ${staff['commission_earning']}')),
                              DataCell(Text('₹ ${staff['tip_earning']}')),
                              DataCell(Text('₹ ${staff['staff_earning']}')),
                              DataCell(
                                IconButton(
                                  icon:
                                      Icon(Icons.payments, color: primaryColor),
                                  onPressed: () {
                                    _showPayoutSheet(
                                        context, staff, getController);
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  void _showPayoutSheet(
      BuildContext context, Map staff, Statffearningcontroller controller) {
    final RxString paymentMethod = ''.obs;
    final TextEditingController descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  (staff['staff_image'] != null &&
                          staff['staff_image'].toString().isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '${Apis.pdfUrl}${staff['staff_image']}?v=${DateTime.now().millisecondsSinceEpoch}',
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
                  SizedBox(width: 12),
                  Text(staff['staff_name'] ?? '',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                    value: paymentMethod.value,
                    items: [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'upi', child: Text('Upi')),
                      DropdownMenuItem(value: 'online', child: Text('Online')),
                    ],
                    onChanged: (v) => paymentMethod.value = v ?? '',
                    decoration: InputDecoration(
                      labelText: 'Select Method *',
                      labelStyle: TextStyle(color: grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
                          color: primaryColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                  )),
              SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Commission Earn: ₹ ${staff['commission_earning']}'),
                    Text('Tip Earn: ₹ ${staff['tip_earning']}'),
                    Text('Salary: ₹ ${staff['staff_earning']}'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Total Pay : ₹ ${staff['staff_earning'] + staff['tip_earning']}'),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButtonExample(
                  onPressed: () {
                    controller.payoutStaff(
                      staffId: staff['staff_id'],
                      paymentMethod: paymentMethod.value,
                      description: descController.text,
                    );
                  },
                  text: "Payout",
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
