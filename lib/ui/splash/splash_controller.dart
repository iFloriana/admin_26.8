import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../route/app_route.dart';
import '../../wiget/custome_snackbar.dart';

class SplashController extends GetxController {
  // State to track if update is required
  RxBool isUpdateRequired = false.obs;
  RxBool isForceUpdate = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAppVersion();
  }

  /// Check app version from API
  Future<void> _checkAppVersion() async {
    try {
      // 📱 Current installed app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      debugPrint("📱 Current Version: $currentVersion");

      // 🌐 API call to get latest version info
      final response =
          await dioClient.dio.get("${Apis.baseUrl}/version-control");

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data;

        final latestVersion = data['latest_version'] ?? "";
        final forceUpdate = data['force_update'] ?? false;
        final playStoreUrl = data['play_store_url'] ?? "";
        final appStoreUrl = data['app_store_url'] ?? "";

        debugPrint(
            "🌐 Latest Version: $latestVersion | Force Update: $forceUpdate");

        // ⚠️ Check if update is required
        if (_isVersionLower(currentVersion, latestVersion)) {
          isUpdateRequired.value = true;
          isForceUpdate.value = forceUpdate;

          _showUpdateDialog(
              forceUpdate, latestVersion, playStoreUrl, appStoreUrl);
          return; // stop navigation
        }
      }

      // ✅ If up-to-date → navigate
      navigateToNextScreen();
    } catch (e) {
      debugPrint("⚠️ Version check failed: $e");
      navigateToNextScreen(); // fallback
    }
  }

  /// Compare current and latest version
  bool _isVersionLower(String current, String latest) {
    final currentParts = current.split('.').map(int.tryParse).toList();
    final latestParts = latest.split('.').map(int.tryParse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      final c = (i < currentParts.length ? currentParts[i] : 0) ?? 0;
      final l = latestParts[i] ?? 0;
      if (c < l) return true; // needs update
      if (c > l) return false; // already newer
    }
    return false; // equal
  }

  /// Show update dialog
  void _showUpdateDialog(bool forceUpdate, String latestVersion,
      String playStoreUrl, String appStoreUrl) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => !forceUpdate, // block back button if forced
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.system_update_alt,
                    size: 60, color: primaryColor),
                const SizedBox(height: 16),
                Text(
                  forceUpdate ? "Update Required" : "Update Available",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  forceUpdate
                      ? "You must update to version $latestVersion to continue using the app."
                      : "A new version ($latestVersion) is available. Update now to enjoy the latest features.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (!forceUpdate)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.back();
                            navigateToNextScreen(); // navigate only if not forced
                          },
                          child: const Text("Later"),
                        ),
                      ),
                    if (!forceUpdate) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final url =
                              GetPlatform.isIOS ? appStoreUrl : playStoreUrl;
                          if (url.isNotEmpty &&
                              await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          } else {
                            CustomSnackbar.showError(
                                "Error", "Update link not available.");
                          }
                        },
                        child: const Text("Update Now",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: !forceUpdate,
    );
  }

  /// Navigate to appropriate screen if update is not forced
  void navigateToNextScreen() async {
    try {
      // ❌ Do NOT navigate if forced update is required
      if (isUpdateRequired.value && isForceUpdate.value) return;

      final user = await prefs.getUser();
      final managerUser = await prefs.getManagerUser();

      String? accessToken = user?.token;
      String? managerAccessToken = managerUser?.token;

      if (accessToken != null && accessToken.isNotEmpty) {
        Get.offNamed(Routes.dashboardScreen);
      } else if (managerAccessToken != null && managerAccessToken.isNotEmpty) {
        Get.offNamed(Routes.managerDashboard);
      } else {
        Get.offNamed(Routes.loginScreen);
      }
    } catch (e) {
      CustomSnackbar.showError('Error', '$e');
    }
  }
}
