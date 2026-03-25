import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/common/repositories/common_firebase_storage_repository.dart';
import 'package:northern_trader/common/services/cloudinary_service.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/features/channels/controller/channels_controller.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';

class CreateChannelScreen extends ConsumerStatefulWidget {
  const CreateChannelScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends ConsumerState<CreateChannelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        
        if (kIsWeb && file.bytes == null) {
          throw Exception('Не удалось загрузить файл');
        }

        setState(() {
          _isUploadingImage = true;
        });

        String? imageUrl;
        
        if (kIsWeb) {
          imageUrl = await CloudinaryService.uploadImage(file);
        } else {
          final userData = ref.read(userDataAuthProvider).value;
          if (userData == null) {
            throw Exception('Пользователь не авторизован');
          }
          final imageId = const Uuid().v4();
          final storageRef = 'channels/images/${userData.uid}/$imageId';
          final dartFile = File(file.path!);
          imageUrl = await ref
              .read(commonFirebaseStorageRepositoryProvider)
              .storeFileToFirebase(storageRef, dartFile);
        }

        if (imageUrl == null) {
          throw Exception('Не удалось получить URL изображения');
        }

        setState(() {
          _imageUrlController.text = imageUrl!;
          _isUploadingImage = false;
        });

        if (mounted) {
          showSnackBar(context: context, content: 'Изображение загружено');
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        showSnackBar(context: context, content: 'Ошибка загрузки: $e');
      }
    }
  }

  Future<void> _createChannel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(channelsControllerProvider).createChannel({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim().isEmpty ? '' : _imageUrlController.text.trim(),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'isActive': true,
      });
      
      if (mounted) {
        Navigator.pop(context);
        showSnackBar(context: context, content: 'Канал создан');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context: context, content: 'Ошибка: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.appBarColor,
        elevation: 0,
        title: Text(
          'Создать канал',
          style: TextStyle(color: colors.textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: colors.textColor),
      ),
      backgroundColor: colors.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: colors.textColor),
                decoration: InputDecoration(
                  labelText: 'Название канала',
                  labelStyle: TextStyle(color: colors.greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.accentColor, width: 2),
                  ),
                  fillColor: colors.inputFieldColor,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название канала';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                style: TextStyle(color: colors.textColor),
                decoration: InputDecoration(
                  labelText: 'Описание',
                  labelStyle: TextStyle(color: colors.greyColor),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.accentColor, width: 2),
                  ),
                  fillColor: colors.inputFieldColor,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите описание канала';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Изображение канала',
                style: TextStyle(
                  color: colors.greyColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _imageUrlController,
                      style: TextStyle(color: colors.textColor),
                      decoration: InputDecoration(
                        labelText: 'URL изображения',
                        labelStyle: TextStyle(color: colors.greyColor),
                        hintText: 'https://example.com/image.jpg',
                        hintStyle: TextStyle(color: colors.greyColor.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.accentColor, width: 2),
                        ),
                        fillColor: colors.inputFieldColor,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _isUploadingImage
                      ? Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: _pickImageFile,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate,
                              color: Colors.green,
                              size: 32,
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Загрузите изображение с ПК или вставьте URL',
                style: TextStyle(
                  color: colors.greyColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _isLoading ? colors.greyColor.withOpacity(0.5) : null,
                  gradient: _isLoading ? null : LinearGradient(
                    colors: [
                      colors.accentColor,
                      colors.accentColorDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: _isLoading ? null : [
                    BoxShadow(
                      color: colors.accentColor.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createChannel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.transparent,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(colors.textColor),
                          ),
                        )
                      : Text(
                          'Создать канал',
                          style: TextStyle(
                            color: isDark ? textColorDark : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

