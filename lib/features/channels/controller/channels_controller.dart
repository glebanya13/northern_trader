import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/features/channels/repository/channels_repository.dart';
import 'package:northern_trader/models/channel.dart';
import 'package:northern_trader/models/channel_post.dart';

final channelsControllerProvider = Provider((ref) {
  final channelsRepository = ref.watch(channelsRepositoryProvider);
  return ChannelsController(
    channelsRepository: channelsRepository,
  );
});

class ChannelsController {
  final ChannelsRepository channelsRepository;

  ChannelsController({
    required this.channelsRepository,
  });

  Stream<List<Channel>> getChannels() {
    return channelsRepository.getChannels();
  }

  Stream<List<ChannelPost>> getChannelPosts(String channelId) {
    return channelsRepository.getChannelPosts(channelId);
  }

  Future<ChannelPost?> getPost(String channelId, String postId) async {
    return channelsRepository.getPost(channelId, postId);
  }

  Future<void> incrementViews(String channelId, String postId) async {
    return channelsRepository.incrementViews(channelId, postId);
  }

  Future<void> updatePost(String channelId, String postId, Map<String, dynamic> data) async {
    return channelsRepository.updatePost(channelId, postId, data);
  }

  Future<void> deletePost(String channelId, String postId) async {
    return channelsRepository.deletePost(channelId, postId);
  }

  Future<void> createPost(String channelId, Map<String, dynamic> data) async {
    return channelsRepository.createPost(channelId, data);
  }

  Future<void> createChannel(Map<String, dynamic> data) async {
    return channelsRepository.createChannel(data);
  }

  Future<void> updateChannel(String channelId, Map<String, dynamic> data) async {
    return channelsRepository.updateChannel(channelId, data);
  }

  Future<void> deleteChannel(String channelId) async {
    return channelsRepository.deleteChannel(channelId);
  }
}

