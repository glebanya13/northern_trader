import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/models/channel.dart';
import 'package:northern_trader/models/channel_post.dart';

final channelsRepositoryProvider = Provider(
  (ref) => ChannelsRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

class ChannelsRepository {
  final FirebaseFirestore firestore;

  ChannelsRepository({
    required this.firestore,
  });

  Stream<List<Channel>> getChannels() {
    return firestore
        .collection('channels')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<Channel> channels = event.docs
          .map((doc) => Channel.fromMap({
                ...doc.data(),
                'id': doc.id,
              }))
          .where((channel) => channel.id.isNotEmpty)
          .toList();
      channels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return channels;
    });
  }

  Stream<List<ChannelPost>> getChannelPosts(String channelId) {
    if (channelId.isEmpty) {
      return Stream.value([]);
    }
    return firestore
        .collection('channels')
        .doc(channelId)
        .collection('posts')
        .snapshots()
        .map((event) {
      List<ChannelPost> posts = event.docs
          .map((doc) => ChannelPost.fromMap({
                ...doc.data(),
                'id': doc.id,
                'channelId': channelId,
              }))
          .where((post) => post.id.isNotEmpty)
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  Future<ChannelPost?> getPost(String channelId, String postId) async {
    final doc = await firestore
        .collection('channels')
        .doc(channelId)
        .collection('posts')
        .doc(postId)
        .get();
    
    if (doc.exists && doc.data() != null) {
      return ChannelPost.fromMap({
        ...doc.data()!,
        'id': doc.id,
      });
    }
    return null;
  }

  Future<void> incrementViews(String channelId, String postId) async {
    if (channelId.isEmpty || postId.isEmpty) return;
    await firestore
        .collection('channels')
        .doc(channelId)
        .collection('posts')
        .doc(postId)
        .update({
      'views': FieldValue.increment(1),
    });
  }

  Future<void> updatePost(String channelId, String postId, Map<String, dynamic> data) async {
    if (channelId.isEmpty || postId.isEmpty) return;
    await firestore
        .collection('channels')
        .doc(channelId)
        .collection('posts')
        .doc(postId)
        .update(data);
  }

  Future<void> deletePost(String channelId, String postId) async {
    if (channelId.isEmpty || postId.isEmpty) return;
    await firestore
        .collection('channels')
        .doc(channelId)
        .collection('posts')
        .doc(postId)
        .delete();
  }

  Future<void> createPost(String channelId, Map<String, dynamic> data) async {
    if (channelId.isEmpty) return;
    final docRef = await firestore
        .collection('channels')
        .doc(channelId)
        .collection('posts')
        .add(data);
    await docRef.update({'id': docRef.id});
  }

  Future<void> createChannel(Map<String, dynamic> data) async {
    final docRef = await firestore.collection('channels').add(data);
    await docRef.update({'id': docRef.id});
  }
}

