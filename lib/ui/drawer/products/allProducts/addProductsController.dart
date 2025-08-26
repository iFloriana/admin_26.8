import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http_parser/http_parser.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import 'package:flutter_template/ui/drawer/products/product_list/product_list_controller.dart';
import 'package:flutter_template/ui/drawer/products/product_list/product_list_model.dart';

import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';

class Branch {
  final String? id;
  final String? name;

  Branch({this.id, this.name});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id'],
      name: json['name'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Branch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Branch(id: $id, name: $name)';
}

class Brand {
  final String? id;
  final String? name;

  Brand({this.id, this.name});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class Category {
  final String? id;
  final String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class Tag {
  final String? id;
  final String? name;

  Tag({this.id, this.name});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class Unit {
  final String? id;
  final String? name;

  Unit({this.id, this.name});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class Variation {
  final String id;
  final String name;
  final List<String> values;

  Variation({required this.id, required this.name, required this.values});

  factory Variation.fromJson(Map<String, dynamic> json) => Variation(
      id: json['_id'],
      name: json['name'],
      values: List<String>.from(json['value']));
}

class VariationGroup {
  Rx<Variation?> selectedType = Rx(null);
  RxList<String> selectedValues = <String>[].obs;
  final MultiSelectController<String> valuesController =
      MultiSelectController<String>();
}

class GeneratedVariant {
  final Map<String, String> combination;
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController skuController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  GeneratedVariant({required this.combination});
}

class AddProductController extends GetxController {
  final Product? productToEdit =
      (Get.arguments is Product) ? Get.arguments as Product : null;
  var isEditMode = false.obs;
  String? productId;

  var branchList = <Branch>[].obs;
  var selectedBranches = <Branch>[].obs;
  final branchController = MultiSelectController<Branch>();
  var selectedCategory = Rx<Category?>(null);
  var categoryList = <Category>[].obs;
  var tagList = <Tag>[].obs;
  var selectedTag = Rx<Tag?>(null);
  var unitList = <Unit>[].obs;
  var selectedUnit = Rx<Unit?>(null);
  var variationList = <Variation>[].obs;
  var selectedVariation = Rx<Variation?>(null);
  var selectedVariationValues = <String>[].obs;

  final formKey = GlobalKey<FormState>();

  // Form field controllers and state
  final productNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rx<File?> imageFile = Rx(null);
  // Holds existing image url when editing
  final RxString editImageUrl = ''.obs;

  final selectedBrand = Rx<Brand?>(null);

  final hasVariations = false.obs;
  final status = 'active'.obs;

  // State for simple product (no variations)
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final skuController = TextEditingController();
  final codeController = TextEditingController();

  // State for variations
  final variationGroups = <VariationGroup>[].obs;
  final generatedVariants = <GeneratedVariant>[].obs;

  // State for product discount - REMOVED
  // final discountType = 'fixed'.obs;
  // final discountAmountController = TextEditingController();
  // final Rx<DateTime?> startDate = Rx(null);
  // final Rx<DateTime?> endDate = Rx(null);

  final isLoading = false.obs;

  // Observables for dropdown data
  final brandList = <Brand>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (productToEdit != null) {
      isEditMode.value = true;
      productId = productToEdit!.id;
    }
    _initialize();
    ever(hasVariations, (has) {
      if (has && variationGroups.isEmpty) {
        addVariationGroup();
      }
      _generateVariants();
    });
  }

  @override
  void onClose() {
    branchController.dispose();
    // Dispose variation group controllers
    for (var group in variationGroups) {
      group.valuesController.dispose();
    }
    super.onClose();
  }

  void _initialize() async {
    await _fetchAllDropdownData();
    if (isEditMode.value) {
      populateFormForUpdate(productToEdit!);
    }
  }

  Future<void> _fetchAllDropdownData() async {
    final salonId = (await prefs.getUser())?.salonId;
    if (salonId == null) return;

    await Future.wait([
      getBrands(salonId),
      getBranches(salonId),
      getCategories(salonId),
      getTags(salonId),
      getUnits(salonId),
      getVariations(salonId),
    ]);
  }

  Future<void> getBrands(String salonId) async {
    try {
      final response = await dioClient.getData(
          '${Apis.baseUrl}${Endpoints.getBrands}$salonId', (json) => json);
      final data = response['data'] as List;
      brandList.value = data.map((e) => Brand.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get brands: $e');
    }
  }

  Future<void> getBranches(String salonId) async {
    try {
      print('Fetching branches for salon: $salonId');
      final response = await dioClient.getData(
          '${Apis.baseUrl}${Endpoints.getBranches}$salonId', (json) => json);
      print('Branches response: $response');
      final data = response['data'] as List;
      print('Branches data: $data');
      branchList.value = data.map((e) => Branch.fromJson(e)).toList();
      print('Branch list length: ${branchList.length}');
      print(
          'First branch: ${branchList.isNotEmpty ? branchList.first.name : 'No branches'}');

      // Debug controller state
      print('Branch controller items count: ${branchController.items.length}');
      print(
          'Branch controller selected items: ${branchController.selectedItems.length}');

      // Try to set items in controller
      try {
        branchController.setItems(branchList.value
            .map((branch) =>
                DropdownItem(label: branch.name ?? 'Unknown', value: branch))
            .toList());
        print('Successfully set items in branch controller');
      } catch (e) {
        print('Error setting items in branch controller: $e');
      }
    } catch (e) {
      print('Error fetching branches: $e');
      CustomSnackbar.showError('Error', 'Failed to get branches: $e');
    }
  }

  Future<void> getCategories(String salonId) async {
    try {
      final response = await dioClient.getData(
          '${Apis.baseUrl}${Endpoints.getproductName}$salonId', (json) => json);
      final data = response['data'] as List;
      categoryList.value = data.map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get categories: $e');
    }
  }

  Future<void> getTags(String salonId) async {
    try {
      final response = await dioClient.getData(
          '${Apis.baseUrl}${Endpoints.getTagsName}$salonId', (json) => json);
      final data = response['data'] as List;
      tagList.value = data.map((e) => Tag.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get tags: $e');
    }
  }

  Future<void> getUnits(String salonId) async {
    try {
      final response = await dioClient.getData(
          '${Apis.baseUrl}${Endpoints.getUnitNames}$salonId', (json) => json);
      final data = response['data'] as List;
      unitList.value = data.map((e) => Unit.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get units: $e');
    }
  }

  Future<void> getVariations(String salonId) async {
    try {
      final response = await dioClient.getData(
          '${Apis.baseUrl}${Endpoints.getVariation}$salonId', (json) => json);
      final data = response['data'] as List;
      variationList.value = data.map((e) => Variation.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get variations: $e');
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final mimeType = _getMimeType(file.path);
      if (mimeType == null) {
        CustomSnackbar.showError(
            'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
        return;
      }
      // 150 KB size limit to keep parity with other modules
      const maxSizeInBytes = 150 * 1024;
      if (await file.length() > maxSizeInBytes) {
        CustomSnackbar.showError('Error', 'Image size must be < 150KB');
        return;
      }
      editImageUrl.value = '';
      imageFile.value = file;
    }
  }

  Future<void> pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final mimeType = _getMimeType(file.path);
      if (mimeType == null) {
        CustomSnackbar.showError(
            'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
        return;
      }
      const maxSizeInBytes = 150 * 1024;
      if (await file.length() > maxSizeInBytes) {
        CustomSnackbar.showError('Error', 'Image size must be < 150KB');
        return;
      }
      editImageUrl.value = '';
      imageFile.value = file;
    }
  }

  String? _getMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    return null;
  }

  void addVariationGroup() {
    variationGroups.add(VariationGroup());
  }

  void removeVariationGroup(int index) {
    variationGroups.removeAt(index);
    _generateVariants();
  }

  void onVariationValuesChanged(int groupIndex, List<String> values) {
    variationGroups[groupIndex].selectedValues.value = values;
    // Update the MultiSelectController to reflect the selected values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      variationGroups[groupIndex].valuesController.clearAll();
      if (values.isNotEmpty) {
        variationGroups[groupIndex].valuesController.selectWhere(
              (item) => values.contains(item.value),
            );
      }
    });
    _generateVariants();
  }

  void _generateVariants() {
    if (!hasVariations.value || variationGroups.isEmpty) {
      generatedVariants.clear();
      return;
    }

    final validGroups = variationGroups
        .where(
            (g) => g.selectedType.value != null && g.selectedValues.isNotEmpty)
        .toList();

    if (validGroups.isEmpty) {
      generatedVariants.clear();
      return;
    }

    List<List<String>> valueSets =
        validGroups.map((g) => g.selectedValues.toList()).toList();
    List<List<String>> combinations = _getCartesianProduct(valueSets);

    generatedVariants.value = combinations.map((combo) {
      Map<String, String> combinationMap = {};
      for (int i = 0; i < combo.length; i++) {
        final group = validGroups[i];
        combinationMap[group.selectedType.value!.name] = combo[i];
      }
      return GeneratedVariant(combination: combinationMap);
    }).toList();
  }

  List<List<T>> _getCartesianProduct<T>(List<List<T>> lists) {
    if (lists.isEmpty) return [[]];
    List<List<T>> result = [[]];
    for (var list in lists) {
      List<List<T>> temp = [];
      for (var element in list) {
        for (var combination in result) {
          temp.add([...combination, element]);
        }
      }
      result = temp;
    }
    return result;
  }

  String toTitleCase(String str) {
    if (str.isEmpty) return '';
    return str
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  void populateFormForUpdate(Product product) {
    productNameController.text = product.productName;
    descriptionController.text = product.description;
    status.value = product.status == 1 ? 'active' : 'inactive';

    selectedBrand.value =
        brandList.firstWhereOrNull((b) => b.id == product.brandId?.id);
    
    selectedCategory.value =
        categoryList.firstWhereOrNull((c) => c.id == product.categoryId?.id);
    selectedTag.value =
        tagList.firstWhereOrNull((t) => t.id == product.tagId?.id);
    selectedUnit.value =
        unitList.firstWhereOrNull((u) => u.id == product.unitId?.id);

    if (product.branchId.isNotEmpty) {
      final branches = branchList
          .where((b) => product.branchId.any((branch) => branch.id == b.id))
          .toList();
      selectedBranches.value = branches;
      // Initialize branch controller with selected branches
      WidgetsBinding.instance.addPostFrameCallback((_) {
        branchController.selectWhere((item) =>
            selectedBranches.any((branch) => branch.id == item.value.id));
      });
    }

    hasVariations.value = product.hasVariations == 1;

    if (!hasVariations.value) {
      priceController.text = product.price?.toString() ?? '';
      stockController.text = product.stock?.toString() ?? '';
      skuController.text = product.sku ?? '';
      codeController.text = product.code ?? '';
    } else {
      // Handle population of variation fields
      if (product.variationId.isNotEmpty) {
        // Clear existing variation groups
        variationGroups.clear();

        // Create variation groups based on product data
        for (var variationData in product.variationId) {
          // Check if variationData is a Map and has the required fields
          if (variationData is Map<String, dynamic>) {
            final variationId = variationData['_id'] ?? variationData['id'];
            final variationValues =
                variationData['value'] ?? variationData['values'] ?? <String>[];

            if (variationId != null) {
              final variationGroup = VariationGroup();
              variationGroup.selectedType.value =
                  variationList.firstWhereOrNull(
                (v) => v.id == variationId,
              );

              // Add the variation group first
              variationGroups.add(variationGroup);

              // Populate the values after the group is added
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (variationValues.isNotEmpty) {
                  variationGroup.selectedValues.value =
                      List<String>.from(variationValues);
                  variationGroup.valuesController.clearAll();
                  variationGroup.valuesController.selectWhere(
                    (item) => variationValues.contains(item.value),
                  );
                }
              });
            }
          }
        }
      }

      // Populate variant data if available
      if (product.variants.isNotEmpty) {
        generatedVariants.clear();
        for (var variant in product.variants) {
          final generatedVariant = GeneratedVariant(
            combination: Map.fromEntries(
              variant.combination
                  .map((c) => MapEntry(c.variationType, c.variationValue)),
            ),
          );

          if (variant.price != null) {
            generatedVariant.priceController.text = variant.price.toString();
          }
          if (variant.stock != null) {
            generatedVariant.stockController.text = variant.stock.toString();
          }
          if (variant.sku != null) {
            generatedVariant.skuController.text = variant.sku;
          }
          if (variant.code != null) {
            generatedVariant.codeController.text = variant.code;
          }

          generatedVariants.add(generatedVariant);
        }
      }
    }

    // Removed discount population logic
    // if (product.productDiscount != null) {
    //   final discount = product.productDiscount!;
    //   discountType.value = discount.type;
    //   discountAmountController.text = discount.discountAmount.toString();
    //   startDate.value = discount.startDate;
    //   endDate.value = discount.endDate;
    // }
    // Image: keep existing network image
    editImageUrl.value = product.imageUrl ?? '';
  }

  void saveProduct() async {
    if (isEditMode.value) {
      await _updateProduct();
    } else {
      await _addProduct();
    }
  }

  Future<void> _updateProduct() async {
    if (!formKey.currentState!.validate()) {
      CustomSnackbar.showError(
          "Validation Error", "Please fill all required fields.");
      return;
    }
    isLoading.value = true;
    try {
      final loginUser = await prefs.getUser();
      final Map<String, dynamic> fields = {
        'branch_id': selectedBranches.map((branch) => branch.id).toList(),
        'product_name': productNameController.text,
        'description': descriptionController.text,
        'brand_id': selectedBrand.value!.id,
        'category_id': selectedCategory.value!.id,
        'unit_id': selectedUnit.value!.id,
        'tag_id': selectedTag.value!.id,
        'status': status.value == 'active' ? 1 : 0,
        'has_variations': hasVariations.value ? 1 : 0,
        'salon_id': loginUser!.salonId,
      };

      if (hasVariations.value) {
        fields['variation_id'] = variationGroups
            .where((g) => g.selectedType.value != null)
            .map((g) => g.selectedType.value!.id)
            .toList();
        fields['variants'] = generatedVariants.map((variant) {
          return {
            'combination': variant.combination.entries
                .map((e) => {
                      'variation_type': e.key,
                      'variation_value': e.value,
                    })
                .toList(),
            'price': double.tryParse(variant.priceController.text) ?? 0,
            'stock': int.tryParse(variant.stockController.text) ?? 0,
            'sku': variant.skuController.text,
            'code': variant.codeController.text,
          };
        }).toList();
      } else {
        fields['price'] = double.tryParse(priceController.text) ?? 0;
        fields['stock'] = int.tryParse(stockController.text) ?? 0;
        fields['sku'] = skuController.text;
        fields['code'] = codeController.text;
      }

      // Prepare FormData for multipart
      final Map<String, dynamic> formMap = Map<String, dynamic>.from(fields);
      if (imageFile.value != null) {
        final mimeType = _getMimeType(imageFile.value!.path) ?? 'image/jpeg';
        final parts = mimeType.split('/');
        formMap['image'] = await dio.MultipartFile.fromFile(
          imageFile.value!.path,
          filename: imageFile.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(parts[0], parts[1]),
        );
      }

      final formData = dio.FormData.fromMap(formMap);

      await dioClient.dio.put(
        '${Apis.baseUrl}${Endpoints.uploadProducts}/$productId',
        data: formData,
        options: dio.Options(headers: {
          'Content-Type': 'multipart/form-data',
        }),
      );

      CustomSnackbar.showSuccess("Success", "Product updated successfully!");
      Get.find<ProductListController>().fetchProducts(); // Refresh list
      Get.back();
    } catch (e) {
      CustomSnackbar.showError("Error", "Failed to update product: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _addProduct() async {
    if (!formKey.currentState!.validate()) {
      CustomSnackbar.showError(
          "Validation Error", "Please fill all required fields.");
      return;
    }

    isLoading.value = true;
    try {
      final loginUser = await prefs.getUser();

      // Ensure all required fields are present
      if (selectedBranches.isEmpty ||
          selectedBrand.value == null ||
          selectedCategory.value == null ||
          selectedUnit.value == null ||
          selectedTag.value == null ||
          productNameController.text.isEmpty ||
          descriptionController.text.isEmpty ||
          loginUser == null) {
        CustomSnackbar.showError(
            "Validation Error", "Please fill all required fields.");
        isLoading.value = false;
        return;
      }

      final Map<String, dynamic> fields = {
        'branch_id': selectedBranches.map((branch) => branch.id).toList(),
        'product_name': productNameController.text,
        'description': descriptionController.text,
        'brand_id': selectedBrand.value!.id,
        'category_id': selectedCategory.value!.id,
        'unit_id': selectedUnit.value!.id,
        'tag_id': selectedTag.value!.id,
        'status': status.value == 'active' ? 1 : 0,
        'has_variations': hasVariations.value ? 1 : 0,
        'salon_id': loginUser.salonId,
      };

      // Removed product_discount from payload
      // if (discountAmountController.text.isNotEmpty) {
      //   payload['product_discount'] = {
      //     'type': discountType.value,
      //     'start_date': startDate.value?.toIso8601String(),
      //     'end_date': endDate.value?.toIso8601String(),
      //     'discount_amount':
      //         double.tryParse(discountAmountController.text) ?? 0,
      //   };
      // }

      if (hasVariations.value) {
        fields['variation_id'] = variationGroups
            .where((g) => g.selectedType.value != null)
            .map((g) => g.selectedType.value!.id)
            .toList();

        fields['variants'] = generatedVariants.map((variant) {
          return {
            'combination': variant.combination.entries
                .map((e) => {
                      'variation_type': e.key,
                      'variation_value': e.value,
                    })
                .toList(),
            'price': double.tryParse(variant.priceController.text) ?? 0,
            'stock': int.tryParse(variant.stockController.text) ?? 0,
            'sku': variant.skuController.text,
            'code': variant.codeController.text,
          };
        }).toList();
      } else {
        fields['price'] = double.tryParse(priceController.text) ?? 0;
        fields['stock'] = int.tryParse(stockController.text) ?? 0;
        fields['sku'] = skuController.text;
        fields['code'] = codeController.text;
      }

      // Build multipart
      final Map<String, dynamic> formMap = Map<String, dynamic>.from(fields);
      if (imageFile.value != null) {
        final mimeType = _getMimeType(imageFile.value!.path) ?? 'image/jpeg';
        final parts = mimeType.split('/');
        formMap['image'] = await dio.MultipartFile.fromFile(
          imageFile.value!.path,
          filename: imageFile.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(parts[0], parts[1]),
        );
      }

      final formData = dio.FormData.fromMap(formMap);

      await dioClient.dio.post(
        '${Apis.baseUrl}${Endpoints.uploadProducts}',
        data: formData,
        options: dio.Options(headers: {
          'Content-Type': 'multipart/form-data',
        }),
      );

      // Clear all controllers and reset fields
      productNameController.clear();
      descriptionController.clear();
      priceController.clear();
      stockController.clear();
      skuController.clear();
      codeController.clear();
      // Removed discountAmountController.clear(), startDate.value = null, endDate.value = null
      selectedBrand.value = null;
      selectedCategory.value = null;
      selectedUnit.value = null;
      selectedTag.value = null;
      selectedBranches.clear();
      branchController.clearAll();
      hasVariations.value = false;
      status.value = 'active';
      variationGroups.clear();
      generatedVariants.clear();
      imageFile.value = null;

      CustomSnackbar.showSuccess("Success", "Product added successfully!");
      Get.back();
    } catch (e) {
      CustomSnackbar.showError("Error", "Failed to add product: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> scanBarcodeForSku() async {
    // Check camera permission
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        CustomSnackbar.showError("Permission Denied",
            "Camera permission is required to scan barcodes.");
        return;
      }
    }

    // Open barcode scanner
    var result = await BarcodeScanner.scan();
    if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
      skuController.text = result.rawContent;
    }
  }
}
