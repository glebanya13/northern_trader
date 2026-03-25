import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart' as delta;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/common/repositories/common_firebase_storage_repository.dart';
import 'package:northern_trader/common/services/cloudinary_service.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/features/channels/controller/channels_controller.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';
import 'package:northern_trader/features/reviews/repository/reviews_repository.dart';
import 'package:northern_trader/models/channel.dart';
import 'package:northern_trader/models/channel_post.dart';
import 'package:northern_trader/models/review.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final Channel channel;
  final ChannelPost post;
  
  const EditPostScreen({
    Key? key,
    required this.channel,
    required this.post,
  }) : super(key: key);

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final quill.QuillController _quillController;
  late final TextEditingController _imageUrlController;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  bool _showEmojiPicker = false;
  final FocusNode _editorFocusNode = FocusNode();
  late bool _showInFeed; // Флаг для показа в ленте
  bool _duplicateToReviews = false; // Дублировать в обзоры
  String _selectedCategory = 'market'; // Категория для обзора
  Review? _existingReview; // Существующий обзор (если есть)

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _imageUrlController = TextEditingController(text: widget.post.imageUrl ?? '');
    _showInFeed = widget.post.showInFeed; // Инициализируем из существующего поста
    
    // Проверяем, есть ли связанный обзор
    _checkExistingReview();
    
    // Инициализируем Quill контроллер с существующим контентом
    if (widget.post.contentType == 'quill') {
      try {
        final deltaJson = jsonDecode(widget.post.content) as List;
        final document = quill.Document.fromJson(deltaJson);
        _quillController = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Если ошибка при загрузке, создаем документ с текстом
        _quillController = quill.QuillController.basic();
        final text = widget.post.content;
        if (text.isNotEmpty) {
          _quillController.document.compose(
            delta.Delta()..insert(text),
            quill.ChangeSource.local,
          );
        }
      }
    } else {
      // Для markdown создаем документ с текстом
      _quillController = quill.QuillController.basic();
      final text = widget.post.content;
      if (text.isNotEmpty) {
        _quillController.document.compose(
          delta.Delta()..insert(text),
          quill.ChangeSource.local,
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _imageUrlController.dispose();
    _editorFocusNode.dispose();
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
          final storageRef = 'posts/images/${userData.uid}/$imageId';
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

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final plainText = _quillController.document.toPlainText().trim();
    if (plainText.isEmpty) {
      showSnackBar(context: context, content: 'Введите содержание поста');
      return;
    }

    if (widget.channel.id.isEmpty || widget.post.id.isEmpty) {
      showSnackBar(context: context, content: 'Ошибка: ID канала или поста пустой');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final deltaJson = jsonEncode(_quillController.document.toDelta().toJson());
      
      // Обновляем пост
      await ref.read(channelsControllerProvider).updatePost(
        widget.channel.id,
        widget.post.id,
        {
          'title': _titleController.text.trim(),
          'content': deltaJson,
          'contentType': 'quill',
          'imageUrl': _imageUrlController.text.trim().isEmpty 
              ? null 
              : _imageUrlController.text.trim(),
          'showInFeed': _showInFeed,
        },
      );
      
      // Обработка обзора
      if (_duplicateToReviews) {
        final user = await ref.read(authControllerProvider).getUserData();
        if (user != null) {
          if (_existingReview != null) {
            // Обновляем существующий обзор
            final updatedReview = _existingReview!.copyWith(
              title: _titleController.text.trim(),
              content: deltaJson,
              contentType: 'quill',
              imageUrl: _imageUrlController.text.trim().isEmpty 
                  ? null 
                  : _imageUrlController.text.trim(),
              category: _selectedCategory,
            );
            await ref.read(reviewsRepositoryProvider).updateReview(updatedReview);
          } else {
            // Создаем новый обзор
            final review = Review(
              id: const Uuid().v4(),
              title: _titleController.text.trim(),
              content: deltaJson,
              contentType: 'quill',
              imageUrl: _imageUrlController.text.trim().isEmpty 
                  ? null 
                  : _imageUrlController.text.trim(),
              category: _selectedCategory,
              tags: [],
              createdAt: DateTime.now(),
              views: 0,
              authorId: user.uid,
              authorName: user.name,
              sourcePostId: widget.post.id,
              sourceChannelId: widget.channel.id,
            );
            await ref.read(reviewsRepositoryProvider).createReview(review);
          }
        }
      } else if (_existingReview != null) {
        // Если чекбокс выключен, но обзор существует - удаляем его
        await ref.read(reviewsRepositoryProvider).deleteReview(_existingReview!.id);
      }
      
      if (mounted) {
        Navigator.pop(context);
        showSnackBar(context: context, content: 'Пост обновлен');
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

  // Проверяем, существует ли обзор для этого поста
  Future<void> _checkExistingReview() async {
    try {
      final review = await ref
          .read(reviewsRepositoryProvider)
          .getReviewBySourcePost(widget.post.id);
      
      if (review != null && mounted) {
        setState(() {
          _existingReview = review;
          _duplicateToReviews = true;
          _selectedCategory = review.category;
        });
      }
    } catch (e) {
      // Игнорируем ошибки
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
          'Редактировать пост',
          style: TextStyle(color: colors.textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: colors.textColor),
        actions: [],
      ),
      backgroundColor: colors.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'Канал: ${widget.channel.name}',
                style: TextStyle(
                  color: colors.textColorSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: colors.textColor),
                decoration: InputDecoration(
                  labelText: 'Заголовок поста',
                  labelStyle: TextStyle(color: colors.greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.dividerColor, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.dividerColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.accentColor, width: 2.5),
                  ),
                  fillColor: colors.inputColor,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите заголовок поста';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Содержание',
                style: TextStyle(
                  color: colors.greyColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: colors.inputColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border(
                    top: BorderSide(color: colors.dividerColor, width: 1.5),
                    left: BorderSide(color: colors.dividerColor, width: 1.5),
                    right: BorderSide(color: colors.dividerColor, width: 1.5),
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
                      const SizedBox(width: 4),
                      Container(
                        width: 1,
                        height: 24,
                        color: colors.dividerColor,
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        color: _showEmojiPicker ? colors.accentColor : colors.greyColor,
                        onPressed: () {
                          setState(() {
                            _showEmojiPicker = !_showEmojiPicker;
                          });
                          if (_showEmojiPicker) {
                            _editorFocusNode.unfocus();
                          }
                        },
                        tooltip: 'Эмодзи',
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 1,
                        height: 24,
                        color: colors.dividerColor,
                      ),
                      const SizedBox(width: 4),
                      quill.QuillToolbarClearFormatButton(
                        controller: _quillController,
                        options: const quill.QuillToolbarClearFormatButtonOptions(
                          iconData: Icons.format_clear,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: colors.inputColor,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  border: Border.all(color: colors.dividerColor, width: 1.5),
                ),
                padding: const EdgeInsets.all(16),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textTheme: Theme.of(context).textTheme.copyWith(
                      bodyLarge: TextStyle(color: colors.richTextColor),
                      bodyMedium: TextStyle(color: colors.richTextColor),
                      bodySmall: TextStyle(color: colors.richTextColor),
                    ),
                  ),
                  child: quill.QuillEditor(
                    controller: _quillController,
                    focusNode: _editorFocusNode,
                    scrollController: ScrollController(),
                  ),
                ),
              ),
              if (_showEmojiPicker)
                Container(
                  height: 300,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colors.inputColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.dividerColor, width: 1.5),
                  ),
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      final selection = _quillController.selection;
                      final index = selection.baseOffset;
                      final length = selection.extentOffset - index;
                      
                      final insertDelta = delta.Delta()
                        ..retain(index)
                        ..delete(length)
                        ..insert(emoji.emoji);
                      
                      _quillController.document.compose(insertDelta, quill.ChangeSource.local);
                      
                      final newOffset = index + emoji.emoji.length;
                      _quillController.updateSelection(
                        TextSelection.collapsed(offset: newOffset),
                        quill.ChangeSource.local,
                      );
                    },
                    config: const Config(
                      height: 300,
                      checkPlatformCompatibility: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Изображение',
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
                          borderSide: BorderSide(color: colors.dividerColor, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.dividerColor, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.accentColor, width: 2.5),
                        ),
                        fillColor: colors.inputColor,
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
              // Чекбокс для выбора показа в ленте (только для админов)
              FutureBuilder(
                future: ref.read(authControllerProvider).getUserData(),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  if (user == null || !user.isOwner) {
                    return const SizedBox.shrink();
                  }
                  
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.inputColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.dividerColor,
                            width: 1.5,
                          ),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            'Показывать в общей ленте',
                            style: TextStyle(
                              color: colors.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            _showInFeed 
                                ? 'Пост будет виден во вкладке "Лента" и в канале'
                                : 'Пост будет виден только в этом канале',
                            style: TextStyle(
                              color: colors.textColorSecondary,
                              fontSize: 13,
                            ),
                          ),
                          value: _showInFeed,
                          activeColor: colors.accentColor,
                          checkColor: colors.isDark ? blackColor : whiteColor,
                          onChanged: (value) {
                            setState(() {
                              _showInFeed = value ?? true;
                            });
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                      // Чекбокс для дублирования в обзоры
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.inputColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.dividerColor,
                            width: 1.5,
                          ),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            'Дублировать в обзоры',
                            style: TextStyle(
                              color: colors.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            _duplicateToReviews 
                                ? _existingReview != null
                                    ? 'Обзор будет обновлен при сохранении'
                                    : 'Будет создан новый обзор'
                                : _existingReview != null
                                    ? 'Существующий обзор будет удален'
                                    : 'Пост не будет добавлен в раздел обзоров',
                            style: TextStyle(
                              color: colors.textColorSecondary,
                              fontSize: 13,
                            ),
                          ),
                          value: _duplicateToReviews,
                          activeColor: colors.accentColor,
                          checkColor: colors.isDark ? blackColor : whiteColor,
                          onChanged: (value) {
                            setState(() {
                              _duplicateToReviews = value ?? false;
                            });
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                      // Выбор категории обзора (показывается только если включено дублирование)
                      if (_duplicateToReviews) ...[
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: colors.inputColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.dividerColor,
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Категория обзора',
                                style: TextStyle(
                                  color: colors.greyColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                dropdownColor: colors.inputColor,
                                style: TextStyle(color: colors.textColor),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: colors.dividerColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: colors.dividerColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: colors.accentColor, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  fillColor: colors.backgroundColor,
                                  filled: true,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'market', child: Text('📊 Обзор рынка')),
                                  DropdownMenuItem(value: 'technical', child: Text('📈 Технический анализ')),
                                  DropdownMenuItem(value: 'fundamental', child: Text('📰 Фундаментальный анализ')),
                                  DropdownMenuItem(value: 'strategy', child: Text('🎯 Торговая стратегия')),
                                  DropdownMenuItem(value: 'education', child: Text('📚 Обучающий материал')),
                                  DropdownMenuItem(value: 'news', child: Text('⚡ Новости и события')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updatePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[700],
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(colors.isDark ? blackColor : whiteColor),
                        ),
                      )
                    : Text(
                        'Сохранить изменения',
                        style: TextStyle(
                          color: colors.isDark ? blackColor : whiteColor,
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

