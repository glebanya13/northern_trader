import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/common/widgets/loader.dart';
import 'package:northern_trader/features/channels/controller/channels_controller.dart';
import 'package:northern_trader/features/channels/screens/channel_posts_screen.dart';
import 'package:northern_trader/models/channel.dart';

class ChannelsStoriesList extends ConsumerWidget {
  const ChannelsStoriesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsStream = ref.watch(channelsControllerProvider).getChannels();
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);

    return StreamBuilder<List<Channel>>(
      stream: channelsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(child: Loader()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final channels = snapshot.data!;

        if (channels.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 110,
          color: colors.backgroundColor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return _ChannelStoryItem(
                channel: channel,
                colors: colors,
              );
            },
          ),
        );
      },
    );
  }
}

class _ChannelStoryItem extends StatelessWidget {
  final Channel channel;
  final AppColors colors;

  const _ChannelStoryItem({
    required this.channel,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChannelPostsScreen(
                channel: channel,
              ),
            ),
          );
        },
        child: SizedBox(
          width: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Кружочек с градиентной рамкой
              Container(
                width: 70,
                height: 70,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      limeGreen,
                      limeGreenDark,
                      colors.accentColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: limeGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.backgroundColor,
                    border: Border.all(
                      color: colors.backgroundColor,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: channel.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: channel.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: colors.accentColor,
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: colors.cardColor,
                              child: Icon(
                                Icons.rss_feed_rounded,
                                size: 28,
                                color: colors.greyColor.withOpacity(0.6),
                              ),
                            ),
                          )
                        : Container(
                            color: colors.cardColor,
                            child: Icon(
                              Icons.rss_feed_rounded,
                              size: 28,
                              color: colors.greyColor.withOpacity(0.6),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Название канала
              Text(
                channel.name,
                style: TextStyle(
                  color: colors.textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
