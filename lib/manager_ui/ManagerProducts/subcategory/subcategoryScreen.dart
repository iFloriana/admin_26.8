import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/ManagerProducts/subcategory/subcategoryController.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../../../utils/custom_text_styles.dart';
import '../../../../../utils/validation.dart';
import '../../../../../wiget/Custome_button.dart';
import '../../../../../wiget/Custome_textfield.dart';
import '../../../../../wiget/custome_text.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import '../../../../wiget/loading.dart';
import '../../../../network/model/productSubCategory.dart';

class ManagerSubcategoryscreen extends StatelessWidget {
  ManagerSubcategoryscreen({super.key});
  final getController = Get.put(ManagerSubcategorycontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sub Categories',
      ),
            drawer: ManagerDrawerScreen(),
      body: Container(
          child: Obx(
        () => getController.isLoading.value
            ? const Center(child: CustomLoadingAvatar())
            : ListView.builder(
                itemCount: getController.subCategories.length,
                itemBuilder: (context, index) {
                  final subCategory = getController.subCategories[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: subCategory.image.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                "${Apis.pdfUrl}${subCategory.image}?v=${DateTime.now().millisecondsSinceEpoch}",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child:
                                        const Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                      title: Text(
                        subCategory.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category: ${subCategory.productCategoryId.name}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          // Text(
                          //   'Branches: ${subCategory.branchId.length} • Brands: ${subCategory.brandId.length}',
                          //   style: TextStyle(
                          //     color: Colors.grey[600],
                          //     fontSize: 12,
                          //   ),
                          // ),
                          // Text(
                          //   subCategory.status == 1 ? 'Active' : 'Inactive',
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: subCategory.status == 1
                          //         ? Colors.green
                          //         : Colors.red,
                          //   ),
                          // ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: primaryColor),
                              onPressed: () {
                                showEditSubCategorySheet(context, subCategory);
                              }),
                          IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: primaryColor,
                              onPressed: () => getController
                                  .deleteSubCategory(subCategory.id)),
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
    getController.selectedBrand.clear();
    getController.selectedCategory.value = null;
    getController.branchController.clearAll();
    getController.brandController.clearAll();
    getController.singleImage.value = null;
    getController.editImageUrl.value = '';
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
                  brandDropdown(),
                  caregoryDropdown(),
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
                  Btn_SubCategoryAdd(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
  }

  void showEditSubCategorySheet(
      BuildContext context, ProductSubCategory subCategory) async {
    getController.nameController.text = subCategory.name;
    getController.isActive.value = subCategory.status == 1;
    final selectedBranches = getController.branchList
        .where((b) => subCategory.branchId.any((cb) => cb.id == b.id))
        .toList();
    final selectedBrands = getController.brandList
        .where((b) => subCategory.brandId.any((cb) => cb.id == b.id))
        .toList();
    final selectedCategory = getController.categoryList
        .firstWhereOrNull((c) => c.id == subCategory.productCategoryId.id);
    getController.selectedBranches.value = selectedBranches;
    getController.selectedBrand.value = selectedBrands;
    getController.selectedCategory.value = selectedCategory;
    getController.branchController.clearAll();
    getController.brandController.clearAll();
    getController.singleImage.value = null;
    getController.editImageUrl.value = subCategory.image;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getController.branchController
          .selectWhere((item) => selectedBranches.contains(item.value));
      getController.brandController
          .selectWhere((item) => selectedBrands.contains(item.value));
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
                  brandDropdown(),
                  caregoryDropdown(),
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
                    text: "Update SubCategory",
                    onPressed: () {
                      getController.updateSubCategory(subCategory.id);
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
                color: Colors.white,
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
              : (getController.editImageUrl.value.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        "${Apis.pdfUrl}${getController.editImageUrl.value}?v=${DateTime.now().millisecondsSinceEpoch}",
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.image_rounded,
                      color: primaryColor, size: 30.sp)),
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
          hintStyle: const TextStyle(color: Colors.grey),
          showClearIcon: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: primaryColor,
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

  Widget brandDropdown() {
    return Obx(() {
      return MultiDropdown<Subcategorys>(
        items: getController.brandList
            .map((brand) => DropdownItem(
                  label: brand.name ?? '',
                  value: brand,
                ))
            .toList(),
        controller: getController.brandController,
        enabled: true,
        searchEnabled: true,
        chipDecoration: const ChipDecoration(
          backgroundColor: secondaryColor,
          wrap: true,
          runSpacing: 2,
          spacing: 10,
        ),
        fieldDecoration: FieldDecoration(
          hintText: 'Select Brand',
          hintStyle: const TextStyle(color: Colors.grey),
          showClearIcon: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: secondaryColor,
            ),
          ),
        ),
        dropdownItemDecoration: DropdownItemDecoration(
          selectedIcon: const Icon(Icons.check_box, color: primaryColor),
          disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
        ),
        onSelectionChange: (selectedBrand) {
          getController.selectedBrand.value = selectedBrand;
        },
      );
    });
  }

  Widget caregoryDropdown() {
    return Obx(() {
      return DropdownButtonFormField<Category>(
        value: getController.selectedCategory.value,
        decoration: InputDecoration(
          labelText: "Select Category",
          labelStyle: TextStyle(color: grey),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: primaryColor,
            ),
          ),
        ),
        items: getController.categoryList.map((Category category) {
          return DropdownMenuItem<Category>(
            value: category,
            child: Text(category.name ?? ''),
          );
        }).toList(),
        onChanged: (Category? newValue) {
          print('Category dropdown onChanged called with: ${newValue?.name}');
          if (newValue != null) {
            getController.selectedCategory.value = newValue;
          }
        },
      );
    });
  }

  Widget Btn_SubCategoryAdd() {
    return ElevatedButtonExample(
      text: "Add SubCategory",
      onPressed: () {
        getController.onAddSubCategory();
      },
    );
  }
}
