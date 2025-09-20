import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/Custome_textfield.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';
import '../wiget/custome_snackbar.dart';

class Branch1 {
  final String? id;
  final String? name;

  Branch1({this.id, this.name});

  factory Branch1.fromJson(Map<String, dynamic> json) {
    return Branch1(
      id: json['_id'],
      name: json['name'],
    );
  }
}

// 🎯 Controller
class managerFinanceController extends GetxController {
  var selectedImage = Rx<File?>(null);
  var selectedCategory = "".obs;
  final ImagePicker _picker = ImagePicker();
  final vendorNameCtrl = TextEditingController();
  final vendoramountCtrl = TextEditingController();
  final vendornoteCtrl = TextEditingController();
  final receivce_from_owner_amountCtrl = TextEditingController();
  final receivce_from_owner_noteCtrl = TextEditingController();
  final owner_deposit_amountCtrl = TextEditingController();
  final owner_deposit_noteCtrl = TextEditingController();
  final addExpenceamountCtrl = TextEditingController();
  final addExpencenoteCtrl = TextEditingController();
  var branchList = <Branch1>[].obs;
  var selectedBranchId = "".obs;
  final categories = [
    "Food & Drinks",
    "Maintenance",
    "Cleaning",
    "Salon equipments",
    "Others"
  ];
  var financeData = <String, dynamic>{}.obs;
  var isLoading = false.obs;
  var selectedDateRange = Rxn<DateTimeRange>();
  var branches = <Map<String, String>>[].obs;
  var selectedBranch = "".obs;
  var expensesData = {}.obs;
  var openingBalance = 0.0.obs;
  // Totals
  var totalCredit = 0.0.obs;
  var totalDebit = 0.0.obs;
  @override
  void onInit() {
    super.onInit();
    fetchFinanceData();
    fetchBranches();
  }

  Future<void> fetchBranches() async {
    try {
      final getdata = await prefs.getManagerUser();

      final response = await dioClient.dio.get(
        "${Apis.baseUrl}/branches/names?salon_id=${getdata?.manager?.salonId}",
      );

      if (response.statusCode == 200) {
        final List data = response.data["data"];
        branches.value = [
          {"_id": "", "name": "All Branches"}, // default option
          ...data.map((e) => {"_id": e["_id"], "name": e["name"]})
        ];
      }
    } catch (e) {
      print("Error fetching branches: $e");
    }
  }

  Future<void> fetchOpeningBalance({
    required String salonId,
    required String branchId,
  }) async {
    try {
      final response = await dioClient.dio.get(
        "${Apis.baseUrl}/expenses/opening-balance",
        queryParameters: {
          "salon_id": salonId,
          "branch_id": branchId,
        },
      );

      if (response.statusCode == 200 &&
          response.data["success"] == true &&
          response.data["balance"] != null) {
        openingBalance.value =
            double.tryParse("${response.data["balance"]["opening_balance"]}") ??
                0.0;
      } else {
        openingBalance.value = 0.0;
      }
    } catch (e) {
      print("Error fetching opening balance: $e");
      openingBalance.value = 0.0;
    }
  }

  Future<void> fetchFinanceData() async {
    try {
      isLoading.value = true;
      final getdata = await prefs.getManagerUser();

      // Build query
      Map<String, dynamic> query = {
        "salon_id": getdata?.manager?.salonId,
      };

      if (selectedBranchId.value.isNotEmpty) {
        query["branch_id"] = selectedBranchId.value;

        // 🆕 Fetch opening balance for the selected branch
        await fetchOpeningBalance(
          salonId: getdata?.manager?.salonId ?? "",
          branchId: selectedBranchId.value,
        );
      } else {
        // Reset if "All Branches" is selected
        openingBalance.value = 0.0;
      }

      final response = await dioClient.dio.get(
        "${Apis.baseUrl}/expenses",
        queryParameters: query,
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        final Map<String, dynamic> raw =
            Map<String, dynamic>.from(response.data["data"] ?? {});
        final Map<String, dynamic> filteredMap = {};
        final DateTimeRange? range = selectedDateRange.value;

        // Precompute inclusive start/end (local dates)
        DateTime? start;
        DateTime? end;
        if (range != null) {
          start =
              DateTime(range.start.year, range.start.month, range.start.day);
          end = DateTime(
            range.end.year,
            range.end.month,
            range.end.day,
            23,
            59,
            59,
            999,
          );
        }

        raw.forEach((dateKey, items) {
          List<dynamic> itemsList = List<dynamic>.from(items ?? []);

          if (range != null) {
            itemsList = itemsList.where((item) {
              try {
                final created = DateTime.parse(item["created_at"]).toLocal();
                return !(created.isBefore(start!) || created.isAfter(end!));
              } catch (e) {
                return false;
              }
            }).toList();

            // 🔥 Strict filter on the dateKey itself
            try {
              final dateObj = DateTime.parse(dateKey).toLocal();
              if (dateObj.isBefore(start!) || dateObj.isAfter(end!)) {
                itemsList = []; // force empty if date is outside
              }
            } catch (_) {}
          }

          if (itemsList.isNotEmpty) {
            filteredMap[dateKey] = itemsList;
          }
        });

        financeData.value = filteredMap;

        // recalc totals from the filteredMap
        double credit = 0;
        double debit = 0;
        filteredMap.forEach((date, transactions) {
          for (var t in transactions) {
            if (t["type"] == "receive_from_owner_account") {
              credit += (t["amount"] ?? 0).toDouble();
            } else if (t["type"] == "vendor_pay" ||
                t["type"] == "deposit_to_owner_account") {
              debit += (t["amount"] ?? 0).toDouble();
            }
          }
        });
        totalCredit.value = credit;
        totalDebit.value = debit;
      }
    } catch (e) {
      print("⚠️ Finance fetch error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> postVendorPayment(File? imageFile) async {
    var getdata = await prefs.getManagerUser();

    try {
      MultipartFile? imageMultipart;

      if (imageFile != null) {
        final fileName = imageFile.path.split('/').last;
        final ext = fileName.split('.').last.toLowerCase();

        // ✅ Allow only jpg, jpeg, png
        if (["jpg", "jpeg", "png"].contains(ext)) {
          String mimeType = ext == "png" ? "png" : "jpeg";

          imageMultipart = await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: MediaType("image", mimeType),
          );
        } else {
          // ❌ Invalid format, show error and stop request
          CustomSnackbar.showError(
            "Invalid File",
            "Only .jpg, .jpeg, .png formats are allowed",
          );
          return;
        }
      }

      FormData formData = FormData.fromMap({
        "salon_id": getdata?.manager?.salonId,
        "branch_id": getdata?.manager?.branchId?.sId,
        "type": "vendor_pay",
        "vendor_name": vendorNameCtrl.text.trim(),
        "amount": vendoramountCtrl.text.trim(),
        "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "note": vendornoteCtrl.text.trim(),
        if (imageMultipart != null) "image": imageMultipart,
      });

      var response = await dioClient.dio.post(
        "${Apis.baseUrl}/expenses",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        print("✅ Success Response: ${response.data}");
        vendorNameCtrl.clear();
        vendoramountCtrl.clear();
        vendornoteCtrl.clear();

        // 🔹 Clear image from controller
        clearImage();
        Get.back();
        CustomSnackbar.showSuccess("Success", "Payment added successfully");
      } else {
        print("❌ Error: ${response.data}");
        CustomSnackbar.showError(
          "Error",
          response.data["message"] ?? "Failed to add payment",
        );
      }
    } catch (e) {
      print("⚠️ Exception: $e");
      Get.snackbar("Exception", e.toString());
    }
  }

  Future<void> recivefromOwner(File? imageFile) async {
    var getdata = await prefs.getManagerUser();

    try {
      MultipartFile? imageMultipart;

      if (imageFile != null) {
        final fileName = imageFile.path.split('/').last;
        final ext = fileName.split('.').last.toLowerCase();

        // ✅ Allow only jpg, jpeg, png
        if (["jpg", "jpeg", "png"].contains(ext)) {
          String mimeType = ext == "png" ? "png" : "jpeg";

          imageMultipart = await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: MediaType("image", mimeType),
          );
        } else {
          // ❌ Invalid format, show error and stop request
          CustomSnackbar.showError(
            "Invalid File",
            "Only .jpg, .jpeg, .png formats are allowed",
          );
          return;
        }
      }

      FormData formData = FormData.fromMap({
        "salon_id": getdata?.manager?.salonId,
        "branch_id": getdata?.manager?.branchId?.sId,
        "type": "receive_from_owner_account",
        "amount": receivce_from_owner_amountCtrl.text.trim(),
        "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "note": receivce_from_owner_noteCtrl.text.trim(),
        if (imageMultipart != null) "image": imageMultipart,
      });

      var response = await dioClient.dio.post(
        "${Apis.baseUrl}/expenses",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        print("✅ Success Response: ${response.data}");
        receivce_from_owner_amountCtrl.clear();
        receivce_from_owner_noteCtrl.clear();
        clearImage();
        Get.back();
        CustomSnackbar.showSuccess("Success", "Payment added successfully");
      } else {
        print("❌ Error: ${response.data}");
        CustomSnackbar.showError(
          "Error",
          response.data["message"] ?? "Failed to add payment",
        );
      }
    } catch (e) {
      print("⚠️ Exception: $e");
      Get.snackbar("Exception", e.toString());
    }
  }

  Future<void> owenerDeposit(File? imageFile) async {
    var getdata = await prefs.getManagerUser();

    try {
      MultipartFile? imageMultipart;

      if (imageFile != null) {
        final fileName = imageFile.path.split('/').last;
        final ext = fileName.split('.').last.toLowerCase();

        // ✅ Allow only jpg, jpeg, png
        if (["jpg", "jpeg", "png"].contains(ext)) {
          String mimeType = ext == "png" ? "png" : "jpeg";

          imageMultipart = await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: MediaType("image", mimeType),
          );
        } else {
          // ❌ Invalid format, show error and stop request
          CustomSnackbar.showError(
            "Invalid File",
            "Only .jpg, .jpeg, .png formats are allowed",
          );
          return;
        }
      }

      FormData formData = FormData.fromMap({
        "salon_id": getdata?.manager?.salonId,
        "branch_id": getdata?.manager?.branchId?.sId,
        "type": "deposit_to_owner_account",
        "amount": owner_deposit_amountCtrl.text.trim(),
        "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "note": owner_deposit_noteCtrl.text.trim(),
        if (imageMultipart != null) "image": imageMultipart,
      });

      var response = await dioClient.dio.post(
        "${Apis.baseUrl}/expenses",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        print("✅ Success Response: ${response.data}");
        owner_deposit_amountCtrl.clear();
        owner_deposit_noteCtrl.clear();
        clearImage();
        Get.back();
        CustomSnackbar.showSuccess("Success", "Payment added successfully");
      } else {
        print("❌ Error: ${response.data}");
        CustomSnackbar.showError(
          "Error",
          response.data["message"] ?? "Failed to add payment",
        );
      }
    } catch (e) {
      print("⚠️ Exception: $e");
      Get.snackbar("Exception", e.toString());
    }
  }

  Future<void> add_expance(File? imageFile) async {
    var getdata = await prefs.getManagerUser();

    try {
      MultipartFile? imageMultipart;

      if (imageFile != null) {
        final fileName = imageFile.path.split('/').last;
        final ext = fileName.split('.').last.toLowerCase();

        // ✅ Allow only jpg, jpeg, png
        if (["jpg", "jpeg", "png"].contains(ext)) {
          String mimeType = ext == "png" ? "png" : "jpeg";

          imageMultipart = await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: MediaType("image", mimeType),
          );
        } else {
          // ❌ Invalid format, show error and stop request
          CustomSnackbar.showError(
            "Invalid File",
            "Only .jpg, .jpeg, .png formats are allowed",
          );
          return;
        }
      }

      FormData formData = FormData.fromMap({
        "category": selectedCategory.value,
        "salon_id": getdata?.manager?.salonId,
        "branch_id": getdata?.manager?.branchId?.sId,
        "type": 'add_expense',
        "amount": addExpenceamountCtrl.text.trim(),
        "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "note": addExpencenoteCtrl.text.trim(),
        if (imageMultipart != null) "image": imageMultipart,
      });

      var response = await dioClient.dio.post(
        "${Apis.baseUrl}/expenses",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        print("✅ Success Response: ${response.data}");
        addExpencenoteCtrl.clear();
        addExpenceamountCtrl.clear();
        clearImage();
        Get.back();
        CustomSnackbar.showSuccess("Success", "Payment added successfully");
      } else {
        print("❌ Error: ${response.data}");
        CustomSnackbar.showError(
          "Error",
          response.data["message"] ?? "Failed to add payment",
        );
      }
    } catch (e) {
      print("⚠️ Exception: $e");
      Get.snackbar("Exception", e.toString());
    }
  }

  Future<void> pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      if (await Permission.camera.request().isDenied) {
        Get.snackbar("Permission Denied", "Camera access is required");
        return;
      }
    } else {
      if (await Permission.photos.request().isDenied &&
          await Permission.storage.request().isDenied) {
        Get.snackbar("Permission Denied", "Gallery access is required");
        return;
      }
    }

    final picked = await _picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      selectedImage.value = File(picked.path);
    }
  }

  void clearImage() {
    selectedImage.value = null;
  }

  void showImagePickerOptions(Color color) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          runSpacing: 15,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: color),
              title: const Text("Capture from Camera"),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.photo_library, color: color),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 🎯 Main Page
class managerFinancePage extends StatelessWidget {
  final managerFinanceController controller =
      Get.put(managerFinanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Finance Dashboard",
        actions: [
          Obx(() {
            // find selected branch
            final selected = controller.branches.firstWhere(
              (b) => b["_id"] == controller.selectedBranchId.value,
              orElse: () => {"_id": "", "name": "All Branches"},
            );

            // get first letter
            final firstLetter = (selected["name"] ?? "A").isNotEmpty
                ? selected["name"]![0].toUpperCase()
                : "A";

            return PopupMenuButton<String>(
              onSelected: (value) {
                controller.selectedBranchId.value = value;
                controller.fetchFinanceData();
              },
              itemBuilder: (context) {
                return controller.branches
                    .map(
                      (branch) => PopupMenuItem<String>(
                        value: branch["_id"]!,
                        child: Text(branch["name"]!),
                      ),
                    )
                    .toList();
              },
              child: CircleAvatar(
                radius: 15,
                backgroundColor: secondaryColor,
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
          Obx(() {
            final range = controller.selectedDateRange.value;
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: Get.context!,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: range,
                    );
                    if (picked != null) {
                      controller.selectedDateRange.value = picked;
                      controller.fetchFinanceData();
                    }
                  },
                ),
              ],
            );
          }),
        ],
      ),
      drawer: ManagerDrawerScreen(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CustomLoadingAvatar());
        }

        if (controller.financeData.isEmpty) {
          return const Center(child: Text("No finance data found"));
        }

        return Column(
          children: [
            // 🔹 Totals Section
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (controller.selectedBranchId.value.isNotEmpty)
                    Expanded(
                      child: Card(
                        color: Colors.blue.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.account_balance_wallet,
                                  color: Colors.blue, size: 26),
                              const SizedBox(height: 8),
                              const Text("Opening Balance",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Obx(() => Text(
                                    "₹ ${controller.openingBalance.value.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Card(
                      color: Colors.green.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.arrow_downward,
                                color: Colors.green, size: 32),
                            const SizedBox(height: 8),
                            const Text("Total Credit",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              "₹ ${controller.totalCredit.value.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: Colors.red.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.arrow_upward,
                                color: Colors.red, size: 32),
                            const SizedBox(height: 8),
                            const Text("Total Debit",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              "₹ ${controller.totalDebit.value.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Transactions List by Date
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: controller.financeData.entries.map((entry) {
                  final date = entry.key;
                  final transactions = entry.value;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                          dividerColor: transparent, focusColor: primaryColor),
                      child: ExpansionTile(
                        leading: const Icon(Icons.calendar_today,
                            color: primaryColor),
                        title: Text(
                          date,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        children: List.generate(transactions.length, (index) {
                          final txn = transactions[index];
                          bool isCredit =
                              txn["type"] == "receive_from_owner_account";
                          bool isDebit = txn["type"] == "vendor_pay" ||
                              txn["type"] == "deposit_to_owner_account";
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isCredit
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              child: Icon(
                                isCredit
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isCredit ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              txn["vendor_name"] ?? txn["type"],
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              txn["notes"] ?? "No notes",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Amount
                                Text(
                                  "₹ ${txn["amount"]}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCredit ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // 🔹 Show invoice icon if image_url exists
                                if (txn["image_url"] != null &&
                                    txn["image_url"].toString().isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      showGeneralDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        barrierLabel: '',
                                        barrierColor:
                                            Colors.black.withOpacity(0.85),
                                        pageBuilder: (context, anim1, anim2) {
                                          return Center(
                                            child: Stack(
                                              children: [
                                                InteractiveViewer(
                                                  child: Image.network(
                                                    "${Apis.pdfUrl}${txn["image_url"]}",
                                                    fit: BoxFit.contain,
                                                    width: double.infinity,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Icon(
                                                            Icons.broken_image,
                                                            size: 100,
                                                            color:
                                                                Colors.white70),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 40,
                                                  right: 20,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                        Icons.cancel,
                                                        color: Colors.white,
                                                        size: 35),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        transitionBuilder:
                                            (context, anim1, anim2, child) =>
                                                FadeTransition(
                                                    opacity: anim1,
                                                    child: child),
                                        transitionDuration:
                                            const Duration(milliseconds: 300),
                                      );
                                    },
                                    child: const Icon(Icons.receipt_long,
                                        color: primaryColor),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Get.bottomSheet(
            _buildBottomSheet(),
            backgroundColor: Colors.white,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  // 📌 Bottom Sheet with 4 Options
  Widget _buildBottomSheet() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: [
              _optionCard(Icons.money_off, "Add Expense", Colors.redAccent),
              _optionCard(
                  Icons.account_balance, "Deposit to Owner", Colors.blue),
              _optionCard(Icons.payment, "Vendor Pay", Colors.orange),
              _optionCard(Icons.account_balance_wallet, "Receive from Owner",
                  Colors.green),
            ],
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // 📌 Card UI
  Widget _optionCard(IconData icon, String title, Color color) {
    return InkWell(
      onTap: () {
        Get.back(); // close bottom sheet
        if (title == "Add Expense") {
          _showAddExpenseDialog(color);
        } else if (title == "Deposit to Owner") {
          _showDepositDialog(color);
        } else if (title == "Vendor Pay") {
          _showVendorPayDialog(color);
        } else if (title == "Receive from Owner") {
          _showReceiveDialog(color);
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 100,
        width: (Get.width / 2) - 25,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  // ================== 📌 Separate Dialogs ==================

  // 1. Add Expense Dialog
  void _showAddExpenseDialog(Color color) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Add Expense",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 15),
                Obx(() {
                  return Wrap(
                    spacing: 5,
                    children: controller.categories.map((cat) {
                      final isSelected =
                          controller.selectedCategory.value == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: color.withOpacity(0.2),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: isSelected ? color : Colors.black,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          controller.selectedCategory.value = cat;
                        },
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: controller.addExpenceamountCtrl,
                  labelText: "Amount",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: controller.addExpencenoteCtrl,
                  maxLines: 2,
                  labelText: "Note",
                ),
                const SizedBox(height: 15),
                Obx(() {
                  final file = controller.selectedImage.value;
                  return file != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                file,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: controller.clearImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : OutlinedButton.icon(
                          onPressed: () =>
                              controller.showImagePickerOptions(color),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: color, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                          ),
                          icon: const Icon(
                            Icons.image,
                            color: black,
                          ),
                          label: const Text(
                            "Upload Proof",
                            style: TextStyle(color: black),
                          ),
                        );
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final file = controller.selectedImage.value;
                    controller.add_expance(file);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                  ),
                  child: const Text("Save Expense",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 2. Deposit to Owner Dialog
  void _showDepositDialog(Color color) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Deposit to Owner",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 15),
                CustomTextFormField(
                  controller: controller.owner_deposit_amountCtrl,
                  keyboardType: TextInputType.number,
                  labelText: "Amount",
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: controller.owner_deposit_noteCtrl,
                  labelText: "Note",
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                Obx(() {
                  final file = controller.selectedImage.value;
                  return file != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                file,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: controller.clearImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : OutlinedButton.icon(
                          onPressed: () =>
                              controller.showImagePickerOptions(color),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: color, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                          ),
                          icon: const Icon(
                            Icons.image,
                            color: black,
                          ),
                          label: const Text(
                            "Upload Proof",
                            style: TextStyle(color: black),
                          ),
                        );
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final file = controller.selectedImage.value;
                    controller.owenerDeposit(file);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                  ),
                  child: const Text("Save Deposit",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// 3. Vendor Pay Dialog
  void _showVendorPayDialog(Color color) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Vendor Payment",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 15),
                CustomTextFormField(
                  controller: controller.vendorNameCtrl,
                  labelText: "Vendor Name",
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: controller.vendoramountCtrl,
                  labelText: "Amount",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: controller.vendornoteCtrl,
                  labelText: "Note",
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                Obx(() {
                  final file = controller.selectedImage.value;
                  return file != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                file,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: controller.clearImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : OutlinedButton.icon(
                          onPressed: () =>
                              controller.showImagePickerOptions(color),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: color, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                          ),
                          icon: const Icon(
                            Icons.image,
                            color: black,
                          ),
                          label: const Text(
                            "Upload Proof",
                            style: TextStyle(color: black),
                          ),
                        );
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final file = controller.selectedImage.value;
                    controller.postVendorPayment(file);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                  ),
                  child: const Text("Save Payment",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// 4. Receive from Owner Dialog
  void _showReceiveDialog(Color color) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Receive from Owner",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 15),
                CustomTextFormField(
                  controller: controller.receivce_from_owner_amountCtrl,
                  keyboardType: TextInputType.number,
                  labelText: "Amount",
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: controller.receivce_from_owner_noteCtrl,
                  labelText: "Note",
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                Obx(() {
                  final file = controller.selectedImage.value;
                  return file != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                file,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: controller.clearImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : OutlinedButton.icon(
                          onPressed: () =>
                              controller.showImagePickerOptions(color),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: color, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                          ),
                          icon: const Icon(
                            Icons.image,
                            color: black,
                          ),
                          label: const Text(
                            "Upload Proof",
                            style: TextStyle(color: black),
                          ),
                        );
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final file = controller.selectedImage.value;
                    controller.recivefromOwner(file);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                  ),
                  child: const Text("Save Transaction",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
