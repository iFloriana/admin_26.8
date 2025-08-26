import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../network/model/branch_model.dart';
import '../../../../wiget/Custome_button.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import '../../drawer_screen.dart';
import 'getBranchesController.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../network/network_const.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/custom_text_styles.dart';
import '../../../../wiget/Custome_textfield.dart';

class EditBranchScreen extends StatefulWidget {
  final BranchModel branch;

  const EditBranchScreen({
    Key? key,
    required this.branch,
  }) : super(key: key);

  @override
  State<EditBranchScreen> createState() => _EditBranchScreenState();
}

class _EditBranchScreenState extends State<EditBranchScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;
  late TextEditingController _contactNumberController;
  late TextEditingController _contactEmailController;
  late TextEditingController _descriptionController;
  late TextEditingController _landmarkController;
  // late TextEditingController _latitudeController;
  // late TextEditingController _longitudeController;
  final List<String> _paymentMethods = ['cash', 'upi'];
  List<String> _selectedPaymentMethods = [];
  List<Service> _selectedServices = [];
  File? _pickedImage;

  // MultiSelect controller for payment methods
  // final paymentMethodController = MultiSelectController<String>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch.name);
    _addressController = TextEditingController(text: widget.branch.address);
    _cityController = TextEditingController(text: widget.branch.city);
    _stateController = TextEditingController(text: widget.branch.state);
    _countryController = TextEditingController(text: widget.branch.country);
    _postalCodeController =
        TextEditingController(text: widget.branch.postalCode);
    _contactNumberController =
        TextEditingController(text: widget.branch.contactNumber);
    _contactEmailController =
        TextEditingController(text: widget.branch.contactEmail);
    _descriptionController =
        TextEditingController(text: widget.branch.description);
    _landmarkController = TextEditingController(text: widget.branch.landmark);
    // _latitudeController =
    //     TextEditingController(text: widget.branch.latitude.toString());
    // _longitudeController =
    //     TextEditingController(text: widget.branch.longitude.toString());
    _selectedPaymentMethods = List.from(widget.branch.paymentMethods);

    // Initialize selected services from branch
    _selectedServices = List.from(widget.branch.services);

    // Initialize MultiSelect controllers with existing data
    final controller = Get.find<Getbranchescontroller>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize payment methods
      controller.paymentMethodController
          .selectWhere((item) => _selectedPaymentMethods.contains(item.value));

      // Initialize services - wait for serviceList to be loaded
      if (controller.serviceList.isNotEmpty) {
        controller.serviceController.selectWhere((item) =>
            _selectedServices.any((service) => service.id == item.value.id));
      } else {
        // Listen for serviceList changes
        ever(controller.serviceList, (services) {
          if (services.isNotEmpty) {
            controller.serviceController.selectWhere((item) => _selectedServices
                .any((service) => service.id == item.value.id));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _contactNumberController.dispose();
    _contactEmailController.dispose();
    _descriptionController.dispose();
    _landmarkController.dispose();
    // _latitudeController.dispose();
    // _longitudeController.dispose();
    super.dispose();
  }

  void _updateBranch() {
    if (_formKey.currentState!.validate()) {
      final controller = Get.find<Getbranchescontroller>();
      controller.updateBranch(
        branchId: widget.branch.id,
        name: _nameController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        country: _countryController.text,
        postalCode: _postalCodeController.text,
        contactNumber: _contactNumberController.text,
        contactEmail: _contactEmailController.text,
        description: _descriptionController.text,
        landmark: _landmarkController.text,
        // latitude: double.parse(_latitudeController.text),
        // longitude: double.parse(_longitudeController.text),
        paymentMethod: _selectedPaymentMethods,
        services: _selectedServices,
        imageFile: _pickedImage,
      );
      Get.back();
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    await _handlePickedFile(picked);
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    await _handlePickedFile(picked);
  }

  Future<void> _handlePickedFile(XFile? pickedFile) async {
    const maxSizeInBytes = 150 * 1024; // 150 KB
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final lower = pickedFile.path.toLowerCase();
      final isAllowed = lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png');
      if (!isAllowed) {
        Get.snackbar(
            'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
        return;
      }
      if (await file.length() < maxSizeInBytes) {
        if (mounted) {
          setState(() {
            _pickedImage = file;
          });
        }
      } else {
        Get.snackbar('Error', 'Image size must be less than 150KB');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Branch'),
       drawer: DrawerScreen(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 80.w, child: _imagePickerTile()),
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Branch Name',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter branch name' : null,
              ),
              // SizedBox(height: 16.h),
              CustomTextFormField(
                controller: _addressController,
                labelText: 'Address',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter address' : null,
              ),
              // SizedBox(height: 16.h),
              Row(
                spacing: 5.w,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: _cityController,
                      labelText: 'City',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter city' : null,
                    ),
                  ),
                  // SizedBox(width: 16.w),
                  Expanded(
                    child: CustomTextFormField(
                      controller: _stateController,
                      labelText: 'State',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter state' : null,
                    ),
                  ),
                ],
              ),
              // SizedBox(height: 16.h),
              Row(
                spacing: 5.w,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: _countryController,
                      labelText: 'Country',
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter country'
                          : null,
                    ),
                  ),
                  // SizedBox(width: 16.w),
                  Expanded(
                    child: CustomTextFormField(
                      controller: _postalCodeController,
                      labelText: 'Postal Code',
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter postal code'
                          : null,
                    ),
                  ),
                ],
              ),
              // SizedBox(height: 16.h),
              CustomTextFormField(
                controller: _contactNumberController,
                labelText: 'Contact Number',
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter contact number'
                    : null,
              ),
              // SizedBox(height: 16.h),
              CustomTextFormField(
                controller: _contactEmailController,
                labelText: 'Contact Email',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter email';
                  if (!GetUtils.isEmail(value!))
                    return 'Please enter valid email';
                  return null;
                },
              ),
              // SizedBox(height: 16.h),
              CustomTextFormField(
                controller: _descriptionController,
                labelText: 'Description',
                maxLines: 3,
              ),
              // SizedBox(height: 16.h),
              CustomTextFormField(
                controller: _landmarkController,
                labelText: 'Landmark',
              ),
              // SizedBox(height: 24.h),
              // Text(
              //   'Services',
              //   style: TextStyle(
              //     fontSize: 16.sp,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: 8.h),
              _buildServiceDropdown(),
              // SizedBox(height: 24.h),
              // Text(
              //   'Payment Methods',
              //   style: TextStyle(
              //     fontSize: 16.sp,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: 8.h),
              MultiDropdown<String>(
                items: _paymentMethods
                    .map((method) => DropdownItem(
                          label: method.toUpperCase(),
                          value: method,
                        ))
                    .toList(),
                controller:
                    Get.find<Getbranchescontroller>().paymentMethodController,
                enabled: true,
                searchEnabled: true,
                chipDecoration: const ChipDecoration(
                  backgroundColor: secondaryColor,
                  wrap: true,
                  runSpacing: 2,
                  spacing: 10,
                ),
                fieldDecoration: FieldDecoration(
                  hintText: 'Select Payment Methods',
                  hintStyle:
                      CustomTextStyles.textFontMedium(size: 14.sp, color: grey),
                  showClearIcon: true,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                      color: grey,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                      color: red,
                      width: 1.0,
                    ),
                  ),
                ),
                dropdownItemDecoration: DropdownItemDecoration(
                  selectedIcon:
                      const Icon(Icons.check_box, color: primaryColor),
                  disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
                ),
                onSelectionChange: (selectedItems) {
                  if (mounted) {
                    setState(() {
                      _selectedPaymentMethods = selectedItems;
                    });
                  }
                },
              ),
              // SizedBox(height: 32.h),
              ElevatedButtonExample(
                text: "Update Branch",
                onPressed: () {
                  _updateBranch();
                },
              ),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: _updateBranch,
              //     style: ElevatedButton.styleFrom(
              //       padding: EdgeInsets.symmetric(vertical: 16.h),
              //     ),
              //     child: Text(
              //       'Update Branch',
              //       style: TextStyle(fontSize: 16.sp),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDropdown() {
    final controller = Get.find<Getbranchescontroller>();
    return Obx(() {
      return MultiDropdown<Service>(
        items: controller.serviceList
            .map((service) => DropdownItem(
                  label: service.name ?? '',
                  value: service,
                ))
            .toList(),
        controller: controller.serviceController,
        enabled: true,
        searchEnabled: true,
        chipDecoration: const ChipDecoration(
          backgroundColor: secondaryColor,
          wrap: true,
          runSpacing: 2,
          spacing: 10,
        ),
        fieldDecoration: FieldDecoration(
          hintText: 'Select Services',
          hintStyle: CustomTextStyles.textFontMedium(size: 14.sp, color: grey),
          showClearIcon: true,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(
              color: grey,
              width: 1.0,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(
              color: primaryColor,
              width: 2.0,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(
              color: red,
              width: 1.0,
            ),
          ),
        ),
        dropdownItemDecoration: DropdownItemDecoration(
          selectedIcon: const Icon(Icons.check_box, color: primaryColor),
          disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
        ),
        onSelectionChange: (selectedItems) {
          if (mounted) {
            setState(() {
              _selectedServices = selectedItems;
            });
          }
        },
      );
    });
  }

  Widget _imagePickerTile() {
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
                  onTap: () async {
                    Get.back();
                    await _pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Get.back();
                    await _pickImageFromCamera();
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
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor),
          borderRadius: BorderRadius.circular(10.r),
          color: secondaryColor.withOpacity(0.2),
        ),
        alignment: Alignment.center,
        child: _pickedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.file(
                  _pickedImage!,
                  fit: BoxFit.cover,
                  height: 120,
                  width: double.infinity,
                ),
              )
            : widget.branch.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      '${Apis.pdfUrl}${widget.branch.imageUrl}?v=${DateTime.now().millisecondsSinceEpoch}',
                      fit: BoxFit.cover,
                      height: 120,
                      width: double.infinity,
                    ),
                  )
                : const Icon(Icons.image_rounded,
                    color: primaryColor, size: 30),
      ),
    );
  }
}
