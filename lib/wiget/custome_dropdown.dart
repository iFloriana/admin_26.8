import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/wiget/custome_text.dart';

import '../utils/colors.dart';
import '../utils/custom_text_styles.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Function(T?) onChanged;
  final FormFieldValidator<T>? validator;
  final String Function(T)? itemToString;
  final String Function(T)?
      getId; // optional identifier extractor to normalize value
  final TextStyle labelStyle = CustomTextStyles.textFontMedium(size: 14.sp);

  CustomDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.validator,
    this.itemToString,
    this.getId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final T? normalizedValue = _normalizeValue(value, items);
    return DropdownButtonFormField<T>(
      value: normalizedValue,
      validator: validator,
      decoration: InputDecoration(
        hintText: items.isEmpty ? 'No items available' : hintText,
        labelText: labelText,
        labelStyle: CustomTextStyles.textFontMedium(size: 14.sp, color: grey),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
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
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemToString != null ? itemToString!(item) : item.toString(),
            style: CustomTextStyles.textFontRegular(size: 14.sp),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  T? _normalizeValue(T? current, List<T> list) {
    if (current == null) return null;
    // If the current instance already exists in list, use it
    for (final item in list) {
      if (identical(item, current)) return item;
    }
    // Try to match by identifier if provided
    if (getId != null) {
      try {
        final String currentId = getId!(current);
        for (final item in list) {
          if (getId!(item) == currentId) return item;
        }
      } catch (_) {}
    }
    // Fallback: if list contains current by equality
    return list.contains(current) ? current : null;
  }
}
