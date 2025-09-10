import 'package:flutter/material.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/ui/drawer/reports/customerMembershipReport/customer_membership_report_controller.dart';
import 'package:get/get.dart';

import '../../../../wiget/appbar/commen_appbar.dart';
import '../../../../wiget/loading.dart';

class CustomerMembershipReportScreen extends StatefulWidget {
  @override
  _CustomerMembershipReportScreen createState() =>
      _CustomerMembershipReportScreen();
}

class _CustomerMembershipReportScreen
    extends State<CustomerMembershipReportScreen> {
  final controller = Get.put(CustomerMembershipReportController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.getCustomers();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (controller.hasMore.value && !controller.isLoading.value) {
          controller.getCustomers(loadMore: true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Customers Membership"),
      drawer: DrawerScreen(),
      body: Obx(() {
        if (controller.customers.isEmpty && controller.isLoading.value) {
          return Center(child: CustomLoadingAvatar());
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount:
              controller.customers.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < controller.customers.length) {
              final c = controller.customers[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    c.fullName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${c.membershipName}",
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      Text(
                        c.membershipValidTill != null
                            ? "Valid till: ${c.membershipValidTill!.split('T').first}"
                            : "",
                        style: TextStyle(
                          color: DateTime.tryParse(c.membershipValidTill ?? "")
                                      ?.isBefore(DateTime.now()) ==
                                  true
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomLoadingAvatar(),
                ),
              );
            }
          },
        );
      }),
    );
  }
}
