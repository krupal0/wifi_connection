import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final int? maxLength;
  final double? borderRadius;
  final Color? focusedBorderColor;
  final Color? unfocusedBorderColor;
  final String? hintText;
  final bool? enable;

  const NumberTextField({
    super.key,
    this.maxLength,
    this.borderRadius,
    this.focusedBorderColor,
    this.unfocusedBorderColor,
    this.hintText, required this.controller, this.enable,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.0,
      child: TextField(
        enabled: enable ?? true,
        controller: controller,
        maxLength: maxLength,
        decoration: InputDecoration(
          counterText: '', // Hides the default character count
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
            borderSide: BorderSide(
              color: focusedBorderColor ?? Colors.blue,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
            borderSide: BorderSide(
              color: unfocusedBorderColor ?? Colors.grey,
            ),
          ),
          hintText: hintText ?? '',
          hintStyle: TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        keyboardType: TextInputType.number,
      ),
    );
  }
}
