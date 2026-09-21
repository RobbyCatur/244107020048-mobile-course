import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/providers.dart';

/// Uji pemetaan DioException -> pesan ramah pengguna.
DioException _ex(DioExceptionType type, {int? status}) => DioException(
      type: type,
      requestOptions: RequestOptions(path: '/posts'),
      response: status == null
          ? null
          : Response(
              requestOptions: RequestOptions(path: '/posts'),
              statusCode: status,
            ),
    );

void main() {
  group('friendlyErrorMessage', () {
    test('timeout koneksi, kirim, dan terima punya pesan sama', () {
      const cases = [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ];
      for (final type in cases) {
        expect(friendlyErrorMessage(_ex(type)),
            contains('timeout'));
      }
    });

    test('connection error -> suruh cek internet', () {
      expect(
        friendlyErrorMessage(
            _ex(DioExceptionType.connectionError)),
        contains('Tidak dapat terhubung'),
      );
    });

    test('404 -> data tidak ditemukan', () {
      expect(
        friendlyErrorMessage(
            _ex(DioExceptionType.badResponse, status: 404)),
        contains('tidak ditemukan'),
      );
    });

    test('500 (dan 5xx lain) -> server bermasalah, coba lagi nanti', () {
      for (final code in [500, 502, 503]) {
        expect(
          friendlyErrorMessage(
              _ex(DioExceptionType.badResponse, status: code)),
          contains('Server bermasalah'),
        );
      }
    });
  });
}
