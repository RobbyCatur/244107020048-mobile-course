import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/main.dart';

/// Repository palsu: UI tidak boleh menyentuh Dio di test ini —
/// kita override postRepositoryProvider, membuktikan arsitektur
/// "UI -> provider -> repository" bisa di-mock dengan mudah.
class FakePostRepository extends PostRepository {
  FakePostRepository({required this.pageSizes}) : super(Dio());

  /// Jumlah item yang dikembalikan per halaman, mis. {1: 10, 2: 5}.
  final Map<int, int> pageSizes;
  final Map<int, int> fetchCount = {};

  @override
  Future<List<Post>> fetchPostsPage(
      {required int page, int limit = 10}) async {
    fetchCount[page] = (fetchCount[page] ?? 0) + 1;
    final count = pageSizes[page] ?? 0;
    return List.generate(
      count,
      (i) => Post(
          userId: 1,
          id: page * 100 + i,
          title: 'Post $page-$i',
          body: 'body'),
    );
  }

  @override
  Future<Post> fetchPost(int id) async {
    // Jalur detail diuji terpisah; di test list tidak boleh ada fetch
    // single-post (dan tidak boleh ada HTTP sungguhan).
    throw StateError('fetchPost tidak boleh dipanggil di test ini');
  }
}

void main() {
  testWidgets('Pagination: load 10 awal lalu bertambah saat scroll',
      (tester) async {
    final repo = FakePostRepository(pageSizes: const {1: 10, 2: 5});
    await tester.pumpWidget(ProviderScope(
      overrides: [
        postRepositoryProvider.overrideWith((ref) => repo),
      ],
      child: const MyApp(),
    ));

    // Halaman pertama termuat lewat microtask di build() notifier.
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(10));
    expect(repo.fetchCount[1], 1);

    // Scroll sampai dasar -> halaman 2 dimuat, footer tampil
    // indikator akhir data karena halaman 2 hanya 5 item (< limit).
    await tester.dragUntilVisible(
      find.text('Semua data termuat.'),
      find.byType(ListView),
      const Offset(0, -150),
    );
    await tester.pumpAndSettle();

    // ListView.builder lazy: tidak semua 15 tile ada di tree.
    // Bukti data bertambah: item terakhir halaman 2 tepat di atas
    // footer, dan tiap halaman hanya direquest sekali.
    expect(find.text('Post 2-4'), findsOneWidget);
    expect(repo.fetchCount[1], 1);
    expect(repo.fetchCount[2], 1);
    expect(find.text('Semua data termuat.'), findsOneWidget);
  });

  testWidgets('Klik tile -> GoRouter ke /post/:id, detail dari cache',
      (tester) async {
    final repo = FakePostRepository(pageSizes: const {1: 10});
    await tester.pumpWidget(ProviderScope(
      overrides: [
        postRepositoryProvider.overrideWith((ref) => repo),
      ],
      child: const MyApp(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Post 1-0'));
    await tester.pumpAndSettle();

    // Fake id = page*100+i -> tile pertama id 100.
    // Detail tampil dari cache list; jika malah memanggil fetchPost,
    // fake akan melempar StateError dan 'Oleh user #1' tidak muncul.
    expect(find.text('Post #100'), findsOneWidget);
    expect(find.text('Oleh user #1'), findsOneWidget); // body detail
  });

  testWidgets('State empty: server balas sukses tapi 0 data',
      (tester) async {
    final repo = FakePostRepository(pageSizes: const {});
    await tester.pumpWidget(ProviderScope(
      overrides: [
        postRepositoryProvider.overrideWith((ref) => repo),
      ],
      child: const MyApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada data dari server.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('State error + retry: gagal lalu sukses setelah override stabil',
      (tester) async {
    final repo = FailOncePostRepository();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        postRepositoryProvider.overrideWith((ref) => repo),
      ],
      child: const MyApp(),
    ));
    await tester.pumpAndSettle();

    // Error pertama harus TAMPAK (bukan spinner abadi) + tombol retry.
    expect(find.textContaining('Coba lagi'), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    // Retry memanggil loadFirstPage lagi dan kini sukses.
    expect(find.byType(ListTile), findsNWidgets(10));
  });
}

/// Gagal sekali (mis. jaringan putus), lalu sukses — mensimulasikan
/// DioException connectionError asli tanpa mock HTTP.
class FailOncePostRepository extends PostRepository {
  FailOncePostRepository() : super(Dio());

  int attempts = 0;

  @override
  Future<List<Post>> fetchPostsPage(
      {required int page, int limit = 10}) async {
    attempts++;
    if (attempts == 1) {
      throw DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/posts'),
      );
    }
    return List.generate(
      10,
      (i) => Post(userId: 1, id: i, title: 'T$i', body: 'b'),
    );
  }
}
