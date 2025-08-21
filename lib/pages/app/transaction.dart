import "package:flutter/material.dart";
import "package:hirelens_admin/pages/app/_layout.dart";
// import "package:hirelens_admin/theme.dart";

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  Widget build(BuildContext context) {
    return MyAppLayout(child: Container(child: Text("TransactionPage")));
  }
}
