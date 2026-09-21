import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/paged_posts.dart';
import '../data/providers.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});

  @override
  ConsumerState<PagedPostPage> createState() =>
      _PagedPostPageState();
}

class _PagedPostPageState
    extends ConsumerState<PagedPostPage> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeLoadMore);
  }

  /// Satu-satunya pemicu load-more: posisi scroll mendekati dasar.
  /// Guard anti-request-ganda ada di notifier (isLoadingMore/hasMore),
  /// jadi aman dipanggil berkali-kali.
  void _maybeLoadMore() {
    if (!_controller.hasClients) return;
    final pos = _controller.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(pagedPostsProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_maybeLoadMore);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);

    // Setelah load (pertama maupun berikutnya) selesai & sukses, cek
    // ulang posisi. Di device layar tinggi, 10 item bisa TIDAK melebihi
    // tinggi layar -> maxScrollExtent = 0 -> list tidak bisa di-scroll
    // -> listener scroll tidak pernah fires. Tanpa re-check ini app
    // tampak "stuck" selamanya. Rantai berhenti saat layar terisi
    // penuh atau hasMore=false.
    ref.listen(pagedPostsProvider, (previous, next) {
      final firstDone =
          (previous?.isLoadingFirst ?? false) && !next.isLoadingFirst;
      final moreDone =
          (previous?.isLoadingMore ?? false) && !next.isLoadingMore;
      final loadJustFinished = firstDone || moreDone;
      if (loadJustFinished && next.error == null) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _maybeLoadMore());
      }
    });

    // STATE LOADING (halaman pertama sedang dimuat / retry diklik).
    if (state.isLoadingFirst) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // STATE ERROR (load pertama gagal, belum ada data).
    if (state.error != null && state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts Paged')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyErrorMessage(state.error!)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref
                    .read(pagedPostsProvider.notifier)
                    .loadFirstPage(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // STATE EMPTY (server merespons sukses tetapi 0 data).
    if (state.items.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Belum ada data dari server.')),
      );
    }

    // STATE SUCCESS + pagination.
    return Scaffold(
      appBar: AppBar(title: const Text('Posts Paged')),
      body: ListView.builder(
        controller: _controller,
        itemCount: state.items.length + 1,
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            // Footer error load-more: dulu ini spinner abadi karena
            // error disembunyikan selama items tidak kosong.
            if (state.error != null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(friendlyErrorMessage(state.error!)),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => ref
                          .read(pagedPostsProvider.notifier)
                          .loadNextPage(),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              );
            }
            if (!state.hasMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child:
                    Center(child: Text('Semua data termuat.')),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: state.isLoadingMore
                    ? const CircularProgressIndicator()
                    : const Text('Geser untuk memuat lagi...'),
              ),
            );
          }
          final post = state.items[index];
          return ListTile(
            leading: CircleAvatar(
                child: Text(post.id.toString())),
            title: Text(post.title,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          );
        },
      ),
    );
  }
}
