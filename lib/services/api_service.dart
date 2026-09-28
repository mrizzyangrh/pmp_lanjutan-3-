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

 String _friendlyMessage(DioException e) {
  final status = e.response?.statusCode;
  final serverError = e.response?.data is Map
      ? (e.response?.data as Map)['error']?.toString()
      : null;

  if (status == 401) {
    return '401 Unauthorized${serverError != null ? ': $serverError' : ''}. '
        'ReqRes wajib header x-api-key. Periksa ApiService._apiKey.';
  }
  if (status == 403) {
    return '403 Forbidden${serverError != null ? ': $serverError' : ''}. '
        'API key ditolak / limit habis.';
  }
  if (status != null && status >= 500) {
    return 'Server error ($status). Coba lagi nanti.';
  }
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Timeout: server tidak merespons. Periksa koneksi internet.';
    case DioExceptionType.connectionError:
      return 'Tidak ada koneksi internet / server tidak terjangkau.';
    default:
      return serverError ?? e.message ?? 'Gagal mengambil data dari server';
  }
}
}
