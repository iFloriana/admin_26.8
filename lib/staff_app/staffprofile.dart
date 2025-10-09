import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:get/get.dart';

/// Controller without model (using Map only)
class StaffProfileController extends GetxController {
  var loading = false.obs;
  var staffData = {}.obs;
  Future<void> onLogoutPress() async {
    await prefs.onLogout();
  }

  Future<void> fetchStaffProfile(String staffId, String salonId) async {
    loading.value = true;
    try {
      final response = await dioClient.dio.get(
        "${Apis.baseUrl}/staffs/$staffId",
        queryParameters: {"salon_id": salonId},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        staffData.value = response.data['data'];
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load staff profile",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    loading.value = false;
  }
}

/// Staff Profile Screen (UI)
class StaffProfileScreen extends StatelessWidget {
  final String staffId;
  final String salonId;

  const StaffProfileScreen({
    super.key,
    required this.staffId,
    required this.salonId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StaffProfileController());
    controller.fetchStaffProfile(staffId, salonId);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        title: "Profile",
        actions: [
          IconButton(
            onPressed: () {
              controller.onLogoutPress();
            },
            icon: Icon(Icons.logout_outlined),
            color: white,
          )
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CustomLoadingAvatar());
        }

        if (controller.staffData.isEmpty) {
          return const Center(child: Text("No profile data"));
        }

        final staff = controller.staffData;
        final branch = staff['branch_id'];
        final services = List.from(staff['service_id'] ?? []);
        final commission = staff['assigned_commission_id']?['commission'] ?? [];
        final assignTime = staff['assign_time'] ?? {};
        final lunchTime = staff['lunch_time'] ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            backgroundImage: staff['image_url'] != null &&
                                    staff['image_url'].toString().isNotEmpty
                                ? NetworkImage(
                                    "${Apis.pdfUrl}${staff['image_url']}",
                                  )
                                : null,
                            child: (staff['image_url'] == null ||
                                    staff['image_url'].toString().isEmpty)
                                ? Text(
                                    staff['full_name']?[0] ?? "?",
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            staff['full_name'] ?? "N/A",
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            staff['specialization'] ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.email,
                              color: primaryColor,
                            ),
                            title: Text(staff['email'] ?? ""),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.phone,
                              color: primaryColor,
                            ),
                            title: Text(staff['phone_number'] ?? ""),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: primaryColor,
                            ),
                            title: Text("Gender: ${staff['gender'] ?? '-'}"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Branch Info
              Card(
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: Text(branch?['name'] ?? "No branch assigned"),
                  subtitle: Text(branch?['address'] ?? ""),
                ),
              ),

              const SizedBox(height: 20),

              /// Shift & Lunch
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.access_time,
                        color: primaryColor,
                      ),
                      title: const Text("Shift Time"),
                      subtitle: Text(
                        "${assignTime['start_shift'] ?? '-'} - ${assignTime['end_shift'] ?? '-'}",
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.lunch_dining,
                        color: primaryColor,
                      ),
                      title: const Text("Lunch Break"),
                      subtitle: Text(
                        "At ${lunchTime['timing'] ?? '-'} • ${lunchTime['duration'] ?? '-'} mins",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Commission Section
              Text(
                "Commission Structure",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (commission.isEmpty)
                const Text("No commission data")
              else
                Column(
                  children: commission
                      .map<Widget>(
                        (c) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(
                              Icons.monetization_on,
                              color: Colors.green,
                            ),
                            title: Text("Slot: ${c['slot']}"),
                            subtitle: Text("Commission: ${c['amount']}%"),
                          ),
                        ),
                      )
                      .toList(),
                ),

              const SizedBox(height: 20),

              /// Services
              Text(
                "Services",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (services.isEmpty)
                const Text("No services assigned")
              else
                Column(
                  children: services
                      .map(
                        (service) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.cut,
                              color: primaryColor,
                            ),
                            title: Text(service['name'] ?? "Unnamed"),
                            subtitle: Text(
                              "₹ ${service['regular_price'] ?? 0} • ${service['service_duration'] ?? ''} mins",
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      }),
    );
  }
}
