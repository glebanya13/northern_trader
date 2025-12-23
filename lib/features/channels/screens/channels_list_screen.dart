import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/widgets/loader.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';
import 'package:northern_trader/features/channels/controller/channels_controller.dart';
import 'package:northern_trader/features/channels/screens/channel_posts_screen.dart';
import 'package:northern_trader/features/channels/screens/create_channel_screen.dart';
import 'package:northern_trader/models/channel.dart';

class ChannelsListScreen extends ConsumerStatefulWidget {
  const ChannelsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChannelsListScreen> createState() => _ChannelsListScreenState();
}

class _ChannelsListScreenState extends ConsumerState<ChannelsListScreen> {

  @override
  Widget build(BuildContext context) {
    final channelsStream = ref.watch(channelsControllerProvider).getChannels();
    final userData = ref.watch(userDataAuthProvider);
    final isOwner = userData.value?.isOwner ?? false;

    return StreamBuilder<List<Channel>>(
      stream: channelsStream,
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

        final channels = snapshot.data ?? [];

        if (channels.isEmpty) {
          return Scaffold(
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rss_feed, size: 64, color: greyColor),
                  SizedBox(height: 16),
                  Text(
                    'Пока нет каналов',
                    style: TextStyle(color: greyColor, fontSize: 16),
                  ),
                ],
              ),
            ),
            floatingActionButton: isOwner
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateChannelScreen(),
                        ),
                      );
                    },
                    backgroundColor: limeGreen,
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                : null,
          );
        }

        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              if (index >= channels.length || channels[index].id.isEmpty) {
                return const SizedBox.shrink();
              }
              final channel = channels[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChannelCard(channel: channel),
              );
            },
          ),
          floatingActionButton: isOwner
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateChannelScreen(),
                      ),
                    );
                  },
                  backgroundColor: limeGreen,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        );
      },
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final Channel channel;

  const _ChannelCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (channel.id.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChannelPostsScreen(
                  channel: channel,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: channel.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: channel.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.white,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: limeGreen,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white,
                            child: Icon(
                              Icons.rss_feed,
                              size: 30,
                              color: Colors.grey[400],
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.white,
                          child: Icon(
                            Icons.rss_feed,
                            size: 30,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      channel.name,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channel.description,
                      style: const TextStyle(
                        color: textColorSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
