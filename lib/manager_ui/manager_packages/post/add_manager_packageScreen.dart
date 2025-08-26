import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/commen_items/commen_class.dart';
import 'package:flutter_template/manager_ui/manager_packages/post/add_manager_packageController.dart';
import 'package:flutter_template/utils/custom_text_styles.dart';
import 'package:get/get.dart';
import 'package:flutter_template/utils/colors.dart';
import '../../../utils/validation.dart';
import '../../../wiget/Custome_button.dart';
import '../../../wiget/Custome_textfield.dart';
import '../../../wiget/appbar/commen_appbar.dart';
import '../../../wiget/custome_text.dart';

class AddManagerPackagescreen extends StatelessWidget {
  final  controller = Get.put(AddManagerPackagecontroller());

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.packageToEdit != null;

    return Scaffold(
      appBar:
          CustomAppBar(title: isEditing ? 'Update Package' : 'Create Package'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 1,
              ),
              CustomTextFormField(
                controller: controller.nameController,
                labelText: 'Name',
                keyboardType: TextInputType.text,
                validator: (value) => Validation.validatename(value),
              ),
              CustomTextFormField(
                controller: controller.discriptionController,
                labelText: 'Discription',
                maxLines: 2,
                keyboardType: TextInputType.text,
                validator: (value) => Validation.validatedisscription(value),
              ),
              Row(
                spacing: 5,
                children: [
                  Expanded(child: startTime(context)),
                  // SizedBox(width: 5),
                  Expanded(child: endTime(context)),
                ],
              ),
              Obx(() => Column(
                    children:
                        List.generate(controller.containerList.length, (index) {
                      final data = controller.containerList[index];
                      return Obx(
                        () => Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            spacing: 8,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Service ${index + 1}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline,
                                        color: primaryColor),
                                    onPressed: () =>
                                        controller.removeContainer(index),
                                  ),
                                ],
                              ),
                              DropdownButtonFormField<Service>(
                                value: data.selectedService.value,
                                items: controller.serviceList
                                    .map((service) => DropdownMenuItem(
                                          value: service,
                                          child: Text(service.name ?? ''),
                                        ))
                                    .toList(),
                                onChanged: (newService) {
                                  if (newService != null) {
                                    controller.onServiceSelected(
                                        data, newService);
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: "Select Service",
                                  labelStyle: TextStyle(color: grey),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                      color: primaryColor,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                spacing: 5,
                                children: [
                                  Expanded(
                                    child: CustomTextFormField(
                                      controller:
                                          data.discountedPriceController,
                                      labelText: 'Discounted Price',
                                      hintText: 'Enter Discounted Price',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  Expanded(
                                    child: CustomTextFormField(
                                      controller: data.quantityController,
                                      labelText: 'Quantity',
                                      hintText: 'Enter Quantity',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              // SizedBox(height: 10),
                              Text("Total: ₹${data.total.value}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                            ],
                          ),
                        ),
                      );
                    }),
                  )),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: controller.addContainer,
                  child: Text(
                    '+ Add Service',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextWidget(
                        text: 'Status',
                        textStyle:
                            CustomTextStyles.textFontRegular(size: 14.sp),
                      ),
                      Switch(
                        value: controller.isActive.value,
                        onChanged: (value) {
                          controller.isActive.value = value;
                        },
                        activeColor: primaryColor,
                      ),
                    ],
                  )),
              Obx(() => Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Grand Total:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "₹${controller.grandTotal.value}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  )),
              ElevatedButtonExample(
                text: isEditing ? 'Update Package' : 'Create Package',
                onPressed: controller.submitPackage,
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget startTime(BuildContext context) {
    return CustomTextFormField(
      controller: controller.StarttimeController,
      labelText: 'Start Time',
      keyboardType: TextInputType.none,
      validator: (value) => Validation.validateTime(value),
      suffixIcon: IconButton(
        onPressed: () async {
          await pickAndSetDate(
            context: context,
            controller: controller.StarttimeController,
          );
        },
        icon: Icon(Icons.calendar_today),
      ),
    );
  }

  Widget endTime(BuildContext context) {
    return CustomTextFormField(
      controller: controller.EndtimeController,
      labelText: 'End Time',
      keyboardType: TextInputType.none,
      validator: (value) => Validation.validateTime(value),
      suffixIcon: IconButton(
        onPressed: () async {
          await pickAndSetDate(
            context: context,
            controller: controller.EndtimeController,
          );
        },
        icon: Icon(Icons.calendar_today),
      ),
    );
  }
}
