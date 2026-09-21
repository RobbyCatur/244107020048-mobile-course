import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  group('Comment.fromJson', () {
    test('field yang hilang/null diberi nilai default, tidak crash', () {
      // JSON sengaja tidak punya `name`, `email` bernilai null,
      // dan `postId` bertipe salah (String, bukan num).
      final comment = Comment.fromJson(const {
        'postId': 'bukan-angka',
        'id': 7,
        'email': null,
        'body': 'Halo dunia',
      });

      // num? -> kalau bukan angka/null, fallback 0.
      expect(comment.postId, 0);
      expect(comment.id, 7);
      // String? -> kalau hilang atau null, fallback ''.
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, 'Halo dunia');
    });

    test('JSON lengkap diparse sesuai nilai aslinya', () {
      final comment = Comment.fromJson(const {
        'postId': 1,
        'id': 2,
        'name': 'id labore ex et quam laborum',
        'email': 'Eliseo@gardner.biz',
        'body': 'laudantium enim quasi est...',
      });

      expect(comment.postId, 1);
      expect(comment.id, 2);
      expect(comment.name, 'id labore ex et quam laborum');
      expect(comment.email, 'Eliseo@gardner.biz');
      expect(comment.body, 'laudantium enim quasi est...');
    });
  });
}
