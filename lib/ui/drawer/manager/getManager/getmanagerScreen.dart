import 'package:flutter/material.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/ui/drawer/manager/getManager/getmanagerController.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:get/get.dart';
import 'package:flutter_template/ui/drawer/manager/addManager/managerScreen.dart';
import 'package:flutter_template/ui/drawer/manager/addManager/managerController.dart';
import 'package:flutter_template/wiget/loading.dart';

import '../udpateFromExisting/upgradeFromExistingScreen.dart';

class Getmanagerscreen extends StatelessWidget {
  Getmanagerscreen({super.key});
  final Getmanagercontroller getController = Get.put(Getmanagercontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Manager",
        actions: [
          PopupMenuButton<String>(
            // icon: Icon(Icons.filter_list, color: white),
            onSelected: (value) {
              if (value == 'all') {
                getController.clearFilter();
              } else {
                // Find the branch by name
                final branch = getController.branchList
                    .firstWhereOrNull((b) => b.name == value);
                if (branch != null) {
                  getController.setBranchFilter(branch);
                }
              }
            },
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> items = [
                PopupMenuItem<String>(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: primaryColor),
                      SizedBox(width: 8),
                      Text('All Branches'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
              ];

              // Add branch filter options
              for (var branch in getController.branchList) {
                items.add(
                  PopupMenuItem<String>(
                    value: branch.name ?? '',
                    child: Row(
                      children: [
                        Icon(Icons.business, color: primaryColor),
                        SizedBox(width: 8),
                        Text(branch.name ?? ''),
                      ],
                    ),
                  ),
                );
              }

              return items;
            },
          ),
        ],
      ),
      drawer: DrawerScreen(),
      body: Obx(() {
        return getController.isLoading.value
            ? const Center(child: CustomLoadingAvatar())
            : RefreshIndicator(
                color: primaryColor,
                onRefresh: () async {
                  await getController.getManagers();
                },
                child: getController.filteredManagers.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(height: 200),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.people_outline,
                                    size: 64, color: Colors.grey[400]),
                                SizedBox(height: 16),
                                Text(
                                  getController.selectedBranchFilter.value !=
                                          null
                                      ? "No managers found in ${getController.selectedBranchFilter.value!.name}"
                                      : "No managers found",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                if (getController.selectedBranchFilter.value !=
                                    null)
                                  TextButton(
                                    onPressed: () =>
                                        getController.clearFilter(),
                                    child: Text(
                                      'Clear Filter',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: getController.filteredManagers.length,
                        itemBuilder: (context, index) {
                          final manager = getController.filteredManagers[index];
                          return ExpansionTile(
                            leading: manager.image_url.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      '${Apis.pdfUrl}${manager.image_url}?v=${DateTime.now().millisecondsSinceEpoch}',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 50,
                                          height: 50,
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
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child:
                                        const Icon(Icons.image_not_supported),
                                  ),
                            // leading: CircleAvatar(
                            //   backgroundColor: Colors.grey[300],
                            //   child: manager.image_url.isNotEmpty
                            //       ? ClipOval(
                            //           child: Image.network(
                            //             '${Apis.pdfUrl}${manager.image_url}?v=${DateTime.now().millisecondsSinceEpoch}',
                            //             width: 40,
                            //             height: 40,
                            //             fit: BoxFit.cover,
                            //             errorBuilder:
                            //                 (context, error, stackTrace) {
                            //               return Icon(Icons.person,
                            //                   color: Colors.grey[600]);
                            //             },
                            //           ),
                            //         )
                            //       : Icon(Icons.person, color: Colors.grey[600]),
                            // ),
                            shape: Border.all(color: Colors.transparent),
                            title: Text('${manager.full_name}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${manager.contactNumber}'),
                                // Text('${manager.email}'),
                                // Text('${manager.branchName}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit_outlined,
                                      color: primaryColor),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            Managerscreen(manager: manager),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color: primaryColor),
                                  onPressed: () {
                                    getController.deleteManager(manager.id);
                                  },
                                ),
                              ],
                            ),
                            children: [
                              Text('Email: ${manager.email}'),
                              Text('Contact: ${manager.contactNumber}'),
                              Text('Branch: ${manager.branchName}'),
                            ],
                          );
                        },
                      ),
              );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                title: const Text(
                  'Create Manager',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: primaryColor,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Choose how you want to create the manager:',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildOptionButton(
                          icon: Icons.group,
                          label: 'From Staff',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.to(Upgradefromexistingscreen());
                          },
                        ),
                        _buildOptionButton(
                          icon: Icons.person_add_alt_1,
                          label: 'Create New',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.of(context).pop();
                            if (Get.isRegistered<Managercontroller>()) {
                              Get.delete<Managercontroller>(force: true);
                            }
                            Get.to(Managerscreen());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                actionsPadding: const EdgeInsets.all(16.0),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(
          Icons.add,
          color: white,
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
