import 'package:flutter/material.dart';
import 'package:northern_trader/common/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
      onPressed: (onPressed == null || isLoading) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: limeGreen,
        minimumSize: const Size(double.infinity, 50),
        disabledBackgroundColor: Colors.grey[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

