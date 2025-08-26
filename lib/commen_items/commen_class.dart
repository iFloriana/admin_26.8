import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../network/network_const.dart';

//////////////////////////////////// START IMAGE URL UTILITIES /////////////////////////////////////////

/// Construct full image URL from relative path
String? getFullImageUrl(String? relativePath) {
  if (relativePath == null || relativePath.isEmpty) return null;

  // If it's already a full URL, return as is
  if (relativePath.startsWith('http://') ||
      relativePath.startsWith('https://')) {
    return relativePath;
  }

  // Construct full URL from relative path
  // Replace backslashes with forward slashes for URL compatibility
  String normalizedPath = relativePath.replaceAll('\\', '/');

  // Remove leading slash if present to avoid double slashes
  if (normalizedPath.startsWith('/')) {
    normalizedPath = normalizedPath.substring(1);
  }

  return '${Apis.baseUrl}/$normalizedPath';
}

//////////////////////////////////// END IMAGE URL UTILITIES /////////////////////////////////////////

//////////////////////////////////// START IMAGE PICKER /////////////////////////////////////////

final ImagePicker _picker = ImagePicker();

Rx<File?> singleImage = Rx<File?>(null);
RxList<File> multipleImages = <File>[].obs;

Future<void> pickImage({bool isMultiple = false, int quality = 80}) async {
  if (isMultiple) {
    final List<XFile> images =
        await _picker.pickMultiImage(imageQuality: quality);
    multipleImages.value = images.map((x) => File(x.path)).toList();
  } else {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: quality,
    );
    if (image != null) {
      singleImage.value = File(image.path);
    }
  }
}

void removeSingleImage() {
  singleImage.value = null;
}

void removeMultipleImage(File image) {
  multipleImages.remove(image);
}

void clearImages() {
  singleImage.value = null;
  multipleImages.clear();
}

/// Get selected single image path
String? getSingleImagePath() {
  return singleImage.value?.path;
}

/// Get selected multiple image paths
List<String> getMultipleImagePaths() {
  return multipleImages.map((file) => file.path).toList();
}

//////////////////////////////////// END IMAGE PICKER /////////////////////////////////////////

//////////////////////////////////// START FILE PICKER /////////////////////////////////////////

final Rx<File?> selectedFile = Rx<File?>(null);
final RxList<File> selectedFiles = <File>[].obs;

/// Pick files - single or multiple
Future<void> pickFiles(
    {bool isMultiple = false, List<String>? allowedExtensions}) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: allowedExtensions != null ? FileType.custom : FileType.any,
    allowedExtensions: allowedExtensions,
    allowMultiple: isMultiple,
  );

  if (result != null) {
    if (isMultiple) {
      selectedFiles.value = result.paths.map((path) => File(path!)).toList();
    } else {
      selectedFile.value = File(result.files.single.path!);
    }
  }
}

/// Clear files
void clearFiles() {
  selectedFile.value = null;
  selectedFiles.clear();
}

/// Remove specific file from multiple files
void removeFile(File file) {
  selectedFiles.remove(file);
}

/// Get selected single file path
String? getSelectedFilePath() {
  return selectedFile.value?.path;
}

/// Get selected multiple file paths
List<String> getSelectedFilePaths() {
  return selectedFiles.map((file) => file.path).toList();
}

//////////////////////////////////// END FILE PICKER /////////////////////////////////////////

////////////////////////////////////  START DATEPICKER /////////////////////////////////////////

final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
Future<void> pickDate(BuildContext context) async {
  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (date != null) {
    selectedDate.value = date;
  }
}

/// Get selected date as string
String? getSelectedDateString() {
  return selectedDate.value?.toIso8601String();
}

////////////////////////////////////  END DATEPICKER /////////////////////////////////////////

////////////////////////////////////  START TIME /////////////////////////////////////////

final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
Future<void> pickTime(BuildContext context) async {
  final TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (time != null) {
    selectedTime.value = time;
  }
}

/// Get selected time as string
String? getSelectedTimeString() {
  if (Get.context == null || selectedTime.value == null) {
    return null; // Return null if context or selectedTime is null
  }
  return selectedTime.value?.format(Get.context!);
}

////////////////////////////////////  END TIME /////////////////////////////////////////

String formatTimeToString(TimeOfDay timeOfDay) {
  final now = DateTime.now();
  final time =
      DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
}

Future<void> pickAndSetDate({
  required BuildContext context,
  required TextEditingController controller,
  String format = 'yyyy-MM-dd',
}) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (pickedDate != null) {
    final formattedDate = DateFormat(format).format(pickedDate);
    controller.text = formattedDate;
  }
}
///////////////////////////////////////////////
///
