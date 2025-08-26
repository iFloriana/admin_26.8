import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/drawer/products/Tags/tagController.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../../../utils/custom_text_styles.dart';
import '../../../../../utils/validation.dart';
import '../../../../../wiget/Custome_button.dart';
import '../../../../../wiget/Custome_textfield.dart';
import '../../../../../wiget/custome_text.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import '../../drawer_screen.dart';

class Tagsscreen extends StatelessWidget {
  Tagsscreen({super.key});
  final Tagcontroller getController = Get.put(Tagcontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Product SubCategories"),
            drawer: DrawerScreen(),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async {
          getController.getTags();
        },
        child: Obx(() {
          if (getController.tagsList.isEmpty) {
            return Center(child: Text('No tags found.'));
          }
          return ListView.builder(
            itemCount: getController.tagsList.length,
            itemBuilder: (context, index) {
              final tag = getController.tagsList[index];
              final branchNames = tag.branches.map((b) => b.name).join(', ');
              return ListTile(
                title: Text(tag.name ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag.status == 1 ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: tag.status == 1 ? Colors.green : Colors.red,
                      ),
                    ),
                    Text('Branches: $branchNames'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: primaryColor),
                      onPressed: () {
                        showEditTagSheet(context, tag);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: primaryColor),
                      onPressed: () async {
                         getController.deleteTag(tag.id!);
                        // final confirm = await showDialog<bool>(
                        //   context: context,
                        //   builder: (context) => AlertDialog(
                        //     title: Text('Delete Tag'),
                        //     content: Text(
                        //         'Are you sure you want to delete this tag?'),
                        //     actions: [
                        //       TextButton(
                        //         onPressed: () =>
                        //             Navigator.of(context).pop(false),
                        //         child: Text('Cancel'),
                        //       ),
                        //       TextButton(
                        //         onPressed: () =>
                        //             Navigator.of(context).pop(true),
                        //         child: Text('Delete',
                        //             style: TextStyle(color: Colors.red)),
                        //       ),
                        //     ],
                        //   ),
                        // );
                        // if (confirm == true) {
                        //   getController.deleteTag(tag.id!);
                        // }
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
        onPressed: () {
          showAddCategorySheet(context);
        },
        child: Icon(Icons.add, color: white),
        backgroundColor: primaryColor,
      ),
    );
  }

  void showAddCategorySheet(BuildContext context) {
    getController.resetForm();
    getController.branchController.clearAll();

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
                CustomTextFormField(
                  controller: getController.nameController,
                  labelText: 'Name',
                  keyboardType: TextInputType.text,
                  validator: (value) => Validation.validatename(value),
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
                Btn_SubCategoryAdd(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void showEditTagSheet(BuildContext context, TagModel tag) async {
    getController.resetForm();
    getController.branchController.clearAll();
    if (getController.branchList.isEmpty) {
      await getController.getBranches();
    }
    getController.nameController.text = tag.name ?? '';
    getController.isActive.value = tag.status == 1;
    final selected = getController.branchList
        .where((b) => tag.branches.any((tb) => tb.id == b.id))
        .toList();
    getController.selectedBranches.value = selected;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            getController.branchController
                .selectWhere((item) => selected.contains(item.value));
          });
          return Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
                children: [
                  CustomTextFormField(
                    controller: getController.nameController,
                    labelText: 'Name',
                    keyboardType: TextInputType.text,
                    validator: (value) => Validation.validatename(value),
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
                    text: "Update Tag",
                    onPressed: () {
                      getController.onEditTag(tag.id!);
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
              color: secondaryColor,
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

  Widget Btn_SubCategoryAdd() {
    return ElevatedButtonExample(
      text: "Add SubCategory",
      onPressed: () {
        getController.onAddSubCategory();
      },
    );
  }
}
