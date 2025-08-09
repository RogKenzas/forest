import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final bool isRequired;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    this.hint,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppConstants.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppConstants.bodyStyle.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          validator: (val) {
            if (isRequired && (val == null || val.isEmpty)) {
              return 'Ce champ est requis';
            }
            return validator != null ? validator!(val) : null;
          },
          onChanged: onChanged,
          dropdownColor: AppConstants.darkGrey,
          style: AppConstants.bodyStyle.copyWith(color: AppConstants.white),
          iconEnabledColor: AppConstants.textGrey,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppConstants.bodyStyle.copyWith(
              color: AppConstants.textGrey,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppConstants.lightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.fullBorderRadius,
              ),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.fullBorderRadius,
              ),
              borderSide: const BorderSide(
                color: AppConstants.primaryGreen,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
