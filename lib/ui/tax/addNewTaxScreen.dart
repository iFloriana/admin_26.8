import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/tax/addNewTaxController.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/custome_dropdown.dart';
import 'package:get/get.dart';
import '../../../utils/custom_text_styles.dart';
import '../../../utils/validation.dart';
import '../../../wiget/Custome_textfield.dart';
import '../../../wiget/Custome_button.dart';
import '../../../wiget/custome_text.dart';

class Addnewtaxscreen extends StatelessWidget {
  Addnewtaxscreen({super.key});

  final Addnewtaxcontroller getController = Get.put(Addnewtaxcontroller());
  final _formKey = GlobalKey<FormState>();

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tax_screen(),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Tax')),
      body: Obx(() {
        if (getController.taxList.isEmpty) {
          return Center(child: Text('No taxes found'));
        }
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: getController.taxList.length,
          itemBuilder: (context, index) {
            final tax = getController.taxList[index];
            return Card(
              child: ListTile(
                title: Text(
                    '${tax.title} - ${tax.value}${tax.type == 'percent' ? '%' : ''}'),
                subtitle: Text(
                    'Module: ${tax.taxType?.capitalize} | Status: ${tax.status == 1 ? 'Active' : 'Inactive'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        getController.editTax(tax);
                        _openBottomSheet(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => getController.deleteTax(tax.id),
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
        onPressed: () => _openBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget tax_screen() {
    return Column(
      children: [
        InputTxtfield_title(),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: 'Status',
                  textStyle: CustomTextStyles.textFontRegular(size: 14.sp),
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
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(child: type()),
            SizedBox(width: 10.w),
            Expanded(child: module()),
          ],
        ),
        SizedBox(height: 10.h),
        InputTxtfield_value(),
        SizedBox(height: 10.h),
        branchChips(),
        SizedBox(height: 10.h),
        Btn_tax(),
      ],
    );
  }

  Widget InputTxtfield_title() {
    return CustomTextFormField(
      controller: getController.titleController,
      labelText: 'Title',
      keyboardType: TextInputType.text,
      validator: (value) => Validation.validateisBlanck(value),
    );
  }

  Widget InputTxtfield_value() {
    return CustomTextFormField(
      controller: getController.valueController,
      labelText: 'Value',
      keyboardType: TextInputType.number,
      validator: (value) => Validation.validateisBlanck(value),
    );
  }

  Widget Btn_tax() {
    return Obx(() => ElevatedButtonExample(
          text: getController.isEditMode.value ? "Update" : "Submit",
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              if (getController.isEditMode.value) {
                getController.updateTax();
              } else {
                getController.onTaxadded();
              }
            }
          },
        ));
  }

  Widget type() {
    return Obx(() => CustomDropdown<String>(
          value: getController.selectedDropdownType.value.isEmpty
              ? null
              : getController.selectedDropdownType.value,
          items: getController.dropdownType,
          hintText: 'Select Type',
          labelText: 'Type',
          onChanged: (newValue) {
            if (newValue != null) {
              getController.selectedDropdownType(newValue);
            }
          },
        ));
  }

  Widget module() {
    return Obx(() => CustomDropdown<String>(
          value: getController.selectedDropdownModule.value.isEmpty
              ? null
              : getController.selectedDropdownModule.value,
          items: getController.dropdownModule,
          hintText: 'Select Module',
          labelText: 'Module',
          onChanged: (newValue) {
            if (newValue != null) {
              getController.selectedDropdownModule(newValue);
            }
          },
        ));
  }

  Widget branchChips() {
    return Obx(() {
      return Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          FilterChip(
            label:
                Text(getController.allSelected ? 'Deselect All' : 'Select All'),
            selected: getController.allSelected,
            onSelected: (selected) {
              if (selected) {
                getController.selectedBranches
                    .assignAll(getController.branchList);
              } else {
                getController.selectedBranches.clear();
              }
            },
            selectedColor: primaryColor.withOpacity(0.2),
          ),
          ...getController.branchList.map((branch) {
            final isSelected =
                getController.selectedBranches.any((b) => b.id == branch.id);
            return FilterChip(
              label: Text(branch.name ?? ''),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  if (!getController.selectedBranches
                      .any((b) => b.id == branch.id)) {
                    getController.selectedBranches.add(branch);
                  }
                } else {
                  getController.selectedBranches
                      .removeWhere((b) => b.id == branch.id);
                }
              },
              selectedColor: primaryColor.withOpacity(0.2),
            );
          }).toList(),
        ],
      );
    });
  }
}
