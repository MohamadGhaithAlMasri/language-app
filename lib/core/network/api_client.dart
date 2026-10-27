import 'dart:convert';
import 'package:dio/dio.dart';
import '../error/failures.dart';
import '../security.dart';

class ApiClient {
  final Dio dio;

  ApiClient({required this.dio}) {
    dio.options.baseUrl = 'https://language-backend2.vercel.app';
    dio.options.connectTimeout = const Duration(seconds: 25);
    dio.options.receiveTimeout = const Duration(seconds: 25);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkFailure(
          'انتهت مهلة الاتصال بالخادم. يرجى التحقق من جودة اتصال الإنترنت والمحاولة مرة أخرى.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure(
          'تعذر الاتصال بالخادم. يرجى التأكد من اتصال الجهاز بالإنترنت ومن عمل السيرفر.',
        );
      } else if (e.type == DioExceptionType.badResponse) {
        final responseData = e.response?.data;
        if (responseData != null && responseData is Map && responseData['data'] != null) {
          try {
            final decryptedStr = SecurityUtils.decrypt(responseData['data']);
            final decoded = jsonDecode(decryptedStr);
            final errorMsg = decoded['error'] ?? decoded['message'] ?? 'حدث خطأ في الخادم';
            throw ServerFailure(errorMsg);
          } catch (_) {
            throw const ServerFailure('حدث خطأ غير متوقع في معالجة استجابة الخادم.');
          }
        }
        
        // Non-encrypted error or fallback
        final errorMsg = (e.response?.data is Map)
            ? (e.response?.data['error'] ?? e.response?.data['message'] ?? 'فشل طلب الخادم')
            : 'فشل طلب الخادم';
        throw ServerFailure(errorMsg);
      } else {
        throw ServerFailure(
          'حدث خطأ غير متوقع أثناء الاتصال بالشبكة: ${e.message ?? "خطأ مجهول"}',
        );
      }
    } catch (e) {
      throw ServerFailure('حدث خطأ داخلي في التطبيق: $e');
    }
  }
}
