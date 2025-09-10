// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_template/main.dart';
// import 'package:flutter_template/network/network_const.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// class VersionController extends GetxController {
//   final latestVersion = "".obs;
//   final forceUpdate = true.obs;
//   final playStoreUrl = "".obs;
//   final appStoreUrl = "".obs;

//   @override
//   void onInit() {
//     super.onInit();
//     checkVersion();
//   }

//   Future<void> checkVersion() async {
//     try {
//       // Get installed version
//       final packageInfo = await PackageInfo.fromPlatform();
//       final currentVersion = packageInfo.version;

//       // Fetch latest version info
//       final response = await dioClient.dio.get(
//         "${Apis.baseUrl}/version-control",
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.data);

//         latestVersion.value = data['latest_version'] ?? "";
//         forceUpdate.value = data['force_update'] ?? false;
//         playStoreUrl.value = data['play_store_url'] ?? "";
//         appStoreUrl.value = data['app_store_url'] ?? "";

    
//         if (_isVersionLower(currentVersion, latestVersion.value)) {
//           _showUpdateDialog(Get.context!);
//         }
//       }
//     } catch (e) {
//       debugPrint("Version check failed: $e");
//     }
//   }

//   bool _isVersionLower(String current, String latest) {
//     final currentParts = current.split('.').map(int.parse).toList();
//     final latestParts = latest.split('.').map(int.parse).toList();

//     for (int i = 0; i < latestParts.length; i++) {
//       if (i >= currentParts.length || currentParts[i] < latestParts[i]) {
//         return true;
//       } else if (currentParts[i] > latestParts[i]) {
//         return false;
//       }
//     }
//     return false;
//   }

//   void _showUpdateDialog(BuildContext context) {
//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async =>
//             !forceUpdate.value, 
//         child: Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           insetPadding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // App Icon / Update Illustration
//                 Icon(Icons.system_update_alt,
//                     size: 60, color: Colors.blueAccent),

//                 const SizedBox(height: 16),

//                 // Title
//                 Text(
//                   forceUpdate.value ? "Update Required" : "Update Available",
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),

//                 const SizedBox(height: 12),

//                 // Description
//                 Text(
//                   forceUpdate.value
//                       ? "To continue using the app, please update to version ${latestVersion.value}."
//                       : "A new version (${latestVersion.value}) is available. Update now to enjoy the latest features.",
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black54,
//                     height: 1.4,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),

//                 const SizedBox(height: 24),

//                 // Buttons
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Later button (only if not forced)
//                     if (!forceUpdate.value)
//                       Expanded(
//                         child: OutlinedButton(
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text("Later"),
//                           onPressed: () => Get.back(),
//                         ),
//                       ),

//                     if (!forceUpdate.value) const SizedBox(width: 12),

//                     // Update Now button
//                     Expanded(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           backgroundColor: Colors.blueAccent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 2,
//                         ),
//                         child: const Text(
//                           "Update Now",
//                           style: TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                         onPressed: () async {
//                           final url = GetPlatform.isIOS
//                               ? appStoreUrl.value
//                               : playStoreUrl.value;

//                           if (url.isNotEmpty &&
//                               await canLaunchUrl(Uri.parse(url))) {
//                             await launchUrl(
//                               Uri.parse(url),
//                               mode: LaunchMode.externalApplication,
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       barrierDismissible: !forceUpdate.value,
//     );
//   }
// }
