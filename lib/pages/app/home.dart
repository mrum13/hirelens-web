import "package:flutter/material.dart";
import "package:hirelens_admin/pages/app/_layout.dart";
// import "package:hirelens_admin/theme.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MyAppLayout(child: Container(child: Text("HomePage")));
  }
}
