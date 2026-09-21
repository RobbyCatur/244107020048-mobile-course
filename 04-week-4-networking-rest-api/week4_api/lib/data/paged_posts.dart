import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/post.dart';
import 'providers.dart';

class PagedPostsState {
  const PagedPostsState({
    this.items = const [],
    this.page = 0,
    this.isLoadingFirst = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<Post> items;
  final int page;

  /// True hanya saat request halaman pertama berjalan.
  /// Tanpa flag ini, UI tidak bisa membedakan "sedang memuat"
  /// dan "server mengembalikan 0 data" (keduanya items.isEmpty).
  final bool isLoadingFirst;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;
}

class PagedPostsNotifier extends Notifier<PagedPostsState> {
  @override
  PagedPostsState build() {
    Future.microtask(loadFirstPage);
    return const PagedPostsState();
  }

  Future<void> loadFirstPage() async {
    final repository = ref.read(postRepositoryProvider);
    // Tandai "sedang memuat halaman pertama" supaya UI bisa menampilkan
    // spinner, bukan kosong/error basi, saat retry diklik.
    state = const PagedPostsState(isLoadingFirst: true);
    try {
      final items =
          await repository.fetchPostsPage(page: 1, limit: 10);
      state = PagedPostsState(
        items: items,
        page: 1,
        hasMore: items.length == 10,
      );
    } catch (e) {
      state = PagedPostsState(error: e, hasMore: false);
    }
  }

  Future<void> loadNextPage() async {
    // items.isEmpty = load pertama belum selesai/gagal -> jangan
    // tumpang tindih (mencegah race fetch page 1 dua kali).
    if (state.isLoadingFirst ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.items.isEmpty) {
      return;
    }
    final repo = ref.read(postRepositoryProvider);
    final currentItems = state.items;
    final currentPage = state.page;
    state = PagedPostsState(
      items: currentItems,
      page: currentPage,
      isLoadingMore: true,
      hasMore: state.hasMore,
    );
    try {
      final next = currentPage + 1;
      final items =
          await repo.fetchPostsPage(page: next, limit: 10);
      state = PagedPostsState(
        items: [...currentItems, ...items],
        page: next,
        hasMore: items.length == 10,
      );
    } catch (e) {
      // Simpan items + error agar UI bisa menampilkan tombol retry,
      // bukan spinner selamanya. isLoadingMore=false -> guard di atas
      // mengizinkan percobaan lagi.
      state = PagedPostsState(
        items: currentItems,
        page: currentPage,
        hasMore: true,
        error: e,
      );
    }
  }
}

final pagedPostsProvider =
    NotifierProvider<PagedPostsNotifier, PagedPostsState>(
        PagedPostsNotifier.new);