import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/enums/message_enum.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';
import 'package:northern_trader/features/chat/repository/chat_repository.dart';
import 'package:northern_trader/models/chat_contact.dart';
import 'package:northern_trader/models/message.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;
  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContacts();
  }

  Stream<List<Message>> chatStream(String recieverUserId) {
    return chatRepository.getChatStream(recieverUserId);
  }

  void sendTextMessage(
    BuildContext context,
    String text,
    String recieverUserId,
  ) {
    ref.read(userDataAuthProvider).whenData(
          (value) {
            if (value != null) {
              chatRepository.sendTextMessage(
                context: context,
                text: text,
                recieverUserId: recieverUserId,
                senderUser: value,
              );
            } else {
              showSnackBar(context: context, content: 'User not authenticated');
            }
          },
        );
  }

  void sendFileMessage(
    BuildContext context,
    dynamic file, 
    String recieverUserId,
    MessageEnum messageEnum,
  ) {
    ref.read(userDataAuthProvider).whenData(
          (value) {
            if (value != null) {
              chatRepository.sendFileMessage(
                context: context,
                file: file,
                recieverUserId: recieverUserId,
                senderUserData: value,
                messageEnum: messageEnum,
                ref: ref,
              );
            } else {
              showSnackBar(context: context, content: 'User not authenticated');
            }
          },
        );
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) {
    chatRepository.setChatMessageSeen(
      context,
      recieverUserId,
      messageId,
    );
  }
}

