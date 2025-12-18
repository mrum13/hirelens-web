// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hirelens_admin/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ❌ HAPUS INI - Jangan buat GlobalKey di luar class
// final scaffoldKey = GlobalKey<ScaffoldState>();

class MyAppLayout extends StatefulWidget {
  Widget child;

  MyAppLayout({super.key, required this.child});

  @override
  State<MyAppLayout> createState() => _MyAppLayoutState();
}

class _MyAppLayoutState extends State<MyAppLayout> {
  // ✅ Buat GlobalKey di dalam State, jadi setiap instance punya key sendiri
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        drawer: Container(
          width: MediaQuery.of(context).size.width * 0.25,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeFromContext(context).colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView(
            children: [
              ListTile(
                title: const Text('Home'),
                onTap: () {
                  context.go('/app/home');
                  Navigator.pop(context); // Close drawer
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Users'),
                onTap: () {
                  context.go('/app/users');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Vendors'),
                onTap: () {
                  context.go('/app/vendors');
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Transactions'),
                onTap: () {
                  context.go('/app/transactions');
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Items'),
                onTap: () {
                  context.go('/app/items');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        endDrawer: Container(
          width: MediaQuery.of(context).size.width * 0.25,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeFromContext(context).colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView(
            children: [
              ListTile(
                title: const Text('Home'),
                onTap: () {
                  context.go('/app/home');
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Users'),
                onTap: () {
                  context.go('/app/users');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Vendors'),
                onTap: () {
                  context.go('/app/vendors');
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Transactions'),
                onTap: () {
                  context.go('/app/transactions');
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Items'),
                onTap: () {
                  context.go('/app/items');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 96),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: themeFromContext(context).colorScheme.surfaceBright,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      scaffoldKey.currentState!.openDrawer();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        GoRouter.of(context).replace('/');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: widget.child,
      ),
    );
  }
}
