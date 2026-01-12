import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:file_picker/file_picker.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/common/repositories/common_firebase_storage_repository.dart';
import 'package:northern_trader/common/services/cloudinary_service.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/features/reviews/controller/reviews_controller.dart';
import 'package:northern_trader/models/review.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';
import 'package:uuid/uuid.dart';

class CreateReviewScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-review';
  
  const CreateReviewScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends ConsumerState<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  late final quill.QuillController _quillController;
  final _editorFocusNode = FocusNode();
  
  String _selectedCategory = 'market';
  final List<String> _tags = [];
  final _tagController = TextEditingController();
  bool _isLoading = false;
  bool _isUploadingVideo = false;
  bool _isUploadingImage = false;

  final List<Map<String, String>> _categories = [
    {'id': 'market', 'name': 'Рыночный анализ'},
    {'id': 'technical', 'name': 'Технический анализ'},
    {'id': 'fundamental', 'name': 'Фундаментальный анализ'},
    {'id': 'crypto', 'name': 'Криптовалюты'},
    {'id': 'forex', 'name': 'Форекс'},
    {'id': 'stocks', 'name': 'Акции'},
  ];

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _videoUrlController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _tagController.dispose();
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
          // На веб используем Cloudinary
          imageUrl = await CloudinaryService.uploadImage(file);
        } else {
          // На мобильных используем Firebase Storage
          final userData = ref.read(userDataAuthProvider).value;
          if (userData == null) {
            throw Exception('Пользователь не авторизован');
          }
          final imageId = const Uuid().v4();
          final storageRef = 'reviews/images/${userData.uid}/$imageId';
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

  Future<void> _pickVideoFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'webm'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        
        // Проверяем наличие файла в зависимости от платформы
        if (kIsWeb && file.bytes == null) {
          throw Exception('Не удалось загрузить файл');
        }
        if (!kIsWeb && file.path == null) {
          throw Exception('Не удалось загрузить файл');
        }

        setState(() {
          _isUploadingVideo = true;
        });

        String? videoUrl;
        
        if (kIsWeb) {
          // На веб используем Cloudinary
          videoUrl = await CloudinaryService.uploadVideo(file);
        } else {
          // На мобильных используем Firebase Storage
          final userData = ref.read(userDataAuthProvider).value;
          if (userData == null) {
            throw Exception('Пользователь не авторизован');
          }
          final videoId = const Uuid().v4();
          final storageRef = 'reviews/videos/${userData.uid}/$videoId';
          final dartFile = File(file.path!);
          videoUrl = await ref
              .read(commonFirebaseStorageRepositoryProvider)
              .storeFileToFirebase(storageRef, dartFile);
        }

        if (videoUrl == null) {
          throw Exception('Не удалось получить URL видео');
        }

        setState(() {
          _videoUrlController.text = videoUrl!;
          _isUploadingVideo = false;
        });

        if (mounted) {
          showSnackBar(context: context, content: 'Видео успешно загружено');
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingVideo = false;
      });
      if (mounted) {
        showSnackBar(context: context, content: 'Ошибка загрузки видео: $e');
      }
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = ref.read(userDataAuthProvider).value;
      if (userData == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Получаем контент из Quill редактора
      final delta = _quillController.document.toDelta();
      final deltaJson = jsonEncode(delta.toJson());

      final review = Review(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        content: deltaJson,
        contentType: 'quill',
        imageUrl: _imageUrlController.text.trim().isEmpty 
            ? null 
            : _imageUrlController.text.trim(),
        videoUrl: _videoUrlController.text.trim().isEmpty 
            ? null 
            : _videoUrlController.text.trim(),
        category: _selectedCategory,
        tags: _tags,
        createdAt: DateTime.now(),
        views: 0,
        authorId: userData.uid,
        authorName: userData.name,
      );

      await ref.read(reviewsControllerProvider).createReview(review);

      if (mounted) {
        final themeMode = ref.read(themeProvider);
        final isDark = themeMode == ThemeMode.dark;
        final colors = AppColors(isDark);
        
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Обзор успешно создан'),
            backgroundColor: colors.accentColorDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.appBarColor,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Создать обзор',
          style: TextStyle(
            color: colors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.accentColorDark,
                  ),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveReview,
              icon: Icon(Icons.check, color: colors.accentColorDark),
              label: Text(
                'Сохранить',
                style: TextStyle(
                  color: colors.accentColorDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Заголовок
            TextFormField(
              controller: _titleController,
              style: TextStyle(color: colors.textColor),
              decoration: InputDecoration(
                labelText: 'Заголовок обзора',
                labelStyle: TextStyle(color: colors.greyColor),
                filled: true,
                fillColor: isDark ? colors.cardColor : colors.inputColor,
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
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите заголовок';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Категория
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              style: TextStyle(color: colors.textColor),
              dropdownColor: isDark ? colors.cardColor : Colors.white,
              decoration: InputDecoration(
                labelText: 'Категория',
                labelStyle: TextStyle(color: colors.greyColor),
                filled: true,
                fillColor: isDark ? colors.cardColor : colors.inputColor,
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
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat['id'],
                  child: Text(cat['name']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // URL изображения (превью для видео)
            Text(
              'Превью изображение',
              style: TextStyle(
                color: colors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
                      filled: true,
                      fillColor: isDark ? colors.cardColor : colors.inputColor,
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
              'Используется как превью для видео. Показывается только если видео отсутствует.',
              style: TextStyle(
                color: colors.greyColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),

            // Видео
            Text(
              'Видео',
              style: TextStyle(
                color: colors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _videoUrlController,
                    style: TextStyle(color: colors.textColor),
                    decoration: InputDecoration(
                      labelText: 'URL видео (YouTube, Vimeo)',
                      labelStyle: TextStyle(color: colors.greyColor),
                      hintText: 'https://youtube.com/watch?v=...',
                      hintStyle: TextStyle(color: colors.greyColor.withOpacity(0.6)),
                      filled: true,
                      fillColor: isDark ? colors.cardColor : colors.inputColor,
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
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _isUploadingVideo
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
                        onTap: _pickVideoFile,
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
                            Icons.video_library,
                            color: Colors.green,
                            size: 32,
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Или загрузите видео файл с вашего устройства (mp4, mov, webm)',
              style: TextStyle(
                color: colors.greyColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),

            // Теги
            Text(
              'Теги',
              style: TextStyle(
                color: colors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    style: TextStyle(color: colors.textColor),
                    decoration: InputDecoration(
                      hintText: 'Введите тег',
                      hintStyle: TextStyle(color: colors.greyColor),
                      filled: true,
                      fillColor: isDark ? colors.cardColor : colors.inputColor,
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
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTag,
                  icon: Icon(Icons.add, color: colors.accentColorDark),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.accentColorDark.withOpacity(0.1),
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor: colors.accentColorDark.withOpacity(0.1),
                    labelStyle: TextStyle(color: colors.accentColorDark),
                    deleteIconColor: colors.accentColorDark,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),

            // Редактор контента
            Text(
              'Содержание',
              style: TextStyle(
                color: colors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Тулбар Quill
            Container(
              decoration: BoxDecoration(
                color: isDark ? colors.cardColor : colors.inputColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(
                  top: BorderSide(color: colors.dividerColor),
                  left: BorderSide(color: colors.dividerColor),
                  right: BorderSide(color: colors.dividerColor),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Theme(
                data: Theme.of(context).copyWith(
                  iconTheme: IconThemeData(color: colors.greyColor),
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: colors.accentColor,
                    secondary: colors.accentColor,
                  ),
                ),
                child: Row(
                  children: [
                    quill.QuillToolbarToggleStyleButton(
                      attribute: quill.Attribute.bold,
                      controller: _quillController,
                      options: const quill.QuillToolbarToggleStyleButtonOptions(
                        iconData: Icons.format_bold,
                      ),
                    ),
                    quill.QuillToolbarToggleStyleButton(
                      attribute: quill.Attribute.italic,
                      controller: _quillController,
                      options: const quill.QuillToolbarToggleStyleButtonOptions(
                        iconData: Icons.format_italic,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 1,
                      height: 24,
                      color: colors.dividerColor,
                    ),
                    const SizedBox(width: 4),
                    quill.QuillToolbarToggleStyleButton(
                      attribute: quill.Attribute.ul,
                      controller: _quillController,
                      options: const quill.QuillToolbarToggleStyleButtonOptions(
                        iconData: Icons.format_list_bulleted,
                      ),
                    ),
                    quill.QuillToolbarToggleStyleButton(
                      attribute: quill.Attribute.ol,
                      controller: _quillController,
                      options: const quill.QuillToolbarToggleStyleButtonOptions(
                        iconData: Icons.format_list_numbered,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 1,
                      height: 24,
                      color: colors.dividerColor,
                    ),
                    const SizedBox(width: 4),
                    quill.QuillToolbarToggleStyleButton(
                      attribute: quill.Attribute.blockQuote,
                      controller: _quillController,
                      options: const quill.QuillToolbarToggleStyleButtonOptions(
                        iconData: Icons.format_quote,
                      ),
                    ),
                    quill.QuillToolbarToggleStyleButton(
                      attribute: quill.Attribute.codeBlock,
                      controller: _quillController,
                      options: const quill.QuillToolbarToggleStyleButtonOptions(
                        iconData: Icons.code,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Редактор
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: isDark ? colors.cardColor : colors.inputColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border(
                  bottom: BorderSide(color: colors.dividerColor),
                  left: BorderSide(color: colors.dividerColor),
                  right: BorderSide(color: colors.dividerColor),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.copyWith(
                    bodyLarge: TextStyle(color: colors.textColor),
                    bodyMedium: TextStyle(color: colors.textColor),
                    bodySmall: TextStyle(color: colors.textColor),
                  ),
                ),
                child: quill.QuillEditor(
                  controller: _quillController,
                  focusNode: _editorFocusNode,
                  scrollController: ScrollController(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
