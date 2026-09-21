import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/pages/post_detail_page.dart';

/// Fake repository: mencatat apakah fetchPost dipanggil, supaya kita
/// bisa membuktikan jalur "dari cache list" vs "via repository".
class DetailFakeRepository extends PostRepository {
  DetailFakeRepository() : super(Dio());

  int fetchPostCalls = 0;

  @override
  Future<List<Post>> fetchPostsPage(
      {required int page, int limit = 10}) async {
    if (page != 1) return [];
    return List.generate(
      3,
      (i) => Post(
          userId: 1, id: i + 1, title: 'Judul $i', body: 'isi $i'),
    );
  }

  @override
  Future<Post> fetchPost(int id) async {
    fetchPostCalls++;
    return Post(
        userId: 7, id: id, title: 'Fetched $id', body: 'body lengkap');
  }
}

Widget _app(Widget child) => MaterialApp(home: child);

void main() {
  testWidgets(
      'Detail dari cache: post ada di list termuat -> tanpa fetch baru',
      (tester) async {
    final repo = DetailFakeRepository();
    await tester.pumpWidget(ProviderScope(
      overrides: [postRepositoryProvider.overrideWith((ref) => repo)],
      child: _app(const PostDetailPage(postId: 2)),
    ));
    await tester.pumpAndSettle();

    // pagedPostsProvider dipantau halaman detail -> list page 1 termuat,
    // post id=2 ketemu di cache -> title dari list, bukan 'Fetched'.
    expect(find.text('Judul 1'), findsOneWidget);
    expect(repo.fetchPostCalls, 0);
  });

  testWidgets(
      'Detail via repository: post tidak ada di list -> GET /posts/:id',
      (tester) async {
    final repo = DetailFakeRepository();
    await tester.pumpWidget(ProviderScope(
      overrides: [postRepositoryProvider.overrideWith((ref) => repo)],
      child: _app(const PostDetailPage(postId: 999)),
    ));
    await tester.pumpAndSettle();

    expect(repo.fetchPostCalls, 1);
    expect(find.text('Fetched 999'), findsOneWidget);
    expect(find.text('body lengkap'), findsOneWidget);
  });
}
