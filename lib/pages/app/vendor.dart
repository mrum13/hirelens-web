import "package:flutter/material.dart";
import "package:hirelens_admin/pages/app/_layout.dart";
// import "package:hirelens_admin/theme.dart";

class VendorPage extends StatefulWidget {
  const VendorPage({super.key});

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  @override
  Widget build(BuildContext context) {
    return MyAppLayout(child: Container(child: Text("VendorPage")));
  }
}
