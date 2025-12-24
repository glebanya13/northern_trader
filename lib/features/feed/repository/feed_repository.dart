import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/models/channel.dart';
import 'package:northern_trader/models/channel_post.dart';
import 'package:northern_trader/models/feed_post.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(firestore: FirebaseFirestore.instance);
});

class FeedRepository {
  final FirebaseFirestore firestore;

  FeedRepository({required this.firestore});

  Stream<List<FeedPost>> getAllPosts() {
    return firestore
        .collection('channels')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((channelsSnapshot) async {
      List<FeedPost> allPosts = [];

      for (var channelDoc in channelsSnapshot.docs) {
        try {
          final channel = Channel.fromMap(channelDoc.data());
          
          final postsSnapshot = await firestore
              .collection('channels')
              .doc(channelDoc.id)
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .get();

          for (var postDoc in postsSnapshot.docs) {
            try {
              final post = ChannelPost.fromMap(postDoc.data());
              allPosts.add(FeedPost(post: post, channel: channel));
            } catch (e) {
            }
          }
        } catch (e) {
        }
      }

      allPosts.sort((a, b) => b.post.createdAt.compareTo(a.post.createdAt));
      
      return allPosts;
    });
  }

  Stream<List<FeedPost>> getFeedPosts({int limit = 50}) {
    return firestore
        .collection('channels')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((channelsSnapshot) async {
      List<FeedPost> allPosts = [];

      for (var channelDoc in channelsSnapshot.docs) {
        try {
          final channel = Channel.fromMap(channelDoc.data());
          
          final postsSnapshot = await firestore
              .collection('channels')
              .doc(channelDoc.id)
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .limit(20)
              .get();

          for (var postDoc in postsSnapshot.docs) {
            try {
              final post = ChannelPost.fromMap(postDoc.data());
              allPosts.add(FeedPost(post: post, channel: channel));
            } catch (e) {
            }
          }
        } catch (e) {
        }
      }

      allPosts.sort((a, b) => b.post.createdAt.compareTo(a.post.createdAt));
      
      return allPosts.take(limit).toList();
    });
  }
}

