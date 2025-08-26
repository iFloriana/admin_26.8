import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  final Dio dio;

  DioClient() : dio = Dio() {
    dio.interceptors.add(PrettyDioLogger());

    dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json", 
      },
    );
  }

  Future<T> getData<T>(
    String endpoint,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await dio.get(endpoint);
      if (response.statusCode == 200) {
        return fromJson(response.data);
      } else {
        throw Exception('GET Error: \\${response.statusCode}');
      }
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> postFormData<T>(
    String endpoint,
    FormData formData,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await dio.post(endpoint, data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return fromJson(response.data);
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> postData<T>(String endpoint, Map<String, dynamic> data,
      T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await dio.post(endpoint, data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return fromJson(response.data);
      } else {
        throw Exception('POST Error: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> putData<T>(String endpoint, Map<String, dynamic> data,
      T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await dio.put(endpoint, data: data);
      if (response.statusCode == 200) {
        return fromJson(response.data);
      } else {
        throw Exception('PUT Error: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> capturePayment(String paymentId, double amount) async {
    try {
      String keyId = dotenv.env['RAZORPAY_KEY_ID'] ?? '';
      String keySecret = dotenv.env['RAZORPAY_KEY_SECRET'] ?? '';

      if (keyId.isEmpty || keySecret.isEmpty) {
        throw Exception('Razorpay API Keys are missing');
      }

      String basicAuth =
          'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}';

      String captureUrl =
          'https://api.razorpay.com/v1/payments/$paymentId/capture';

      Response response = await dio.post(
        captureUrl,
        options: Options(headers: {'Authorization': basicAuth}),
        data: {"amount": amount.toInt(), "currency": "INR"},
      );

      if (response.statusCode == 200) {
        print('✅ Payment Captured: $paymentId');
      } else {
        throw Exception('Capture Failed: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection Timeout, please try again.';
        case DioExceptionType.sendTimeout:
          return 'Send Timeout, please try again.';
        case DioExceptionType.receiveTimeout:
          return 'Receive Timeout, please try again.';
        case DioExceptionType.badResponse:
          return 'Server Error: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          return 'Something went wrong. Please try again.';
      }
    } else {
      return 'Unexpected error: $error';
    }
  }

  Future<T> putFormData<T>(
    String endpoint,
    FormData formData,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await dio.put(
        endpoint,
        data: formData,
        options: Options(headers: {
          'Content-Type': 'multipart/form-data',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return fromJson(response.data);
      } else {
        throw Exception('PUT FormData Error: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> patchData<T>(
    String endpoint,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await dio.patch(endpoint, data: data);
      if (response.statusCode == 200) {
        return fromJson(response.data);
      } else {
        throw Exception('PATCH Error: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> deleteData<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await dio.delete(endpoint);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          return fromJson(response.data);
        } else {
          return fromJson({});
        }
      } else {
        throw Exception('DELETE Error: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleDioError(e);
    }
  }
}
