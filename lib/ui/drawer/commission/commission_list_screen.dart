import 'package:flutter/material.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import '../../../wiget/appbar/commen_appbar.dart';
import '../../../wiget/loading.dart';
import 'commission_list_controller.dart';
import 'add_commission_screen.dart';

class CommissionListScreen extends StatelessWidget {
  final controller = Get.put(CommissionListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Commissions'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CustomLoadingAvatar());
        }
        if (controller.commissionList.isEmpty) {
          return Center(child: Text('No commissions found'));
        }
        return ListView.builder(
          itemCount: controller.commissionList.length,
          itemBuilder: (context, index) {
            final item = controller.commissionList[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(item.commissionName),
                subtitle: Text(
                    'Type: ${item.commissionType}\nBranch: ${item.branch.name}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: primaryColor),
                      onPressed: () {
                        Get.to(() => AddCommissionScreen(), arguments: item)
                            ?.then((result) {
                          if (result == true) {
                            controller.fetchCommissions();
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: primaryColor),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Delete?'),
                            content: Text(
                                'Are you sure you want to delete this commission?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Cancel')),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text('Delete')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          controller.deleteCommission(item.id);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Get.to(() => AddCommissionScreen(), arguments: item)
                      ?.then((result) {
                    if (result == true) {
                      controller.fetchCommissions();
                    }
                  });
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Get.to(() => AddCommissionScreen())?.then((result) {
            if (result == true) {
              controller.fetchCommissions();
            }
          });
        },
        child: Icon(
          Icons.add,
          color: white,
        ),
      ),
    );
  }
}
