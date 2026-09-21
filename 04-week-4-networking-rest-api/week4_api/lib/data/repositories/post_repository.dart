import 'package:dio/dio.dart';
import '../models/post.dart';

class PostRepository {
  PostRepository(this._dio);
  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get<List>('/posts');
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
  }

  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    final response = await _dio.get<List>(
      '/posts',
      queryParameters: {'_page': page, '_limit': limit},
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
  }

  /// Ambil satu post via GET /posts/:id — dipakai halaman detail saat
  /// dibuka langsung (deep link) dan post belum ada di list yang termuat.
  Future<Post> fetchPost(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/posts/$id');
    final data = response.data;
    // JSONPlaceholder membalas {} (bukan 404) untuk id tak dikenal.
    if (data == null || data.isEmpty) {
      throw StateError('Post dengan id $id tidak ditemukan.');
    }
    return Post.fromJson(data);
  }
}
