import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/ui/drawer/services/addServices/addservicesController.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/utils/custom_text_styles.dart';
import 'package:flutter_template/utils/validation.dart';
import 'package:flutter_template/wiget/Custome_button.dart';
import 'package:flutter_template/wiget/Custome_textfield.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:flutter_template/wiget/custome_text.dart';
import 'package:get/get.dart';

import '../../../../network/network_const.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import '../../../../wiget/loading.dart';

class AddNewService extends StatelessWidget {
  AddNewService({super.key});
  final Addservicescontroller getController = Get.put(Addservicescontroller());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Services",
        ),
        drawer: DrawerScreen(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() {
            if (getController.serviceList.isEmpty) {
              return Center(
                child: Text(
                  "No services available.",
                  style: TextStyle(fontSize: 16.sp),
                ),
              );
            }
            return RefreshIndicator(
              color: primaryColor,
              onRefresh: () => getController.getAllServices(),
              child: ListView.builder(
                itemCount: getController.serviceList.length,
                itemBuilder: (context, index) {
                  final service = getController.serviceList[index];
                  print('Building item $index: ${service.name}');
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    child: ListTile(
                      leading: service.image_url != null &&
                              service.image_url!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                '${Apis.pdfUrl}${service.image_url}?v=${DateTime.now().millisecondsSinceEpoch}',
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
                                    child:
                                        const Icon(Icons.image_not_supported),
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
                        service.name ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.h),
                          Text(
                            '₹${service.price} • ${service.duration} mins',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            service.status == 1 ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: service.status == 1
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon:
                                Icon(Icons.edit_outlined, color: primaryColor),
                            onPressed: () async {
                              await getController.startEditing(service);
                              showAddCategorySheet(context);
                            },
                          ),
                          IconButton(
                            icon:
                                Icon(Icons.delete_outline, color: primaryColor),
                            onPressed: () {
                              getController.deleteService(service.id!);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            getController.resetForm();
            showAddCategorySheet(context);
          },
          child: Icon(
            Icons.add,
            color: white,
          ),
          backgroundColor: primaryColor,
        ),
      ),
    );
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
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image_rounded,
                              color: primaryColor, size: 30.sp);
                        },
                      ),
                    )
                  : Icon(Icons.image_rounded, color: primaryColor, size: 30.sp),
        ),
      );
    });
  }

  Widget InputTxtfield_discription() {
    return CustomTextFormField(
      controller: getController.descriptionController,
      labelText: 'Description',
      maxLines: 3,
      keyboardType: TextInputType.text,
      validator: (value) => Validation.validatedisscription(value),
    );
  }

  Widget Btn_serviceAdd() {
    return Obx(() => ElevatedButtonExample(
          text:
              getController.isEditing.value ? "Update Service" : "Add Service",
          onPressed: () {
            if (getController.nameController.text.isEmpty) {
              CustomSnackbar.showError('Error', 'Please enter service name');
              return;
            }
            if (getController.serviceDuration.text.isEmpty) {
              CustomSnackbar.showError(
                  'Error', 'Please enter service duration');
              return;
            }
            if (getController.regularPrice.text.isEmpty) {
              CustomSnackbar.showError('Error', 'Please enter regular price');
              return;
            }
            if (getController.selectedCategory.value == null) {
              CustomSnackbar.showError('Error', 'Please select a category');
              return;
            }
            getController.onServicePress();
          },
        ));
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
              left: 10,
              right: 10,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            ),
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
                children: [
                  // Container(
                  //   width: 50,
                  //   height: 5,
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey[300],
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  // ),
                  // Text(
                  //   getController.isEditing.value
                  //       ? "Update Service"
                  //       : "Add New Service",
                  //   style: TextStyle(
                  //     fontSize: 18.sp,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  SizedBox(height: 10.h),
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
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          controller: getController.serviceDuration,
                          labelText: 'Service Duration (mins)',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              Validation.validateisBlanck(value),
                        ),
                      ),
                      Expanded(
                        child: CustomTextFormField(
                          controller: getController.regularPrice,
                          labelText: 'Regular Price (₹)',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              Validation.validateisBlanck(value),
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: 10.h),
                  Obx(() {
                    return DropdownButtonFormField<Category>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: "Select Category",
                        labelStyle: TextStyle(color: grey),
                      ),
                      value: getController.selectedCategory.value,
                      items: getController.categories.map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        getController.selectedCategory.value = value;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    );
                  }),
                  // SizedBox(height: 10.h),
                  InputTxtfield_discription(),
                  // SizedBox(height: 10.h),
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
                  SizedBox(height: 20.h),
                  Obx(() => getController.isLoading.value
                      ? const CustomLoadingAvatar()
                      : Btn_serviceAdd()),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
  }
}
