import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/features/channels/controller/channels_controller.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: const Text(
          'Создать канал',
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
                onPressed: _isLoading ? null : _createChannel,
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
                        'Создать канал',
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

