import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/commen_items/commen_class.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/ui/drawer/services/categotys/addNewServicesController.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/utils/custom_text_styles.dart';
import 'package:flutter_template/wiget/custome_text.dart';
import 'package:get/get.dart';
import '../../../../utils/validation.dart';
import '../../../../wiget/Custome_textfield.dart';
import '../../../../wiget/Custome_button.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import '../../../../wiget/custome_snackbar.dart';
import '../../../../network/network_const.dart';

class AddNewCategotyScreen extends StatelessWidget {
  AddNewCategotyScreen({super.key});

  final AddNewCategotyController getController =
      Get.put(AddNewCategotyController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Service Categories'),
      drawer: DrawerScreen(),
      body: Obx(() {
        if (getController.serviceList.isEmpty) {
          return Center(child: Text("No services found."));
        }
        return ListView.builder(
          padding: EdgeInsets.only(bottom: 80.h),
          itemCount: getController.serviceList.length,
          itemBuilder: (context, index) {
            final item = getController.serviceList[index];
            return Card(
              color: white,
              margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              child: ListTile(
                leading: item.image != null && item.image!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          '${Apis.pdfUrl}${item.image}?v=${DateTime.now().millisecondsSinceEpoch}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image_not_supported),
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
                title: Text(item.name ?? 'No Name'),
                subtitle: Text((item.status == 1) ? "Active" : "Deactive"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: primaryColor),
                      onPressed: () {
                        getController.startEditing(item);
                        showAddCategorySheet(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: primaryColor),
                      onPressed: () {
                        getController.deleteCategory(item.id ?? '');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          getController.resetForm();
          showAddCategorySheet(context);
        },
        child: Icon(Icons.add, color: white),
      ),
    );
  }

  void showAddCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.w,
            right: 16.w,
            top: 16.h,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: Imagepicker()),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 3,
                        child: CustomTextFormField(
                          controller: getController.nameController,
                          labelText: 'Name',
                          keyboardType: TextInputType.text,
                          validator: (value) => Validation.validatename(value),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
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
                  SizedBox(height: 16.h),
                  Obx(() => ElevatedButtonExample(
                        text: getController.isEditing.value
                            ? "Update Category"
                            : "Add Category",
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            getController.onAddOrUpdateCategoryPress();
                            Navigator.pop(context);
                          } else {
                            CustomSnackbar.showError('Validation Error',
                                'Please fill in all fields correctly');
                          }
                        },
                      )),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget Imagepicker() {
    return Obx(() {
      return GestureDetector(
        onTap: () {
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
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: primaryColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10.r),
            color: secondaryColor.withOpacity(0.2),
          ),
          child: getController.singleImage.value != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.file(
                    getController.singleImage.value!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              : getController.editImageUrl.value.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        '${Apis.pdfUrl}${getController.editImageUrl.value}?v=${DateTime.now().millisecondsSinceEpoch}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.image_rounded,
                        color: primaryColor,
                        size: 40.sp,
                      ),
                    ),
        ),
      );
    });
  }
}
