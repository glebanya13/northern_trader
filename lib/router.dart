import 'package:flutter/material.dart';
import 'package:northern_trader/common/widgets/error.dart';
import 'package:northern_trader/features/auth/screens/login_screen.dart';
import 'package:northern_trader/features/auth/screens/user_information_screen.dart';
import 'package:northern_trader/features/chat/screens/mobile_chat_screen.dart';
import 'package:northern_trader/features/feed/screens/post_detail_screen.dart';
import 'package:northern_trader/features/feed/screens/all_posts_screen.dart';
import 'package:northern_trader/features/reviews/screens/review_detail_screen.dart';
import 'package:northern_trader/features/reviews/screens/create_review_screen.dart';
import 'package:northern_trader/features/reviews/screens/edit_review_screen.dart';
import 'package:northern_trader/models/review.dart';

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
    case AllPostsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const AllPostsScreen(),
      );
    case ReviewDetailScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final review = arguments['review'] as Review;
      return MaterialPageRoute(
        builder: (context) => ReviewDetailScreen(
          review: review,
        ),
      );
    case CreateReviewScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const CreateReviewScreen(),
      );
    case EditReviewScreen.routeName:
      final review = settings.arguments as Review;
      return MaterialPageRoute(
        builder: (context) => EditReviewScreen(
          review: review,
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

