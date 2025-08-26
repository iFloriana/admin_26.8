import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  /// Common POST method (works for JSON + Multipart)
  Future<Map<String, dynamic>?> postRequest(
    String url,
    dynamic body, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      // Detect if it's JSON or FormData
      final isFormData = body is FormData;

      Response response = await _dio.post(
        url,
        data: body,
        options: Options(
          headers: headers ??
              {
                "Content-Type":
                    isFormData ? "multipart/form-data" : "application/json",
              },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map<String, dynamic>
            ? response.data
            : {"data": response.data};
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception in postRequest: $e");
      return null;
    }
  }
}


// for normal data post
// void loginUser() async {
//   ApiService api = ApiService();

//   var res = await api.postRequest(
//     "https://yourapi.com/api/login",
//     {
//       "email": "test@gmail.com",
//       "password": "123456",
//     },
//   );

//   print(res);
// }


// for image data post
// void uploadProfileImage() async {
//   ApiService api = ApiService();

//   FormData formData = FormData.fromMap({
//     "user_id": "12345",
//     "profile_image": await MultipartFile.fromFile(
//       "/storage/emulated/0/Download/profile.png",
//       filename: "profile.png",
//     ),
//   });

//   var res = await api.postRequest(
//     "https://yourapi.com/api/upload",
//     formData,
//   );

//   print(res);
// }
