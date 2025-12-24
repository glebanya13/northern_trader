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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemBuilder: (context, index) {
                  var chatContactData = snapshot.data![index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cardColor,
                          cardColorLight.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: limeGreen.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
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
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: dividerColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      limeGreen.withOpacity(0.3),
                                      limeGreen.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: limeGreen.withOpacity(0.4),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: limeGreen.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  backgroundImage: chatContactData.profilePic.isNotEmpty
                                      ? CachedNetworkImageProvider(chatContactData.profilePic)
                                      : null,
                                  backgroundColor: Colors.transparent,
                                  radius: 32,
                                  child: chatContactData.profilePic.isEmpty
                                      ? Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                appBarColor,
                                                cardColor,
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.person_rounded,
                                            color: limeGreen,
                                            size: 32,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chatContactData.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      chatContactData.lastMessage,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: greyColor,
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: limeGreen.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      DateFormat.Hm().format(chatContactData.timeSent),
                                      style: const TextStyle(
                                        color: limeGreen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: greyColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ],
                          ),
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
