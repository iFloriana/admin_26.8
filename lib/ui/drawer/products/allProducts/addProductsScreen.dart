import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/drawer/products/allProducts/addProductsController.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../../wiget/Custome_button.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import '../../../../wiget/custome_snackbar.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/Custome_textfield.dart';
import '../../../../wiget/custome_text.dart';
import '../../../../utils/custom_text_styles.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddProductController());
    final textTheme = Theme.of(context).textTheme;
    final isEditMode = controller.isEditMode.value;

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditMode ? 'Update Product' : 'Add Product',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(controller),
              // const SizedBox(height: 16),
              CustomTextFormField(
                controller: controller.productNameController,
                labelText: 'Product Name *',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              // const SizedBox(height: 12),
              CustomTextFormField(
                controller: controller.descriptionController,
                labelText: 'Description',
                maxLines: 3,
              ),
              // const SizedBox(height: 16),
              Row(
                spacing: 5,
                children: [
                  Expanded(child: _buildBrandDropdown(controller)),
                  // const SizedBox(width: 8),
                  Expanded(child: _buildCategoryDropdown(controller)),
                ],
              ),
              // const SizedBox(height: 12),
              Row(
                spacing: 5,
                children: [
                  Expanded(child: _buildTagDropdown(controller)),
                  // const SizedBox(width: 8),
                  Expanded(child: _buildUnitDropdown(controller)),
                ],
              ),
              // const SizedBox(height: 24),
              // _buildSectionTitle(textTheme, 'Price, SKU & Stock'),
              Obx(() => _buildPriceSection(controller)),
              // const SizedBox(height: 24),
              // Removed _buildSectionTitle(textTheme, 'Product Discount'),
              // Removed _buildDiscountSection(controller),
              // const SizedBox(height: 24),
              // _buildSectionTitle(textTheme, 'Status'),
              _buildBranchDropdown(controller),
              _buildStatusSelector(controller),
              // const SizedBox(height: 24),
              // _buildSectionTitle(textTheme, 'Branch *'),

              // const SizedBox(height: 32),
              _buildActionButtons(controller, isEditMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(AddProductController controller) {
    return Center(
      child: Column(
        children: [
          Obx(() {
            final hasPicked = controller.imageFile.value != null;
            final hasNetwork = controller.editImageUrl.value.isNotEmpty;
            return GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Choose from Gallery'),
                          onTap: () async {
                            Get.back();
                            await controller.pickImage();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Take Photo'),
                          onTap: () async {
                            Get.back();
                            await controller.pickImageFromCamera();
                          },
                        ),
                      ],
                    ),
                  ),
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                );
              },
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(10.r),
                  color: secondaryColor.withOpacity(0.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: hasPicked
                      ? Image.file(controller.imageFile.value!,
                          fit: BoxFit.cover)
                      : hasNetwork
                          ? Image.network(
                              '${Apis.pdfUrl}${controller.editImageUrl.value}?v=${DateTime.now().millisecondsSinceEpoch}',
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.image,
                                  size: 50, color: Colors.grey),
                            )
                          : const Icon(Icons.image,
                              size: 50, color: Colors.grey),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     ElevatedButton(
          //       onPressed: () {
          //         Get.bottomSheet(
          //           Container(
          //             padding: const EdgeInsets.all(16),
          //             decoration: const BoxDecoration(
          //               color: Colors.white,
          //               borderRadius:
          //                   BorderRadius.vertical(top: Radius.circular(16)),
          //             ),
          //             child: Column(
          //               mainAxisSize: MainAxisSize.min,
          //               children: [
          //                 ListTile(
          //                   leading: const Icon(Icons.photo_library),
          //                   title: const Text('Choose from Gallery'),
          //                   onTap: () async {
          //                     Get.back();
          //                     await controller.pickImage();
          //                   },
          //                 ),
          //                 ListTile(
          //                   leading: const Icon(Icons.camera_alt),
          //                   title: const Text('Take Photo'),
          //                   onTap: () async {
          //                     Get.back();
          //                     await controller.pickImageFromCamera();
          //                   },
          //                 ),
          //               ],
          //             ),
          //           ),
          //           isScrollControlled: true,
          //           shape: const RoundedRectangleBorder(
          //             borderRadius:
          //                 BorderRadius.vertical(top: Radius.circular(16)),
          //           ),
          //         );
          //       },
          //       child: const Text('Upload'),
          //     ),
          //     const SizedBox(width: 8),
          //     TextButton(
          //       onPressed: () {
          //         controller.imageFile.value = null;
          //         controller.editImageUrl.value = '';
          //       },
          //       child:
          //           const Text('Remove', style: TextStyle(color: Colors.red)),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  // --- Dropdown Widgets ---
  Widget _buildBrandDropdown(AddProductController controller) {
    return Obx(() => DropdownButtonFormField<Brand>(
          value: controller.selectedBrand.value,
          decoration: const InputDecoration(
            labelText: 'Brand *',
            labelStyle: TextStyle(color: grey),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: primaryColor, width: 2.0),
            ),
          ),
          items: controller.brandList
              .map((item) =>
                  DropdownMenuItem(value: item, child: Text(item.name ?? '')))
              .toList(),
          onChanged: (v) => controller.selectedBrand.value = v,
          validator: (v) => v == null ? 'Required' : null,
        ));
  }

  Widget _buildCategoryDropdown(AddProductController controller) {
    return Obx(() => DropdownButtonFormField<Category>(
          value: controller.selectedCategory.value,
          decoration: const InputDecoration(
            labelText: 'Category *',
            labelStyle: TextStyle(color: grey),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: primaryColor, width: 2.0),
            ),
          ),
          items: controller.categoryList
              .map((item) =>
                  DropdownMenuItem(value: item, child: Text(item.name ?? '')))
              .toList(),
          onChanged: (v) => controller.selectedCategory.value = v,
          validator: (v) => v == null ? 'Required' : null,
        ));
  }

  Widget _buildTagDropdown(AddProductController controller) {
    return Obx(() => DropdownButtonFormField<Tag>(
          value: controller.selectedTag.value,
          decoration: const InputDecoration(
            labelText: 'Tag *',
            labelStyle: TextStyle(color: grey),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: primaryColor, width: 2.0),
            ),
          ),
          items: controller.tagList
              .map((item) =>
                  DropdownMenuItem(value: item, child: Text(item.name ?? '')))
              .toList(),
          onChanged: (v) => controller.selectedTag.value = v,
          validator: (v) => v == null ? 'Required' : null,
        ));
  }

  Widget _buildUnitDropdown(AddProductController controller) {
    return Obx(() => DropdownButtonFormField<Unit>(
          value: controller.selectedUnit.value,
          decoration: const InputDecoration(
            labelText: 'Unit *',
            labelStyle: TextStyle(color: grey),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: primaryColor, width: 2.0),
            ),
          ),
          items: controller.unitList
              .map((item) =>
                  DropdownMenuItem(value: item, child: Text(item.name ?? '')))
              .toList(),
          onChanged: (v) => controller.selectedUnit.value = v,
          validator: (v) => v == null ? 'Required' : null,
        ));
  }

  Widget _buildBranchDropdown(AddProductController controller) {
    return Obx(() {
      return MultiDropdown<Branch>(
        items: controller.branchList
            .map((branch) => DropdownItem(
                  label: branch.name ?? 'Unknown',
                  value: branch,
                ))
            .toList(),
        controller: controller.branchController,
        enabled: true,
        searchEnabled: true,
        chipDecoration: const ChipDecoration(
          backgroundColor: primaryColor,
          wrap: true,
          runSpacing: 2,
          spacing: 10,
        ),
        fieldDecoration: const FieldDecoration(
          hintText: 'Select Branches *',
          showClearIcon: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: primaryColor, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
        ),
        dropdownItemDecoration: DropdownItemDecoration(
          selectedIcon: const Icon(Icons.check_box, color: primaryColor),
          disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
        ),
        onSelectionChange: (selectedItems) {
          controller.selectedBranches.value = selectedItems;
        },
      );
    });
  }

  Widget _buildSectionTitle(TextTheme theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
      child: Text(title,
          style: theme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
    );
  }

  // --- Price and Variation Section ---
  Widget _buildPriceSection(AddProductController controller) {
    return Card(
      color: secondaryColor.withOpacity(0.2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Has variations?'),
                Switch(
                  activeColor: primaryColor,
                  value: controller.hasVariations.value,
                  onChanged: (val) => controller.hasVariations.value = val,
                ),
              ],
            ),
            const Divider(),
            if (!controller.hasVariations.value)
              _buildSimplePriceFields(controller)
            else
              _buildVariationPriceFields(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplePriceFields(AddProductController controller) {
    return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          spacing: 10,
          children: [
            Row(
              spacing: 5,
              children: [
                Expanded(
                    child: CustomTextFormField(
                        controller: controller.priceController,
                        labelText: 'Price *',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null)),
                Expanded(
                    child: CustomTextFormField(
                        controller: controller.stockController,
                        labelText: 'Stock *',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null)),
              ],
            ),
            Row(
              spacing: 5,
              children: [
                Expanded(
                    child: CustomTextFormField(
                  controller: controller.skuController,
                  labelText: 'SKU',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () => controller.scanBarcodeForSku(),
                    tooltip: 'Scan barcode',
                  ),
                )),
                Expanded(
                    child: CustomTextFormField(
                        controller: controller.codeController,
                        labelText: 'Code')),
              ],
            )
          ],
        ));
  }

  Widget _buildVariationPriceFields(AddProductController controller) {
    return Obx(() => Column(
          children: [
            ...List.generate(controller.variationGroups.length, (index) {
              final group = controller.variationGroups[index];
              return _buildVariationGroup(controller, group, index);
            }),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // background color
                  foregroundColor: white, // text (foreground) color
                ),
                onPressed: controller.addVariationGroup,
                icon: const Icon(
                  Icons.add,
                  color: white,
                ),
                label: const Text('Add More Variation'),
              ),
            ),
            if (controller.generatedVariants.isNotEmpty)
              const SizedBox(height: 16),
            ...List.generate(controller.generatedVariants.length, (index) {
              final variant = controller.generatedVariants[index];
              return _buildVariantInputRow(variant);
            }),
          ],
        ));
  }

  Widget _buildVariationGroup(
      AddProductController controller, VariationGroup group, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Obx(() => DropdownButtonFormField<Variation>(
                  value: group.selectedType.value,
                  decoration: const InputDecoration(
                    labelText: 'Variation Type',
                    labelStyle: TextStyle(color: grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: primaryColor, width: 2.0),
                    ),
                  ),
                  items: controller.variationList
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item.name)))
                      .toList(),
                  onChanged: (v) {
                    group.selectedType.value = v;
                    group.selectedValues.clear();
                    controller.update(); // Re-triggers UI build
                  },
                  validator: (v) => v == null ? 'Required' : null,
                )),
          ),
          const SizedBox(width: 8),
          Expanded(
              flex: 3,
              child: Obx(() {
                final variationType = group.selectedType.value;
                if (variationType?.values == null ||
                    variationType!.values.isEmpty) {
                  return InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Variation Value',
                      labelStyle: TextStyle(color: grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: primaryColor, width: 2.0),
                      ),
                    ),
                    child: const Text('Select variation type ',
                        style: TextStyle(color: Colors.black54)),
                  );
                }

                return MultiDropdown<String>(
                  items: variationType.values
                      .map((value) => DropdownItem(
                            label: value,
                            value: value,
                          ))
                      .toList(),
                  controller: group.valuesController,
                  enabled: true,
                  searchEnabled: true,
                  chipDecoration: const ChipDecoration(
                    backgroundColor: primaryColor,
                    wrap: true,
                    runSpacing: 2,
                    spacing: 10,
                  ),
                  fieldDecoration: const FieldDecoration(
                    hintText: 'Select Values',
                    showClearIcon: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: primaryColor, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                    ),
                  ),
                  dropdownItemDecoration: DropdownItemDecoration(
                    selectedIcon:
                        const Icon(Icons.check_box, color: primaryColor),
                    disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
                  ),
                  onSelectionChange: (selectedItems) {
                    controller.onVariationValuesChanged(index, selectedItems);
                  },
                );
              })),
          IconButton(
              onPressed: () => controller.removeVariationGroup(index),
              icon: const Icon(Icons.delete_outline, color: primaryColor)),
        ],
      ),
    );
  }

  Widget _buildVariantInputRow(GeneratedVariant variant) {
    final label = variant.combination.entries.map((e) => e.value).join(' / ');
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              spacing: 5,
              children: [
                Expanded(
                    child: TextFormField(
                        controller: variant.priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          labelStyle: TextStyle(color: grey),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2.0),
                          ),
                        ),
                        keyboardType: TextInputType.number)),
                Expanded(
                    child: TextFormField(
                        controller: variant.stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock',
                          labelStyle: TextStyle(color: grey),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2.0),
                          ),
                        ),
                        keyboardType: TextInputType.number)),
              ],
            ),
            Row(
              spacing: 5,
              children: [
                Expanded(
                    child: TextFormField(
                        controller: variant.skuController,
                        decoration: const InputDecoration(
                          labelText: 'SKU',
                          labelStyle: TextStyle(color: grey),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2.0),
                          ),
                        ))),
                Expanded(
                    child: TextFormField(
                        controller: variant.codeController,
                        decoration: const InputDecoration(
                          labelText: 'Code',
                          labelStyle: TextStyle(color: grey),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2.0),
                          ),
                        )))
              ],
            )
          ],
        )
        // Row(
        //   children: [
        //     Expanded(
        //         flex: 2,
        //         child:
        //     const SizedBox(width: 8),

        //     const SizedBox(width: 8),

        //     const SizedBox(width: 8),

        //     const SizedBox(width: 8),
        //    ,
        //   ],
        // ),
        );
  }

  // Removed _buildDiscountSection and _buildDateField as they are no longer needed
  // Widget _buildDiscountSection(AddProductController controller) {
  //   return Column(
  //     children: [
  //       Row(
  //         children: [
  //           Expanded(
  //             child: Obx(() => DropdownButtonFormField<String>(
  //                   value: controller.discountType.value,
  //                   items: ['fixed', 'percentage']
  //                       .map((t) => DropdownMenuItem(
  //                             value: t,
  //                             child: Text(t[0].toUpperCase() + t.substring(1)),
  //                           ))
  //                       .toList(),
  //                   onChanged: (v) => controller.discountType.value = v!,
  //                   decoration: const InputDecoration(
  //                       labelText: 'Type', border: OutlineInputBorder()),
  //                 )),
  //           ),
  //           const SizedBox(width: 8),
  //           Expanded(
  //               child: _buildDateField(
  //                   Get.context!, controller.startDate, 'Start Date')),
  //           const SizedBox(width: 8),
  //           Expanded(
  //               child: _buildDateField(
  //                   Get.context!, controller.endDate, 'End Date')),
  //         ],
  //       ),
  //       const SizedBox(height: 12),
  //       TextFormField(
  //         controller: controller.discountAmountController,
  //         decoration: const InputDecoration(
  //             labelText: 'Discount Amount', border: OutlineInputBorder()),
  //         keyboardType: TextInputType.number,
  //       ),
  //     ],
  //   );
  // }
  //
  // Widget _buildDateField(
  //     BuildContext context, Rx<DateTime?> date, String label) {
  //   final format = DateFormat('MM/dd/yyyy');
  //   return Obx(() => InkWell(
  //         onTap: () async {
  //           final picked = await showDatePicker(
  //             context: context,
  //             initialDate: date.value ?? DateTime.now(),
  //             firstDate: DateTime(2000),
  //             lastDate: DateTime(2101),
  //           );
  //           if (picked != null) {
  //             date.value = picked;
  //           }
  //         },
  //         child: InputDecorator(
  //           decoration: InputDecoration(
  //               labelText: label, border: const OutlineInputBorder()),
  //           child: Text(
  //               date.value != null ? format.format(date.value!) : 'mm/dd/yyyy'),
  //         ),
  //       ));
  // }

  Widget _buildStatusSelector(AddProductController controller) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextWidget(
              text: 'Status',
              textStyle: CustomTextStyles.textFontRegular(size: 14.sp),
            ),
            Switch(
              value: controller.status.value == 'active',
              onChanged: (value) {
                controller.status.value = value ? 'active' : 'inactive';
              },
              activeColor: primaryColor,
            ),
          ],
        ));
  }

  Widget _buildActionButtons(AddProductController controller, bool isEditMode) {
    return ElevatedButtonExample(
        text: isEditMode ? 'Update Product' : 'Add Product',
        onPressed: controller.saveProduct);

    // ElevatedButton(
    //   onPressed: controller.saveProduct,
    //   child: Text(isEditMode ? 'Update Product' : 'Add Product'),
    // );
    // Obx(() => controller.isLoading.value
    //     ? const Center(child: CircularProgressIndicator())
    //     : Row(
    //         children: [
    //           Expanded(
    //             child: ElevatedButton(
    //               style: ElevatedButton.styleFrom(
    //                   padding: const EdgeInsets.symmetric(vertical: 16)),
    //               onPressed: controller.saveProduct,
    //               child: Text(isEditMode ? 'Update Product' : 'Add Product'),
    //             ),
    //           ),
    //           const SizedBox(width: 8),
    //           Expanded(
    //             child: OutlinedButton(
    //               style: OutlinedButton.styleFrom(
    //                   padding: const EdgeInsets.symmetric(vertical: 16)),
    //               onPressed: () => Get.back(),
    //               child: const Text('Cancel'),
    //             ),
    //           ),
    //         ],
    //       ));
  }
}
