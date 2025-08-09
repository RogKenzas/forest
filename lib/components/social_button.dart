import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class SocialButton extends StatelessWidget {
  final String provider;
  final VoidCallback? onPressed;
  final double size;

  const SocialButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppConstants.lightGrey,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(color: AppConstants.darkGrey, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: _buildIcon()),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (provider.toLowerCase()) {
      case 'google':
        return Image.asset("assets/img/google.png");
      case 'apple':
        return Image.asset("assets/img/apple.png");
      case 'facebook':
        return Image.asset("assets/img/facebook.png");
      default:
        return Image.asset("assets/img/google.png");
    }
  }
}
