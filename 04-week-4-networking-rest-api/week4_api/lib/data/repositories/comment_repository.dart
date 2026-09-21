import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository layer: satu-satunya tempat logika HTTP untuk Comment.
/// UI/Provider tidak menyentuh Dio langsung, hanya memanggil method ini,
/// sehingga mudah di-mock saat testing.
class CommentRepository {
  CommentRepository(this._dio);

  final Dio _dio;

  /// Timeout request ini dibatasi 10 detik. Dio sudah punya global
  /// connect/receive timeout 10s di api_client.dart, tetapi [Options]
  /// di bawah menegaskan batas per-request agar tidak berubah diam-diam
  /// jika konfigurasi global diedit.
  static const Duration _requestTimeout = Duration(seconds: 10);

  /// Ambil daftar komentar milik satu post via GET /comments?postId={id}.
  /// Exception Dio (timeout/connection/badResponse) dibiarkan naik ke
  /// caller; AsyncNotifier akan mengonversinya menjadi AsyncError.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      options: Options(
        sendTimeout: _requestTimeout,
        receiveTimeout: _requestTimeout,
      ),
    );
    // response.data bisa null bila body kosong -> fallback daftar kosong.
    final data = response.data ?? [];
    // whereType menyaring elemen yang bukan Map (mis. null di array JSON)
    // supaya fromJson tidak pernah dipanggil dengan tipe salah.
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
