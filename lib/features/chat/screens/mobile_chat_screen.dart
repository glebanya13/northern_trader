import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/common/widgets/loader.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';
import 'package:northern_trader/features/chat/widgets/bottom_chat_field.dart';
import 'package:northern_trader/features/chat/widgets/chat_list.dart';
import 'package:northern_trader/models/user_model.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final String profilePic;
  
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.profilePic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataAuthProvider);
    final isOwner = userData.value?.isOwner ?? false;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);
    
    return WillPopScope(
      onWillPop: () async {
        if (isOwner) {
          Navigator.pop(context);
        }
        return isOwner;
      },
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: colors.appBarColor,
          foregroundColor: colors.textColor,
          iconTheme: IconThemeData(color: colors.textColor),
          automaticallyImplyLeading: isOwner,
          leading: isOwner ? IconButton(
            icon: Icon(Icons.arrow_back, color: colors.textColor),
            onPressed: () => Navigator.pop(context),
          ) : null,
          title: StreamBuilder<UserModel>(
            stream: ref.read(authControllerProvider).userDataById(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOwner ? 'Чат' : name,
                    style: TextStyle(
                      color: colors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isOwner)
                    Text(
                      snapshot.data?.isOnline == true ? 'online' : 'offline',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: colors.greyColor,
                      ),
                    ),
                ],
              );
            },
          ),
          centerTitle: false,
        ),
        body: Container(
          color: colors.backgroundColor,
          child: Column(
            children: [
              Expanded(
                child: ChatList(
                  recieverUserId: uid,
                ),
              ),
              BottomChatField(
                recieverUserId: uid,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

