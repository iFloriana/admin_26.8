import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/ManagerProducts/variations/update_variation_controller.dart';
import 'package:flutter_template/network/model/variation_product.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/custom_text_styles.dart';
import '../../../../utils/validation.dart';
import '../../../../wiget/Custome_button.dart';
import '../../../../wiget/Custome_textfield.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import '../../../../wiget/custome_dropdown.dart';
import '../../../../wiget/custome_text.dart';
import '../../../../wiget/loading.dart';

class ManagerUpdateVariationscreen extends StatelessWidget {
  final Data variationToEdit;
  ManagerUpdateVariationscreen({super.key, required this.variationToEdit});

  @override
  Widget build(BuildContext context) {
    final getController =
        Get.put(
        ManagerUpdateVariationcontroller(variationToEdit: variationToEdit));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Update Variations',
      ),
      body: Padding( 
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                controller: getController.nameController,
                labelText: "Variation Name",
                keyboardType: TextInputType.text,
                validator: (value) => Validation.validatename(value),
              ),
              SizedBox(height: 10),
              Obx(() {
                if (getController.isLoading.value) {
                  return Center(child: CustomLoadingAvatar());
                }
                return branchDropdown(getController);
              }),
              SizedBox(height: 10),
              Type(getController),
              SizedBox(height: 10),
              Obx(() => Column(
                    children: [
                      for (int i = 0;
                          i < getController.valueControllers.length;
                          i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  controller: getController.valueControllers[i],
                                  labelText: "Value",
                                  keyboardType: TextInputType.text,
                                  validator: (value) =>
                                      Validation.validateisBlanck(value),
                                ),
                              ),
                              if (getController.valueControllers.length > 1)
                                IconButton(
                                  icon: Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () {
                                    getController.removeValueField(i);
                                  },
                                ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            getController.addValueField();
                          },
                          icon: Icon(
                            Icons.add,
                            color: white,
                          ),
                          label: Text(
                            'Add Value',
                            style: TextStyle(color: white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 10),
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
              SizedBox(height: 20),
              Btn_variation(getController),
            ],
          ),
        ),
      ),
    );
  }

  Widget branchDropdown(ManagerUpdateVariationcontroller getController) {
    return Obx(() {
      final branches = getController.branchList;
      return MultiDropdown<Branch1>(
        items: branches.map((branch) {
          final label = branch.name ?? 'Unnamed Branch';
          return DropdownItem<Branch1>(
            label: label,
            value: branch,
          );
        }).toList(),
        controller: getController.branchController,
        onSelectionChange: (selectedItems) {
          getController.selectedBranches.value = selectedItems;
        },
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
              color: secondaryColor,
            ),
          ),
        ),
        dropdownItemDecoration: DropdownItemDecoration(
          selectedIcon: const Icon(Icons.check_box, color: primaryColor),
          disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
        ),
        // Pre-selecting values is not directly supported in a clean way.
        // The controller handles this logic. `selectedBranches` is updated in controller.
        // The UI will reflect the selection once the user interacts or if we can drive it via controller.
        // The `MultiSelectController` should handle displaying the selected items as chips.
      );
    });
  }

  Widget Type(ManagerUpdateVariationcontroller getController) {
    return Obx(() => CustomDropdown<String>(
          value: getController.selectedType.value.isEmpty
              ? null
              : getController.selectedType.value,
          items: getController.dropdownItemsType,
          hintText: 'Type',
          labelText: 'Type',
          onChanged: (newValue) {
            if (newValue != null) {
              getController.selectedType(newValue);
            }
          },
        ));
  }

  Widget Btn_variation(ManagerUpdateVariationcontroller getController) {
    return ElevatedButtonExample(
      text: "Update Variation",
      onPressed: () {
        getController.onBranchUpdate();
      },
    );
  }
}
