import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/enums/message_enum.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/features/chat/controller/chat_controller.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String recieverUserId;
  
  const BottomChatField({
    Key? key,
    required this.recieverUserId,
  }) : super(key: key);

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _SelectedFile {
  final dynamic file;
  final MessageEnum type;
  
  _SelectedFile(this.file, this.type);
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();
  bool isShowEmojiContainer = false;
  FocusNode focusNode = FocusNode();
  List<_SelectedFile> _selectedFiles = [];

  void sendTextMessage() {
    String message = _messageController.text.trim();
    
    if (_selectedFiles.isNotEmpty) {
      _sendSelectedFiles();
      if (message.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          ref.read(chatControllerProvider).sendTextMessage(
                context,
                message,
                widget.recieverUserId,
              );
        });
        setState(() {
          _messageController.text = '';
        });
      }
      return;
    }
    
    if (message.isNotEmpty) {
      ref.read(chatControllerProvider).sendTextMessage(
            context,
            message,
            widget.recieverUserId,
          );
      setState(() {
        _messageController.text = '';
        isShowSendButton = false;
      });
    }
  }

  void sendFileMessage(
    dynamic file,
    MessageEnum messageEnum,
  ) {
    ref.read(chatControllerProvider).sendFileMessage(
          context,
          file,
          widget.recieverUserId,
          messageEnum,
        );
  }

  void selectImage() async {
    dynamic image = await pickImageFromGallery(context);
    if (image != null) {
      setState(() {
        _selectedFiles.add(_SelectedFile(image, MessageEnum.image));
        isShowSendButton = true;
      });
    }
  }

  void selectFile() async {
    dynamic file = await pickFileFromDevice(context);
    if (file != null) {
      setState(() {
        _selectedFiles.add(_SelectedFile(file, MessageEnum.file));
        isShowSendButton = true;
      });
    }
  }

  void _clearSelectedFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      if (_selectedFiles.isEmpty && _messageController.text.trim().isEmpty) {
        isShowSendButton = false;
      }
    });
  }

  void _clearAllSelectedFiles() {
    setState(() {
      _selectedFiles.clear();
      if (_messageController.text.trim().isEmpty) {
        isShowSendButton = false;
      }
    });
  }

  void _sendSelectedFiles() {
    if (_selectedFiles.isEmpty) return;
    
    final filesToSend = List<_SelectedFile>.from(_selectedFiles);
    _clearAllSelectedFiles();
    
    for (int i = 0; i < filesToSend.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        sendFileMessage(filesToSend[i].file, filesToSend[i].type);
      });
    }
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  String _getFileName(dynamic file) {
    if (file == null) return 'Файл';
    try {
      String fullName;
      if (kIsWeb) {
        if (file is PlatformFile) {
          fullName = file.name;
        } else {
          fullName = (file as dynamic).name ?? 'Файл';
        }
      } else {
        fullName = (file as File).path.split('/').last;
      }
      
      int lastDot = fullName.lastIndexOf('.');
      String name = lastDot > 0 ? fullName.substring(0, lastDot) : fullName;
      String extension = lastDot > 0 ? fullName.substring(lastDot) : '';
      
      if (name.length <= 5) {
        return fullName;
      } else {
        return '${name.substring(0, 5)}...$extension';
      }
    } catch (e) {
      return 'Файл';
    }
  }
  
  IconData _getFileIcon(MessageEnum type) {
    switch (type) {
      case MessageEnum.image:
        return Icons.image;
      case MessageEnum.video:
        return Icons.video_file;
      case MessageEnum.file:
        return Icons.insert_drive_file;
      default:
        return Icons.attach_file;
    }
  }

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedFiles.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            height: 56,
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _selectedFiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final selectedFile = entry.value;
                  return Container(
                    width: 150,
                    height: 48,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: mobileChatBoxColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getFileIcon(selectedFile.type),
                          color: limeGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _getFileName(selectedFile.file),
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _clearSelectedFile(index),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                focusNode: focusNode,
                controller: _messageController,
                onChanged: (val) {
                  setState(() {
                    isShowSendButton = val.trim().isNotEmpty || _selectedFiles.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: mobileChatBoxColor,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: toggleEmojiKeyboardContainer,
                            icon: const Icon(
                              Icons.emoji_emotions,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: selectImage,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: selectFile,
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  hintText: 'Введите сообщение',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
                right: 2,
                left: 2,
              ),
              child: CircleAvatar(
                backgroundColor: limeGreen,
                radius: 20,
                child: IconButton(
                  onPressed: isShowSendButton ? sendTextMessage : null,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (isShowEmojiContainer)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                setState(() {
                  _messageController.text = _messageController.text + emoji.emoji;
                });
              },
            ),
          ),
      ],
    );
  }
}

