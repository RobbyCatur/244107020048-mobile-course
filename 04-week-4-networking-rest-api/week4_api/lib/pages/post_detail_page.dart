import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/network_errors.dart';
import '../data/paged_posts.dart';
import '../data/providers.dart';

/// Halaman detail post untuk route GoRouter `/post/:id`.
///
/// Sumber data (berjenjang):
/// 1. List yang sudah dimuat di `pagedPostsProvider` (user navigasi dari
///    halaman utama) -> tampil instan, nol request baru.
/// 2. Deep link / buka langsung -> `postDetailProvider(id)` memanggil
///    repository GET /posts/:id.
class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(pagedPostsProvider);

    // (1) Cari dulu di cache list — hindari fetch ulang yang percuma.
    final matches = listState.items.where((p) => p.id == postId);
    if (matches.isNotEmpty) {
      return _DetailScaffold(post: matches.first);
    }

    // (2) Load pertama list masih berjalan (page==0 & belum error) ->
    // tunggu; post mungkin akan muncul dari list, jadi jangan fetch duluan.
    if (listState.page == 0 && listState.error == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // (3) Pasti tidak ada di list -> ambil via repository
    // (AsyncValue menangani loading/error otomatis).
    final detail = ref.watch(postDetailProvider(postId));
    return Scaffold(
      appBar: AppBar(title: Text('Post #${postId.toString()}')),
      body: detail.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyErrorMessage(err),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(postDetailProvider(postId)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (post) => _DetailBody(post: post),
      ),
    );
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post #${post.id.toString()}')),
      body: _DetailBody(post: post),
    );
  }
}

/// Isi detail: judul dan body lengkap.
class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(post.title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Oleh user #${post.userId.toString()}',
            style: theme.textTheme.bodySmall),
        const Divider(height: 32),
        Text(post.body, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
