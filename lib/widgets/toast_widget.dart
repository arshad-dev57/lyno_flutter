import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';

class CustomToast {
  static void show({
    required BuildContext context,
    required String message,
    required Color color,
  }) {
    DelightToastBar(
      builder: (context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Image.asset("assets/images/image 10.png", height: 20, width: 20),
              // const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 400),
      position: DelightSnackbarPosition.top,
    ).show(context);
  }
}
