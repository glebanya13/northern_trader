import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/features/feed/repository/feed_repository.dart';
import 'package:northern_trader/models/feed_post.dart';

final feedControllerProvider = Provider<FeedController>((ref) {
  final feedRepository = ref.watch(feedRepositoryProvider);
  return FeedController(feedRepository: feedRepository);
});

final feedPostsProvider = StreamProvider<List<FeedPost>>((ref) {
  final feedController = ref.watch(feedControllerProvider);
  return feedController.getFeedPosts();
});

class FeedController {
  final FeedRepository feedRepository;

  FeedController({required this.feedRepository});

  Stream<List<FeedPost>> getFeedPosts({int limit = 50}) {
    return feedRepository.getFeedPosts(limit: limit);
  }

  Stream<List<FeedPost>> getAllPosts() {
    return feedRepository.getAllPosts();
  }
}

