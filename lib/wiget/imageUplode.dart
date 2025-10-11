import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';

class UploadException implements Exception {
  final String message;
  UploadException(this.message);
  @override
  String toString() => message;
}

Future<dio.MultipartFile> buildMultipartFile(
  File file, {
  int maxBytes = 150 * 1024,
  List<String> allowedExtensions = const ['jpg', 'jpeg', 'png'],
}) async {
  if (!await file.exists()) {
    throw UploadException('File not found');
  }

  final fileSize = await file.length();
  if (fileSize > maxBytes) {
    throw UploadException('Image size must be less than ${maxBytes ~/ 1024}KB');
  }

  String filename = file.path.split(Platform.pathSeparator).last;
  String ext = '';
  if (filename.contains('.')) {
    ext = filename.split('.').last.toLowerCase();
  }

  if (!allowedExtensions.contains(ext)) {
    ext = 'jpg';
    if (!filename.contains('.')) filename = '$filename.$ext';
  }

  final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
  return await dio.MultipartFile.fromFile(
    file.path,
    filename: filename,
    contentType: MediaType(mime.split('/')[0], mime.split('/')[1]),
  );
}
