import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';

class CloudinaryService {
  static const String cloudName = 'db7tgqxq1';
  static const String uploadPreset = 'ml_default';
  
  static String _getMimeType(String filename) {
    final ext = filename.toLowerCase().split('.').last;
    switch (ext) {
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
  
  /// Загрузка видео из PlatformFile
  static Future<String?> uploadVideo(PlatformFile file) async {
    try {
      if (file.bytes == null) {
        throw Exception('Файл не содержит данных');
      }

      debugPrint('CloudinaryService: Начинаем загрузку видео ${file.name}, размер: ${file.bytes!.length} байт');

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      
      request.fields['upload_preset'] = uploadPreset;
      
      final mimeType = _getMimeType(file.name);
      debugPrint('CloudinaryService: MIME type: $mimeType');
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
          contentType: MediaType.parse(mimeType),
        ),
      );

      debugPrint('CloudinaryService: Отправляем запрос...');
      
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 10),
        onTimeout: () {
          throw Exception('Превышено время ожидания загрузки');
        },
      );
      
      debugPrint('CloudinaryService: Получен ответ, статус: ${streamedResponse.statusCode}');
      
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('CloudinaryService: Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final url = responseData['secure_url'] as String?;
        debugPrint('CloudinaryService: Успешно! URL: $url');
        return url;
      } else {
        final errorData = json.decode(response.body);
        final errorMsg = errorData['error']?['message'] ?? 'Ошибка загрузки (${response.statusCode})';
        debugPrint('CloudinaryService: Ошибка: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('CloudinaryService: Exception: $e');
      rethrow;
    }
  }
  
  /// Загрузка изображения из PlatformFile
  static Future<String?> uploadImage(PlatformFile file) async {
    try {
      if (file.bytes == null) {
        throw Exception('Файл не содержит данных');
      }

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      
      request.fields['upload_preset'] = uploadPreset;
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          throw Exception('Превышено время ожидания загрузки');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['secure_url'] as String?;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error']?['message'] ?? 'Ошибка загрузки');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Загрузка изображения из bytes
  static Future<String?> uploadImageBytes(Uint8List bytes, String filename) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      
      request.fields['upload_preset'] = uploadPreset;
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          throw Exception('Превышено время ожидания загрузки');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['secure_url'] as String?;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error']?['message'] ?? 'Ошибка загрузки');
      }
    } catch (e) {
      rethrow;
    }
  }
}

