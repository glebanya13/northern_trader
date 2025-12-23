import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) {
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
      await ref.read(channelsControllerProvider).createPost(
        widget.channel.id,
        {
          'channelId': widget.channel.id,
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
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
              TextFormField(
                controller: _contentController,
                maxLines: 10,
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Содержание (HTML)',
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
                  hintText: 'Введите HTML-контент поста',
                  hintStyle: TextStyle(color: greyColor),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите содержание поста';
                  }
                  return null;
                },
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

