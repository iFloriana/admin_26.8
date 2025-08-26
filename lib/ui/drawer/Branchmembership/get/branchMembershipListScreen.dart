import 'package:flutter/material.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:get/get.dart';
import '../../../../route/app_route.dart';
import '../../../../wiget/Custome_button.dart';
import '../../../../wiget/loading.dart';
import 'branchMembershipListController.dart';
import '../add/branchMembershipAddController.dart';
import '../../../../network/model/BranchMembership.dart';
import '../../../../wiget/Custome_textfield.dart';
import '../../../../wiget/custome_dropdown.dart';

class BranchMembershipListScreen extends StatelessWidget {
  final controller = Get.put(BranchMembershipListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Branch Memberships',
      ),
      drawer: DrawerScreen(),
      body: RefreshIndicator(child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CustomLoadingAvatar());
        }

        if (controller.memberships.isEmpty) {
          return Center(child: Text('No memberships found'));
        }

        return ListView.builder(
          itemCount: controller.memberships.length,
          itemBuilder: (context, index) {
            final membership = controller.memberships[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  membership.membershipName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Plan: ${membership.subscriptionPlan}'),
                    Text('Amount: ₹${membership.membershipAmount}'),
                    Text(
                        'Discount: ${membership.discountType == 'percentage' ? '%' : ' ₹'} ${membership.discount}'),
                    Text(
                        'Status: ${membership.status == 1 ? 'Active' : 'Inactive'}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: primaryColor),
                      onPressed: () {
                        showEditMembershipSheet(context, membership);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: primaryColor),
                      onPressed: () {
                        controller.deleteMembership(membership.id);
                        // showDialog(
                        //   context: context,
                        //   builder: (context) => AlertDialog(
                        //     title: Text('Delete Membership'),
                        //     content: Text(
                        //         'Are you sure you want to delete "${membership.membershipName}"?'),
                        //     actions: [
                        //       TextButton(
                        //         onPressed: () => Navigator.of(context).pop(),
                        //         child: Text('Cancel'),
                        //       ),
                        //       TextButton(
                        //         onPressed: () {
                        //           Navigator.of(context).pop();
                        //           controller.deleteMembership(membership.id);
                        //         },
                        //         child: Text('Delete',
                        //             style: TextStyle(color: Colors.red)),
                        //       ),
                        //     ],
                        //   ),
                        // );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }), onRefresh: () async {
        controller.fetchMemberships();
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          controller.clearAllFields();
          Get.toNamed(Routes.branchmembershipaddscreen);
        },
        child: Icon(
          Icons.add,
          color: white,
        ),
      ),
    );
  }

  void showEditMembershipSheet(
      BuildContext context, BranchMemberShip membership) async {
    final addController = Get.put(Branchmembershipaddcontroller());
    addController.memberShipNameController.text = membership.membershipName;
    addController.descriptionController.text = membership.description;
    addController.selected_Subscription_plan.value =
        mapPlanValueToDisplay(membership.subscriptionPlan);
    addController.selected_discountType.value =
        mapDiscountTypeToDisplay(membership.discountType);
    addController.discountAmountController.text =
        membership.discount.toString();
    addController.membershipAmountController.text =
        membership.membershipAmount.toString();
    addController.isActive.value = membership.status == 1;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  CustomTextFormField(
                    controller: addController.memberShipNameController,
                    labelText: "Name",
                    keyboardType: TextInputType.text,
                  ),
                  Obx(() => CustomDropdown<String>(
                        value: addController
                                .selected_Subscription_plan.value.isEmpty
                            ? null
                            : addController.selected_Subscription_plan.value,
                        items: addController.Subscription_plan_option,
                        hintText: 'Subscription Plan',
                        labelText: 'Subscription Plan',
                        onChanged: (newValue) {
                          if (newValue != null) {
                            addController.selected_Subscription_plan.value =
                                newValue;
                          }
                        },
                      )),
                  Obx(() => CustomDropdown<String>(
                        value: addController.selected_discountType.value.isEmpty
                            ? null
                            : addController.selected_discountType.value,
                        items: addController.discountType_option,
                        hintText: 'Discount Type',
                        labelText: 'Discount Type',
                        onChanged: (newValue) {
                          if (newValue != null) {
                            addController.selected_discountType.value =
                                newValue;
                          }
                        },
                      )),
                  CustomTextFormField(
                    controller: addController.descriptionController,
                    labelText: 'Description',
                    maxLines: 2,
                    keyboardType: TextInputType.text,
                  ),
                  CustomTextFormField(
                    controller: addController.membershipAmountController,
                    labelText: "Membership Amount",
                    keyboardType: TextInputType.number,
                  ),
                  CustomTextFormField(
                    controller: addController.discountAmountController,
                    labelText: "Discount Amount",
                    keyboardType: TextInputType.number,
                  ),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status'),
                          Switch(
                            value: addController.isActive.value,
                            onChanged: (value) {
                              addController.isActive.value = value;
                            },
                            activeColor: primaryColor,
                          ),
                        ],
                      )),
                  ElevatedButtonExample(
                    text: 'Update Membership',
                    onPressed: () {
                      controller.updateMembership(membership.id);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
  }

  String mapPlanValueToDisplay(String value) {
    switch (value.toLowerCase()) {
      case '1-month':
        return '1-Month';
      case '3-months':
        return '3-Months';
      case '6-months':
        return '6-Months';
      case '12-months':
        return '12-Months';
      case 'lifetime':
        return 'Lifetime';
      default:
        return value;
    }
  }

  String mapDiscountTypeToDisplay(String value) {
    switch (value.toLowerCase()) {
      case 'fixed':
        return 'Fixed';
      case 'percentage':
        return 'Percentage';
      default:
        return value;
    }
  }
}
