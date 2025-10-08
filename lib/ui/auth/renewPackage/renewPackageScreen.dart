import 'package:flutter/material.dart';
import 'package:flutter_template/ui/auth/renewPackage/renewPackageController.dart';
import 'package:get/get.dart';

class Renewpackagescreen extends StatelessWidget {
  Renewpackagescreen({super.key});

  final getController = Get.put(RenewPackagesController());

  @override
  Widget build(BuildContext context) {
    // Show dialog after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset controller states before opening dialog
      getController.clearData();

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Verify Email",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),

                // Email field
                TextField(
                  controller: getController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Enter Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Loading or Result
                Obx(() {
                  if (getController.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child:
                          CircularProgressIndicator(color: Colors.deepPurple),
                    );
                  }

                  if (getController.adminName.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.deepPurple.shade100,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "✅ Admin: ${getController.adminName.value}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("📧 ${getController.adminEmail.value}",
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                            "🏢 Salon: ${getController.salonName.value}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 24),

                // Dynamic buttons
                Obx(() {
                  final hasData = getController.adminName.isNotEmpty &&
                      getController.adminEmail.isNotEmpty &&
                      getController.salonName.isNotEmpty;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text("Cancel"),
                      ),

                      // Change button dynamically
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          if (hasData) {
                            // ✅ Call renew package API
                            getController.renewPackage();
                          } else {
                            // 🔍 Verify email first
                            getController.verifyEmail(
                              getController.emailController.text.trim(),
                            );
                          }
                        },
                        child: Text(
                          hasData ? "Renew Package" : "Check Email",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Renew Package Screen'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Renew Package functionality is in the dialog above.'),
      ),
    );
  }
}
