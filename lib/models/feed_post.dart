import 'package:northern_trader/models/channel.dart';
import 'package:northern_trader/models/channel_post.dart';

class FeedPost {
  final ChannelPost post;
  final Channel channel;

  FeedPost({
    required this.post,
    required this.channel,
  });
}

