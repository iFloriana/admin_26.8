import 'package:flutter/material.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import '../../network/network_const.dart';
import '../../utils/app_images.dart';
import '../../wiget/appbar/commen_appbar.dart';
import '../../wiget/custome_text.dart';
import 'managerProfileCOntroller.dart';

class Managerprofilescreen extends StatelessWidget {
  Managerprofilescreen({super.key});
  final getController = Get.put(Managerprofilecontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Manager Profile',
      ),
      drawer: ManagerDrawerScreen(),
      body: Obx(() {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [secondaryColor, primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: getController.image.value.isEmpty
                            ? const AssetImage(AppImages.placeholder)
                                as ImageProvider
                            : NetworkImage(
                                '${Apis.pdfUrl}${getController.image.value}?v=${DateTime.now().millisecondsSinceEpoch}',
                              ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        getController.fullname.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        getController.email.value,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Profile details in a card

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildProfileRow(Icons.person, "Full Name",
                            getController.fullname.value),
                        const Divider(),
                        _buildProfileRow(
                            Icons.phone, "Phone", getController.phone.value),
                        const Divider(),
                        _buildProfileRow(
                            Icons.email, "Email", getController.email.value),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // 🔹 Helper widget for profile row
  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  )),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        )
      ],
    );
  }
}
