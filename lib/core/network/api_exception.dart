import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiException('Connection timeout');
      case DioExceptionType.receiveTimeout:
        return const ApiException('Server not responding');
      case DioExceptionType.connectionError:
        return const ApiException('No internet connection');
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        final message = data is Map<String, dynamic> ? (data['message']?.toString() ?? 'Request failed') : 'Request failed';
        return ApiException(message, statusCode: error.response?.statusCode);
      default:
        return const ApiException('Something went wrong');
    }
  }

  @override
  String toString() => message;
}