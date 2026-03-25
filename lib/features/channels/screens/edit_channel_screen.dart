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
import 'package:northern_trader/models/channel.dart';

class EditChannelScreen extends ConsumerStatefulWidget {
  final Channel channel;
  const EditChannelScreen({
    Key? key,
    required this.channel,
  }) : super(key: key);

  @override
  ConsumerState<EditChannelScreen> createState() => _EditChannelScreenState();
}

class _EditChannelScreenState extends ConsumerState<EditChannelScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.channel.name);
    _descriptionController = TextEditingController(text: widget.channel.description);
    _imageUrlController = TextEditingController(text: widget.channel.imageUrl);
  }

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.channel.id.isEmpty) {
      showSnackBar(context: context, content: 'Ошибка: ID канала пустой');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(channelsControllerProvider).updateChannel(widget.channel.id, {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim().isEmpty ? '' : _imageUrlController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        showSnackBar(context: context, content: 'Канал обновлён');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context: context, content: 'Ошибка: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: const Text(
          'Редактировать канал',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: textColor),
      ),
      backgroundColor: backgroundColor,
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
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Название канала',
                  labelStyle: const TextStyle(color: greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: limeGreen, width: 2),
                  ),
                  fillColor: cardColor,
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
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Описание',
                  labelStyle: const TextStyle(color: greyColor),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: limeGreen, width: 2),
                  ),
                  fillColor: cardColor,
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
              const Text(
                'Изображение канала',
                style: TextStyle(
                  color: greyColor,
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
                      style: const TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'URL изображения',
                        labelStyle: const TextStyle(color: greyColor),
                        hintText: 'https://example.com/image.jpg',
                        hintStyle: TextStyle(color: greyColor.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: limeGreen, width: 2),
                        ),
                        fillColor: cardColor,
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
                  color: greyColor.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: limeGreen,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[700],
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      )
                    : const Text(
                        'Сохранить',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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


