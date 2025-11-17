import 'package:flutter/material.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart' as dio;
import '../../../main.dart';
import '../../../network/model/packages_model.dart';
import '../../../wiget/custome_snackbar.dart';

class RenewPackagesController extends GetxController {
  var adminName = ''.obs;
  var adminEmail = ''.obs;
  var salonName = ''.obs;
  var adminId = ''.obs;
  var isLoading = false.obs;
  var emailController = TextEditingController();
  var packages = <Package_model>[].obs;
  var selectedPackageId = RxnString();
  late Razorpay _razorpay;

  @override
  void onInit() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.onInit();
  }

  @override
  void onClose() {
    _razorpay.clear();
    emailController.dispose();
    super.onClose();
  }

  Future<void> verifyEmail(String email) async {
    if (email.isEmpty) {
      CustomSnackbar.showError("Error", "Please enter an email");
      return;
    }

    try {
      isLoading.value = true;
      adminName.value = '';
      adminEmail.value = '';
      salonName.value = '';
      adminId.value = '';

      final response =
          await dioClient.dio.post('${Apis.baseUrl}/auth/verify-email', data: {
        "email": email,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        adminName.value = data['admin']['full_name'] ?? '';
        adminEmail.value = data['admin']['email'] ?? '';
        salonName.value = data['salonDetails']['salon_name'] ?? '';
        adminId.value = data['admin']['_id'] ?? ''; // Store adminId
      } else {
        CustomSnackbar.showError(
            "Error", "Server Error: ${response.statusMessage}");
      }
    } catch (e) {
      CustomSnackbar.showError("Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPackages() async {
    try {
      isLoading.value = true;
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.packages}',
        (json) => (json as List<dynamic>)
            .map((e) => Package_model.fromJson(e))
            .toList(),
      );
      packages.value = response;
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch packages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateSelected(String value) {
    selectedPackageId.value = value;
  }

  Future<void> renewPackage() async {
    if (selectedPackageId.value == null) {
      CustomSnackbar.showError("Error", "No package selected");
      return;
    }

    // Start payment process
    startPayment();
  }

  void startPayment() {
    var selectedPackage =
        packages.firstWhereOrNull((pkg) => pkg.sId == selectedPackageId.value);
    if (selectedPackage != null) {
      var options = {
        'key': dotenv.env['RAZORPAY_KEY_ID'],
        'amount': (selectedPackage.price! * 100).toInt(),
        'name': selectedPackage.packageName,
        'description': selectedPackage.description,
        'prefill': {
          'contact': '', // Phone number can be added if available
          'email': adminEmail.value,
        },
        'external': {
          'wallets': ['paytm']
        }
      };
      try {
        _razorpay.open(options);
      } catch (e) {
        CustomSnackbar.showError('Error', 'Failed to open Razorpay: $e');
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      String paymentId = response.paymentId ?? '';
      var selectedPackage = packages
          .firstWhereOrNull((pkg) => pkg.sId == selectedPackageId.value);
      if (selectedPackage != null) {
        double amount = selectedPackage.price! * 100.0;
        await dioClient.capturePayment(paymentId, amount);

        // Call renew-package API
        final payload = {
          "package_id": selectedPackageId.value,
        };

        final renewResponse = await dioClient.dio.patch(
          '${Apis.baseUrl}/auth/renew-package/${adminId.value}',
          data: payload,
          options: dio.Options(
            headers: {"Content-Type": "application/json"},
          ),
        );

        if (renewResponse.statusCode == 200) {
          prefs.onLogout();
        } else {
          CustomSnackbar.showError('Error',
              'Package renewal failed: ${renewResponse.statusMessage}');
        }
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Package renewal failed: $e');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    CustomSnackbar.showError('Error', 'Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    CustomSnackbar.showSuccess(
        'Info', 'External Wallet selected: ${response.walletName}');
  }

  void clearData() {
    emailController.clear();
    adminName.value = '';
    adminEmail.value = '';
    salonName.value = '';
    adminId.value = '';
    selectedPackageId.value = null;
    packages.clear();
  }
}
