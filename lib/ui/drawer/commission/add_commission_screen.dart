import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/Custome_button.dart';
import 'package:get/get.dart';
import '../../../wiget/appbar/commen_appbar.dart';
import '../../../wiget/custome_snackbar.dart';
import '../../../wiget/loading.dart';
import 'add_commission_controller.dart';
import 'package:flutter_template/network/model/branch_model.dart';

class AddCommissionScreen extends StatelessWidget {
  final AddCommissionController controller = Get.put(AddCommissionController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: CustomAppBar(
            title: controller.editingId != null
                ? 'Edit Commission'
                : 'Add Commission',
          ),
          body: controller.isLoading.value
              ? Center(child: CustomLoadingAvatar())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                          controller: controller.commissionNameController,
                          decoration: InputDecoration(
                            labelText: 'Commission Name *',
                            labelStyle: TextStyle(color: grey),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2.0,
                              ),
                            ),
                          )),
                      Obx(() {
                        return DropdownButtonFormField<BranchModel>(
                          value: controller.selectedBranch.value,
                          decoration: InputDecoration(
                            labelText: "Select Branch",
                            labelStyle: TextStyle(color: grey),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2.0,
                              ),
                            ),
                          ),
                          items:
                              controller.branchList.map((BranchModel branch) {
                            return DropdownMenuItem<BranchModel>(
                              value: branch,
                              child: Text(branch.name),
                            );
                          }).toList(),
                          onChanged: (BranchModel? newValue) {
                            if (newValue != null) {
                              controller.selectedBranch.value = newValue;
                              CustomSnackbar.showSuccess(
                                'Branch Selected',
                                'ID: ${newValue.id}',
                              );
                            }
                          },
                        );
                      }),
                      // SizedBox(height: 16),
                      // Commission Name

                      // SizedBox(height: 16),
                      // Commission Type Dropdown
                      DropdownButtonFormField<String>(
                          value: controller.commissionType.value.isEmpty
                              ? null
                              : controller.commissionType.value,
                          items: controller.commissionTypeOptions
                              .map((type) => DropdownMenuItem(
                                  value: type, child: Text(type)))
                              .toList(),
                          onChanged: (val) =>
                              controller.commissionType.value = val ?? '',
                          decoration: InputDecoration(
                            labelText: 'Commission Type *',
                            labelStyle: TextStyle(color: grey),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2.0,
                              ),
                            ),
                          )),
                      // SizedBox(height: 24),
                      // Text('Slots',
                      //     style: TextStyle(fontWeight: FontWeight.bold)),
                      // SizedBox(height: 8),
                      ...List.generate(controller.slots.length, (index) {
                        final slot = controller.slots[index];
                        return Row(
                          spacing: 5,
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: slot.slot,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                      color: primaryColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  labelText: 'Slot *',
                                  labelStyle: TextStyle(color: grey),
                                ),
                                onChanged: (val) => slot.slot = val,
                              ),
                            ),
                            // SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: slot.amount,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                      color: primaryColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  labelText: 'Amount *',
                                  labelStyle: TextStyle(color: grey),
                                ),
                                onChanged: (val) => slot.amount = val,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: primaryColor),
                              onPressed: () => controller.removeSlot(index),
                            ),
                          ],
                        );
                      }),
                      // SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: controller.addSlot,
                        child: Text(
                          '+ Add Slot',
                          style: TextStyle(color: white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                      ),
                      // SizedBox(height: 24),

                      ElevatedButtonExample(
                          text: controller.editingId != null
                              ? 'Update Commission'
                              : 'Add Commission',
                          onPressed: controller.postCommission)
                      // Row(
                      // children: [
                      // ElevatedButton(
                      //   onPressed: controller.postCommission,
                      //   child: Text(controller.editingId != null
                      //       ? 'Update Commission'
                      //       : 'Add Commission'),
                      // ),
                      // SizedBox(width: 16),
                      // ],
                      // ),
                    ],
                  ),
                ),
        ));
  }
}
