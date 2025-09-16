import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/Custome_textfield.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// 🎯 Controller
class FinanceController extends GetxController {
  var selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

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
class FinancePage extends StatelessWidget {
  final FinanceController controller = Get.put(FinanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Finance Dashboard",
      ),
      body: const Center(child: Text("Main Content Here")),
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
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController noteCtrl = TextEditingController();

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
                CustomTextFormField(
                    controller: nameCtrl, labelText: "Expense Name"),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: amountCtrl,
                  labelText: "Amount",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: noteCtrl,
                  maxLines: 2,
                  labelText: "Note",
                ),
                const SizedBox(height: 15),
                Obx(() {
                  final file = controller.selectedImage.value;
                  return file != null
                      ? Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(file,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover),
                            ),
                            TextButton(
                                onPressed: controller.clearImage,
                                child: const Text("Remove Image")),
                          ],
                        )
                      : OutlinedButton.icon(
                          onPressed: () =>
                              controller.showImagePickerOptions(color),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: color, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12), // corner radius
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                          ),
                          icon: const Icon(Icons.image),
                          label: const Text("Upload Bill"),
                        );
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.back(),
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
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController noteCtrl = TextEditingController();

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
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  labelText: "Amount",
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: noteCtrl,
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
                  onPressed: () => Get.back(),
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
    final TextEditingController vendorNameCtrl = TextEditingController();
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController noteCtrl = TextEditingController();

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
                  controller: vendorNameCtrl,
                  labelText: "Vendor Name",
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: amountCtrl,
                  labelText: "Amount",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: noteCtrl,
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
                  onPressed: () => Get.back(),
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
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController noteCtrl = TextEditingController();

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
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  labelText: "Amount",
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: noteCtrl,
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
                  onPressed: () => Get.back(),
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
