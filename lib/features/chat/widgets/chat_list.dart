import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:northern_trader/common/enums/message_enum.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/widgets/loader.dart';
import 'package:northern_trader/features/chat/controller/chat_controller.dart';
import 'package:northern_trader/features/chat/repository/chat_repository.dart';
import 'package:northern_trader/features/chat/widgets/my_message_card.dart';
import 'package:northern_trader/features/chat/widgets/sender_message_card.dart';
import 'package:northern_trader/models/message.dart';

class ChatList extends ConsumerStatefulWidget {
  final String recieverUserId;
  
  const ChatList({
    Key? key,
    required this.recieverUserId,
  }) : super(key: key);

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: ref.read(chatControllerProvider).chatStream(widget.recieverUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Нет сообщений. Начните общение!',
              style: const TextStyle(color: greyColor),
            ),
          );
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (messageController.hasClients) {
            messageController.jumpTo(messageController.position.maxScrollExtent);
          }
        });

        return ListView.builder(
          controller: messageController,
          itemCount: snapshot.data!.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final messageData = snapshot.data![index];
            var timeSent = DateFormat.Hm().format(messageData.timeSent);

            String? currentUserId = ref.read(chatRepositoryProvider).getCurrentUserId();
            
            if (currentUserId != null &&
                !messageData.isSeen &&
                messageData.recieverid == currentUserId) {
              ref.read(chatControllerProvider).setChatMessageSeen(
                    context,
                    widget.recieverUserId,
                    messageData.messageId,
                  );
            }
            
            if (currentUserId != null &&
                messageData.senderId == currentUserId) {
              return MyMessageCard(
                message: messageData.text,
                date: timeSent,
                type: messageData.type,
              );
            }
            
            return SenderMessageCard(
              message: messageData.text,
              date: timeSent,
              type: messageData.type,
            );
          },
        );
      },
    );
  }
}

