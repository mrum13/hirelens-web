// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hirelens_admin/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();

class MyAppLayout extends StatefulWidget {
  Widget child;

  MyAppLayout({super.key, required this.child});

  @override
  State<MyAppLayout> createState() => _MyAppLayoutState();
}

class _MyAppLayoutState extends State<MyAppLayout> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        drawer: Container(
          width: MediaQuery.of(context).size.width * 0.25,
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeFromContext(context).colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView(
            children: [
              ListTile(
                title: Text('Home'),
                onTap: () => context.go('/app/home'),
              ),
              Divider(),
              ListTile(
                title: Text('Users'),
                onTap: () => context.go('/app/users'),
              ),
              ListTile(
                title: Text('Vendors'),
                onTap: () => context.go('/app/vendors'),
              ),
              Divider(),
              ListTile(
                title: Text('Transactions'),
                onTap: () => context.go('/app/transactions'),
              ),
              Divider(),
              ListTile(
                title: Text('Items'),
                onTap: () => context.go('/app/items'),
              ),
            ],
          ),
        ),
        endDrawer: Container(
          width: MediaQuery.of(context).size.width * 0.25,
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeFromContext(context).colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView(
            children: [
              ListTile(
                title: Text('Home'),
                onTap: () => context.go('/app/home'),
              ),
              Divider(),
              ListTile(
                title: Text('Users'),
                onTap: () => context.go('/app/users'),
              ),
              ListTile(
                title: Text('Vendors'),
                onTap: () => context.go('/app/vendors'),
              ),
              Divider(),
              ListTile(
                title: Text('Transactions'),
                onTap: () => context.go('/app/transactions'),
              ),
              Divider(),
              ListTile(
                title: Text('Items'),
                onTap: () => context.go('/app/items'),
              ),
            ],
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 96),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: themeFromContext(context).colorScheme.surfaceBright,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      scaffoldKey.currentState!.openDrawer();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      GoRouter.of(context).replace('/');
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
