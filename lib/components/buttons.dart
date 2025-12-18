// ignore_for_file: must_be_immutable

import "package:flutter/material.dart";
import "package:hirelens_admin/theme.dart";

enum MyFilledButtonVariant { primary, secondary, tertiary, neutral, error }

class MyFilledButton extends StatefulWidget {
  bool isLoading;
  final Widget child;
  double? width;
  double? height;
  final Alignment alignment;
  final MyFilledButtonVariant variant;
  final void Function()? onTap;
  final EdgeInsets padding;

  MyFilledButton({
    super.key,
    this.isLoading = false,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    this.alignment = Alignment.center,
    this.width = double.infinity,
    required this.variant,
    required this.child,
    required this.onTap,
  });

  @override
  State<MyFilledButton> createState() => _MyFilledButtonState();
}

class _MyFilledButtonState extends State<MyFilledButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: widget.padding,
        alignment: widget.alignment,
        decoration: _variantSelector(widget.variant),
        width: widget.width,
        height: widget.height,
        child:
            !widget.isLoading
                ? widget.child
                : CircularProgressIndicator(
                  color: hirelensDarkTheme.colorScheme.surface,
                ),
      ),
    );
  }
}

BoxDecoration _variantSelector(MyFilledButtonVariant variant) {
  switch (variant) {
    case MyFilledButtonVariant.primary:
      return BoxDecoration(
        color: hirelensDarkTheme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      );
    case MyFilledButtonVariant.secondary:
      return BoxDecoration(
        color: hirelensDarkTheme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      );
    case MyFilledButtonVariant.tertiary:
      return BoxDecoration(
        color: hirelensDarkTheme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(16),
      );
    case MyFilledButtonVariant.neutral:
      return BoxDecoration(
        color: hirelensDarkTheme.colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(16),
      );
    case MyFilledButtonVariant.error:
      return BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(16),
      );
  }
}
