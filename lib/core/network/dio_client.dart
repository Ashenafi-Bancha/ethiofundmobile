import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';
import '../../providers/auth_provider.dart';

class DioClient {
  DioClient(this.ref) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;
          if (!path.contains(ApiConstants.login) && !path.contains(ApiConstants.register)) {
            final token = await ref.read(secureStorageProvider).getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await ref.read(secureStorageProvider).clearAll();
            ref.invalidate(authNotifierProvider);
          }
          handler.reject(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }
  }

  final Ref ref;
  late final Dio dio;
}

final dioClientProvider = Provider<DioClient>((ref) => DioClient(ref));

extension DioExceptionMapper on DioException {
  ApiException toApiException() => ApiException.fromDioError(this);
}