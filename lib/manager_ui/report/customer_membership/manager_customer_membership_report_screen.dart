import 'package:flutter/material.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/manager_ui/report/customer_membership/manager_customer_membership_report_controller.dart';
import 'package:get/get.dart';

import '../../../wiget/appbar/commen_appbar.dart';
import '../../../wiget/loading.dart';

class ManagerCustomerMembershipReportScreen extends StatefulWidget {
  @override
  _ManagerCustomerMembershipReportScreen createState() =>
      _ManagerCustomerMembershipReportScreen();
}

class _ManagerCustomerMembershipReportScreen
    extends State<ManagerCustomerMembershipReportScreen> {
  final controller = Get.put(ManagerCustomerMembershipReportController());
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
      appBar: CustomAppBar(title: "Customers  Membership"),
      drawer: ManagerDrawerScreen(),
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
              return ListTile(
                // leading: CircleAvatar(child: Text(c.fullName[0])),
                title: Text(c.fullName),
                subtitle: Text("${c.membershipName}"),
                trailing: Text(
                  c.membershipValidTill != null
                      ? "Valid till: ${c.membershipValidTill!.split('T').first}"
                      : "",
                  style: TextStyle(
                    color: DateTime.tryParse(c.membershipValidTill ?? "")
                                ?.isBefore(DateTime.now()) ==
                            true
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              );
            } else {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomLoadingAvatar(),
              ));
            }
          },
        );
      }),
    );
  }
}
