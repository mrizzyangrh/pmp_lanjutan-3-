import 'package:dio/dio.dart';

import '../models/user_model.dart';

class ApiService {
  static const String _apiKey = 'reqres-free-v1';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://reqres.in/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<UserModel>> fetchUsers({String? token}) async {
    try {
      final response = await _dio.get(
        '/users',
        options: Options(headers: {'x-api-key': token ?? _apiKey}),
      );

      final responseData = response.data;
      if (responseData is! Map || responseData['data'] is! List) {
        throw const FormatException(
          'Format data pengguna dari server tidak valid.',
        );
      }

      final data = responseData['data'] as List;
      return data
          .map(
            (json) =>
                UserModel.fromJson(Map<String, dynamic>.from(json as Map)),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_friendlyMessage(e));
    } on FormatException catch (e) {
      throw Exception(e.message);
    } on TypeError {
      throw Exception('Format data pengguna dari server tidak valid.');
    }
  }

  String _friendlyMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi ke server melewati batas waktu.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
      case DioExceptionType.badResponse:
        return 'Server mengembalikan error (HTTP ${error.response?.statusCode ?? 'unknown'}).';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat koneksi server tidak valid.';
      case DioExceptionType.unknown:
        return error.message ?? 'Gagal mengambil data pengguna.';
    }
  }
}
