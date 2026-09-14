import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/product_page.dart';
import 'pages/stats_page.dart';
import 'pages/todo_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

/// Router aplikasi: ShellRoute membungkus halaman utama dengan NavigationBar;
/// ProductPage (demo AsyncValue) berdiri sendiri di rute '/produk'.
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const TodoPage()),
        GoRoute(
            path: '/stats', builder: (context, state) => const StatsPage()),
      ],
    ),
    GoRoute(
        path: '/produk', builder: (context, state) => const ProductPage()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Week 3 - ToDo',
        routerConfig: _router,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      );
}

/// Kerangka dengan NavigationBar di bawah. Index aktif diturunkan dari
/// [location] agar konsisten saat back button / deep link mengubah URL.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  int get _index => switch (location) {
        '/stats' => 1,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) => Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) =>
              context.go(index == 0 ? '/' : '/stats'),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.checklist), label: 'Tugas'),
            NavigationDestination(
                icon: Icon(Icons.bar_chart), label: 'Statistik'),
          ],
        ),
      );
}
