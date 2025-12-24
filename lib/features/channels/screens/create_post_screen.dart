import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/features/channels/controller/channels_controller.dart';
import 'package:northern_trader/models/channel.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final Channel channel;
  
  const CreatePostScreen({
    Key? key,
    required this.channel,
  }) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late final quill.QuillController _quillController;
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;
  final FocusNode _editorFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _imageUrlController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final plainText = _quillController.document.toPlainText().trim();
    if (plainText.isEmpty) {
      showSnackBar(context: context, content: 'Введите содержание поста');
      return;
    }

    if (widget.channel.id.isEmpty) {
      showSnackBar(context: context, content: 'Ошибка: ID канала пустой');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final deltaJson = jsonEncode(_quillController.document.toDelta().toJson());
      
      await ref.read(channelsControllerProvider).createPost(
        widget.channel.id,
        {
          'channelId': widget.channel.id,
          'title': _titleController.text.trim(),
          'content': deltaJson,
          'contentType': 'quill', // Указываем тип контента
          'imageUrl': _imageUrlController.text.trim().isEmpty 
              ? null 
              : _imageUrlController.text.trim(),
          'videoUrl': null,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'views': 0,
        },
      );
      
      if (mounted) {
        Navigator.pop(context);
        showSnackBar(context: context, content: 'Пост создан');
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: const Text(
          'Создать пост',
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
              Text(
                'Канал: ${widget.channel.name}',
                style: const TextStyle(
                  color: textColorSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Заголовок поста',
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
                    return 'Введите заголовок поста';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Содержание',
                style: TextStyle(
                  color: greyColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border(
                    top: BorderSide(color: dividerColor),
                    left: BorderSide(color: dividerColor),
                    right: BorderSide(color: dividerColor),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Theme(
                  data: ThemeData.dark().copyWith(
                    iconTheme: const IconThemeData(color: greyColor),
                    colorScheme: ColorScheme.dark(
                      primary: limeGreen,
                      secondary: limeGreen,
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
                        color: dividerColor,
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
                        color: dividerColor,
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
                        color: dividerColor,
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
                  color: cardColor,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  border: Border.all(color: dividerColor),
                ),
                padding: const EdgeInsets.all(16),
                child: quill.QuillEditor(
                  controller: _quillController,
                  focusNode: _editorFocusNode,
                  scrollController: ScrollController(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _imageUrlController,
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'URL изображения (необязательно)',
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
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _createPost,
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
                        'Создать пост',
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

