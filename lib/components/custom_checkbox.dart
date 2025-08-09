import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool isRequired;

  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? AppConstants.primaryGreen : AppConstants.lightGrey,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color:
                    value ? AppConstants.primaryGreen : AppConstants.textGrey,
                width: 1,
              ),
            ),
            child:
                value
                    ? const Icon(
                      Icons.check,
                      color: AppConstants.white,
                      size: 16,
                    )
                    : null,
          ),
          if (label != null) ...[
            const SizedBox(width: 8),
            Text(
              label!,
              style: AppConstants.captionStyle.copyWith(
                color: AppConstants.textGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
