import "package:go_router/go_router.dart";
import "package:supabase_flutter/supabase_flutter.dart";

// Pages
import "package:hirelens_admin/pages/login.dart";
import "package:hirelens_admin/pages/app/home.dart";
import "package:hirelens_admin/pages/app/user.dart";
import "package:hirelens_admin/pages/app/vendor.dart";
import "package:hirelens_admin/pages/app/item.dart";
import "package:hirelens_admin/pages/app/transaction.dart";

GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => LoginPage()),
    GoRoute(path: '/app/home', builder: (context, state) => HomePage()),
    GoRoute(path: '/app/users', builder: (context, state) => UserPage()),
    GoRoute(
      path: '/app/transactions',
      builder: (context, state) => TransactionPage(),
    ),
    GoRoute(path: '/app/items', builder: (context, state) => ItemPage()),
    GoRoute(path: '/app/vendors', builder: (context, state) => VendorPage()),
  ],
  initialLocation: '/',
  redirect: (ctx, state) {
    final logged = Supabase.instance.client.auth.currentSession != null;
    final onLogin = state.matchedLocation == '/';
    if (!logged && !onLogin) return '/';
    if (logged && onLogin) return '/app/home';

    return null;
  },
);
