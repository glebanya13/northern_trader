import 'package:flutter/material.dart';
import 'package:northern_trader/common/widgets/error.dart';
import 'package:northern_trader/features/auth/screens/login_screen.dart';
import 'package:northern_trader/features/auth/screens/user_information_screen.dart';
import 'package:northern_trader/features/chat/screens/mobile_chat_screen.dart';
import 'package:northern_trader/features/feed/screens/post_detail_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case UserInformationScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const UserInformationScreen(),
      );
    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'] ?? '';
      final uid = arguments['uid'] ?? '';
      final profilePic = arguments['profilePic'] ?? '';
      return MaterialPageRoute(
        builder: (context) => MobileChatScreen(
          name: name,
          uid: uid,
          profilePic: profilePic,
        ),
      );
    case PostDetailScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final post = arguments['post'];
      final channel = arguments['channel'];
      return MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          post: post,
          channel: channel,
        ),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: ErrorScreen(error: 'This page doesn\'t exist'),
        ),
      );
  }
}

