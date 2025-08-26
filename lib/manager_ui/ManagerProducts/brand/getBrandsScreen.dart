import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/ManagerProducts/brand/getBrandsController.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../../../utils/custom_text_styles.dart';
import '../../../../../utils/validation.dart';
import '../../../../../wiget/Custome_button.dart';
import '../../../../../wiget/Custome_textfield.dart';
import '../../../../../wiget/custome_text.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import '../../../../wiget/loading.dart';
import '../../../../network/model/brand.dart';

class ManagerGetbrandsscreen extends StatelessWidget {
  ManagerGetbrandsscreen({super.key});
  final getController = Get.put(ManagerGetbrandscontroller());

  // Helper to check allowed image extensions
  bool _isAllowedImageExtension(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Brands',
      ),
            drawer: ManagerDrawerScreen(),
      body: RefreshIndicator(
          color: primaryColor,
          onRefresh: () async {
            getController.getBrands();
          },
          child: Obx(
            () => getController.isLoading.value
                ? const Center(child: CustomLoadingAvatar())
                : ListView.builder(
                    itemCount: getController.brands.length,
                    itemBuilder: (context, index) {
                      final brand = getController.brands[index];
                      return Container(
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(10),
                        //     border: Border(
                        //         right: BorderSide(
                        //             color: secondaryColor, width: 3))),
                        // margin: const EdgeInsets.symmetric(
                        //     horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: brand.image.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '${Apis.pdfUrl}${brand.image}?v=${DateTime.now().millisecondsSinceEpoch}',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
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
                                  child: const Icon(Icons.image_not_supported),
                                ),
                          title: Text(
                            brand.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Branches: ${brand.branchId.length}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: primaryColor),
                                  onPressed: () {
                                    showEditBrandSheet(context, brand);
                                  }),
                              IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: primaryColor,
                                  onPressed: () =>
                                      getController.deleteBrand(brand.id)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddCategorySheet(context);
        },
        child: Icon(Icons.add, color: white),
        backgroundColor: primaryColor,
      ),
    );
  }

  void showAddCategorySheet(BuildContext context) {
    getController.nameController.clear();
    getController.isActive.value = true;
    getController.selectedBranches.clear();
    getController.branchController.clearAll();
    getController.singleImage.value = null; // Clear picked image for add
    getController.editImageUrl.value = ''; // Clear network image for add
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Imagepicker(),
                      ),
                      Expanded(
                        flex: 3,
                        child: CustomTextFormField(
                          controller: getController.nameController,
                          labelText: 'Name',
                          keyboardType: TextInputType.text,
                          validator: (value) => Validation.validatename(value),
                        ),
                      )
                    ],
                  ),
                  branchDropdown(),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextWidget(
                            text: 'Status',
                            textStyle:
                                CustomTextStyles.textFontRegular(size: 14.sp),
                          ),
                          Switch(
                            value: getController.isActive.value,
                            onChanged: (value) {
                              getController.isActive.value = value;
                            },
                            activeColor: primaryColor,
                          ),
                        ],
                      )),
                  Btn_BranchesAdd(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
  }

  void showEditBrandSheet(BuildContext context, Brand brand) async {
    getController.nameController.text = brand.name;
    getController.isActive.value = brand.status == 1;
    final selectedBranches = getController.branchList
        .where((b) => brand.branchId.any((cb) => cb.id == b.id))
        .toList();
    getController.selectedBranches.value = selectedBranches;
    getController.branchController.clearAll();

    // Reset image selection for editing
    getController.singleImage.value = null;
    getController.editImageUrl.value =
        brand.image; // Set network image for edit

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getController.branchController
          .selectWhere((item) => selectedBranches.contains(item.value));
    });
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Imagepicker(),
                      ),
                      Expanded(
                        flex: 3,
                        child: CustomTextFormField(
                          controller: getController.nameController,
                          labelText: 'Name',
                          keyboardType: TextInputType.text,
                          validator: (value) => Validation.validatename(value),
                        ),
                      )
                    ],
                  ),
                  branchDropdown(),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextWidget(
                            text: 'Status',
                            textStyle:
                                CustomTextStyles.textFontRegular(size: 14.sp),
                          ),
                          Switch(
                            value: getController.isActive.value,
                            onChanged: (value) {
                              getController.isActive.value = value;
                            },
                            activeColor: primaryColor,
                          ),
                        ],
                      )),
                  ElevatedButtonExample(
                    text: "Update Brand",
                    onPressed: () {
                      getController.updateBrand(brand.id);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
  }

  Widget Imagepicker() {
    return Obx(() {
      return GestureDetector(
        onTap: () async {
          Get.bottomSheet(
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from Gallery'),
                    onTap: () async {
                      Get.back();
                      await getController.pickImageFromGallery();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Take Photo'),
                    onTap: () async {
                      Get.back();
                      await getController.pickImageFromCamera();
                    },
                  ),
                ],
              ),
            ),
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          );
        },
        child: Container(
          height: 51.h,
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10.r),
            color: secondaryColor.withOpacity(0.2),
          ),
          child: getController.singleImage.value != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.file(
                    getController.singleImage.value!,
                    fit: BoxFit.cover,
                  ),
                )
              : getController.editImageUrl.value.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        '${Apis.pdfUrl}${getController.editImageUrl.value}?v=${DateTime.now().millisecondsSinceEpoch}',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.image_rounded, color: primaryColor, size: 30.sp),
        ),
      );
    });
  }

  Widget branchDropdown() {
    return Obx(() {
      return MultiDropdown<Branch1>(
        items: getController.branchList
            .map((branch) => DropdownItem(
                  label: branch.name ?? '',
                  value: branch,
                ))
            .toList(),
        controller: getController.branchController,
        enabled: true,
        searchEnabled: true,
        chipDecoration: const ChipDecoration(
          backgroundColor: secondaryColor,
          wrap: true,
          runSpacing: 2,
          spacing: 10,
        ),
        fieldDecoration: FieldDecoration(
          hintText: 'Select Branches',
          hintStyle: CustomTextStyles.textFontMedium(size: 14.sp, color: grey),
          showClearIcon: true,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(
              color: grey,
              width: 1.0,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(
              color: primaryColor,
              width: 2.0,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(
              color: red,
              width: 1.0,
            ),
          ),
        ),
        dropdownItemDecoration: DropdownItemDecoration(
          selectedIcon: const Icon(Icons.check_box, color: primaryColor),
          disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
        ),
        onSelectionChange: (selectedItems) {
          getController.selectedBranches.value = selectedItems;
        },
      );
    });
  }

  Widget Btn_BranchesAdd() {
    return ElevatedButtonExample(
      text: "Add Brand",
      onPressed: () {
        getController.onAddBrand();
      },
    );
  }
}
