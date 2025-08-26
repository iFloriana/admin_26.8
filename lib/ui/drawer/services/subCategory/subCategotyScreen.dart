import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/ui/drawer/services/subCategory/subCategoryController.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/utils/custom_text_styles.dart';
import 'package:flutter_template/utils/validation.dart';
import 'package:flutter_template/wiget/Custome_button.dart';
import 'package:flutter_template/wiget/Custome_textfield.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:flutter_template/wiget/custome_text.dart';
import 'package:get/get.dart';
import 'package:flutter_template/network/network_const.dart';

class Subcategotyscreen extends StatelessWidget {
  Subcategotyscreen({super.key});
  final Subcategorycontroller getController = Get.put(Subcategorycontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Sub Category"),
      drawer: DrawerScreen(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(() {
          return ListView.builder(
            itemCount: getController.subCategoryList.length,
            itemBuilder: (context, index) {
              final subCategory = getController.subCategoryList[index];
              return ListTile(
                title: Text(subCategory.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        showAddCategorySheet(context, subCategory: subCategory);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        getController.deleteSubCategory(subCategory.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => showAddCategorySheet(context),
        child: Icon(
          Icons.add,
          color: white,
        ),
      ),
    );
  }

  void showAddCategorySheet(BuildContext context, {SubCategory? subCategory}) {
    if (subCategory != null) {
      getController.nameController.text = subCategory.name;
      getController.selectedBranch.value = getController.branchList
          .firstWhereOrNull((c) => c.id == subCategory.categoryId);
      getController.isActive.value = subCategory.status == 1;
      getController.singleImage.value = null;
      getController.editImageUrl.value =
          subCategory.id.isNotEmpty ? subCategory.id : '';
    } else {
      getController.resetForm();
    }

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 16.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: Imagepicker()),
                  SizedBox(width: 5.w),
                  Expanded(
                    flex: 3,
                    child: CustomTextFormField(
                      controller: getController.nameController,
                      labelText: "Name",
                      keyboardType: TextInputType.text,
                      validator: (value) => Validation.validatename(value),
                    ),
                  ),
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
              Btn_Subcategory(subCategory: subCategory, context: context),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
    );
  }

  Widget branchDropdown() {
    return Obx(() {
      return DropdownButton<Category>(
        isExpanded: true,
        value: getController.selectedBranch.value,
        hint: const Text("Select Category"),
        items: getController.branchList.map((Category branch) {
          return DropdownMenuItem<Category>(
            value: branch,
            child: Text(branch.name ?? ''),
          );
        }).toList(),
        onChanged: (Category? newValue) {
          if (newValue != null) {
            getController.selectedBranch.value = newValue;
            CustomSnackbar.showSuccess(
              'Category Selected',
              'ID: ${newValue.id}',
            );
          }
        },
      );
    });
  }

  Widget Imagepicker() {
    return Obx(() {
      return GestureDetector(
        onTap: () {
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
                    onTap: () {
                      Get.back();
                      getController.pickImageFromGallery();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Take Photo'),
                    onTap: () {
                      Get.back();
                      getController.pickImageFromCamera();
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
          height: 50.h,
          width: 70.w,
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
                        // You may need to adjust the URL prefix as per your backend
                        '${Apis.pdfUrl}${getController.editImageUrl.value}?v=${DateTime.now().millisecondsSinceEpoch}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.image_rounded,
                        color: primaryColor,
                        size: 30.sp,
                      ),
                    ),
        ),
      );
    });
  }

  Widget Btn_Subcategory(
      {SubCategory? subCategory, required BuildContext context}) {
    return ElevatedButtonExample(
      text: subCategory == null ? "Add SubCategory" : "Update SubCategory",
      onPressed: () async {
        if (subCategory == null) {
          await getController.onaddNewSubcategory();
        } else {
          await getController.onEditSubcategory(subCategory);
        }
        Navigator.of(context).pop();
      },
    );
  }
}
// {
//   "salon_id": "680f52f17f30e732a48469f5",
//   "image": "https://example.com/image.jpg",
//   "category_id": "68107158ccaa14278104a0d4",
//   "name": "Hair Styling",
//   "status": 1
// }
