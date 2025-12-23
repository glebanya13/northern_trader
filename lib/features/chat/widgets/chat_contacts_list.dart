import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/widgets/loader.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';
import 'package:northern_trader/features/chat/controller/chat_controller.dart';
import 'package:northern_trader/features/chat/repository/chat_repository.dart';
import 'package:northern_trader/features/chat/screens/mobile_chat_screen.dart';
import 'package:northern_trader/models/chat_contact.dart';

class ChatContactsList extends ConsumerStatefulWidget {
  const ChatContactsList({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatContactsList> createState() => _ChatContactsListState();
}

class _ChatContactsListState extends ConsumerState<ChatContactsList> {
  String? ownerId;
  bool isLoadingOwner = true;

  @override
  void initState() {
    super.initState();
    _loadOwnerId();
  }

  Future<void> _loadOwnerId() async {
    final chatRepository = ref.read(chatRepositoryProvider);
    final owner = await chatRepository.getOwnerId();
    setState(() {
      ownerId = owner;
      isLoadingOwner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataAuthProvider);
    
    return userData.when(
      data: (user) {
        if (user == null) {
          return const Center(
            child: Text('Пожалуйста, войдите в систему'),
          );
        }

        if (user.isOwner) {
          return StreamBuilder<List<ChatContact>>(
            stream: ref.watch(chatControllerProvider).chatContacts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Ошибка: ${snapshot.error}',
                          style: const TextStyle(color: greyColor),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: greyColor),
                      SizedBox(height: 16),
                      Text(
                        'Нет чатов с пользователями',
                        style: TextStyle(color: greyColor, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  var chatContactData = snapshot.data![index];

                  return Card(
                    color: cardColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: dividerColor, width: 1),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MobileChatScreen(
                              name: chatContactData.name,
                              uid: chatContactData.contactId,
                              profilePic: chatContactData.profilePic,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: chatContactData.profilePic.isNotEmpty
                                  ? CachedNetworkImageProvider(chatContactData.profilePic)
                                  : null,
                              radius: 30,
                              child: chatContactData.profilePic.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chatContactData.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    chatContactData.lastMessage,
                                    style: const TextStyle(fontSize: 15, color: greyColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat.Hm().format(chatContactData.timeSent),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }

        if (isLoadingOwner) {
          return const Loader();
        }

        if (ownerId == null || ownerId!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: greyColor),
                SizedBox(height: 16),
                Text(
                  'Владелец не найден',
                  style: TextStyle(color: greyColor, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return FutureBuilder(
          future: ref.read(authControllerProvider).userDataById(ownerId!).first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text(
                  'Ошибка загрузки данных владельца',
                  style: TextStyle(color: greyColor),
                ),
              );
            }

            final ownerData = snapshot.data!;
            return MobileChatScreen(
              name: ownerData.name,
              uid: ownerId!,
              profilePic: ownerData.profilePic,
            );
          },
        );
      },
      loading: () => const Loader(),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Ошибка: $error',
                style: const TextStyle(color: greyColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
