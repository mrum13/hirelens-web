import 'package:flutter/material.dart';
import 'package:hirelens_admin/pages/app/_layout.dart';
import 'package:hirelens_admin/theme.dart';

class EditItem extends StatelessWidget {
  const EditItem({super.key});

  @override
  Widget build(BuildContext context) {
    return MyAppLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Edit Items",
                style: themeFromContext(context).textTheme.displayLarge,
              ),
              SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}