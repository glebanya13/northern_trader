import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final commonFirebaseStorageRepositoryProvider = Provider(
  (ref) => CommonFirebaseStorageRepository(
    firebaseStorage: FirebaseStorage.instance,
  ),
);

class CommonFirebaseStorageRepository {
  final FirebaseStorage firebaseStorage;
  CommonFirebaseStorageRepository({
    required this.firebaseStorage,
  });

  Future<String> storeFileToFirebase(String ref, dynamic file) async {
    UploadTask uploadTask;
    
    if (kIsWeb) {
      Uint8List fileBytes;
      String? fileName;
      String? contentType;
      
      if (file is XFile) {
        fileBytes = await file.readAsBytes();
        fileName = file.name;
        contentType = _getContentType(ref, fileName);
      } else if (file is PlatformFile) {
        if (file.bytes == null) {
          throw Exception('Файл не содержит данных (bytes is null)');
        }
        fileBytes = file.bytes!;
        fileName = file.name;
        contentType = _getContentType(ref, fileName);
      } else {
        throw Exception('На веб-платформе требуется XFile или PlatformFile');
      }
      
      if (fileBytes.isEmpty) {
        throw Exception('Файл пустой');
      }
      
      uploadTask = firebaseStorage.ref().child(ref).putData(
        fileBytes,
        SettableMetadata(
          contentType: contentType ?? 'application/octet-stream',
          cacheControl: 'public, max-age=31536000',
        ),
      );
    } else {
      if (file is File) {
        uploadTask = firebaseStorage.ref().child(ref).putFile(
          file,
          SettableMetadata(
            contentType: _getContentType(ref, file.path),
            cacheControl: 'public, max-age=31536000',
          ),
        );
      } else {
        throw Exception('На мобильных платформах требуется File');
      }
    }
    
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
  
  String? _getContentType(String path, [String? fileName]) {
    String checkString = fileName ?? path;
    if (checkString.toLowerCase().endsWith('.jpg') || 
        checkString.toLowerCase().endsWith('.jpeg') ||
        checkString.contains('image')) {
      return 'image/jpeg';
    } else if (checkString.toLowerCase().endsWith('.png')) {
      return 'image/png';
    } else if (checkString.toLowerCase().endsWith('.gif')) {
      return 'image/gif';
    } else if (checkString.toLowerCase().endsWith('.mp4') ||
               (checkString.contains('video') && checkString.contains('mp4'))) {
      return 'video/mp4';
    } else if (checkString.toLowerCase().endsWith('.mov')) {
      return 'video/quicktime';
    } else if (checkString.toLowerCase().endsWith('.webm')) {
      return 'video/webm';
    } else if (checkString.contains('video')) {
      return 'video/mp4';
    } else if (checkString.toLowerCase().endsWith('.mp3') ||
               checkString.toLowerCase().endsWith('.aac') ||
               checkString.contains('audio')) {
      return 'audio/mpeg';
    } else if (checkString.toLowerCase().endsWith('.pdf')) {
      return 'application/pdf';
    } else if (checkString.toLowerCase().endsWith('.doc') ||
               checkString.toLowerCase().endsWith('.docx')) {
      return 'application/msword';
    }
    return null;
  }
}

