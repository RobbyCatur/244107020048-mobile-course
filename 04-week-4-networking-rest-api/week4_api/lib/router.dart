import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/paged_post_page.dart';
import 'pages/post_detail_page.dart';

/// Konfigurasi navigasi app.
/// Provider agar mudah di-invalidate/di-override saat widget test.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PagedPostPage(),
        routes: [
          // Route bersarang: path lengkap = /post/:id
          GoRoute(
            path: 'post/:id',
            builder: (context, state) {
              // pathParameters selalu String; id rusak -> 0 ->
              // halaman detail menampilkan pesan "tidak ditemukan",
              // bukan crash.
              final id =
                  int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return PostDetailPage(postId: id);
            },
          ),
        ],
      ),
    ],
  );
});
