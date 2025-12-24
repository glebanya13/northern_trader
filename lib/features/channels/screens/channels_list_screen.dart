import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/common/widgets/loader.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';
import 'package:northern_trader/features/channels/controller/channels_controller.dart';
import 'package:northern_trader/features/channels/screens/channel_posts_screen.dart';
import 'package:northern_trader/features/channels/screens/create_channel_screen.dart';
import 'package:northern_trader/features/channels/screens/edit_channel_screen.dart';
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
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          limeGreen,
                          limeGreenDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: limeGreen.withOpacity(0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateChannelScreen(),
                          ),
                        );
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  )
                : null,
          );
        }

        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              if (index >= channels.length || channels[index].id.isEmpty) {
                return const SizedBox.shrink();
              }
              final channel = channels[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ChannelCard(channel: channel),
              );
            },
          ),
          floatingActionButton: isOwner
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        limeGreen,
                        limeGreenDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: limeGreen.withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateChannelScreen(),
                        ),
                      );
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _ChannelCard extends ConsumerWidget {
  final Channel channel;

  const _ChannelCard({required this.channel});

  Widget _buildIconAction({
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: dividerColor.withOpacity(0.35),
              width: 1,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }

  void _deleteChannel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.red[300], size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Удалить канал?',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Вы уверены, что хотите удалить этот канал? Это действие нельзя отменить. Канал можно удалить только если в нем нет постов.',
          style: TextStyle(
            color: textColorSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Отмена',
              style: TextStyle(
                color: greyColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (channel.id.isEmpty) {
                showSnackBar(context: context, content: 'Ошибка: ID канала пустой');
                Navigator.pop(context);
                return;
              }
              try {
                await ref.read(channelsControllerProvider).deleteChannel(channel.id);
                Navigator.pop(context);
                showSnackBar(context: context, content: 'Канал удален');
              } catch (e) {
                Navigator.pop(context);
                showSnackBar(context: context, content: 'Ошибка: ${e.toString()}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[300],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Удалить',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataAuthProvider);
    final isOwner = userData.value?.isOwner ?? false;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            cardColorLight.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: limeGreen.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: dividerColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        limeGreen.withOpacity(0.3),
                        limeGreen.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: limeGreen.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: limeGreen.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: channel.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: channel.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: appBarColor,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: limeGreen,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    appBarColor,
                                    cardColor,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.rss_feed_rounded,
                                size: 34,
                                color: limeGreen,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  appBarColor,
                                  cardColor,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.rss_feed_rounded,
                              size: 34,
                              color: limeGreen,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        channel.description,
                        style: const TextStyle(
                          color: textColorSecondary,
                          fontSize: 14,
                          height: 1.4,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isOwner)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconAction(
                        onTap: () {
                          if (channel.id.isEmpty) {
                            showSnackBar(context: context, content: 'Ошибка: ID канала пустой');
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditChannelScreen(channel: channel),
                            ),
                          );
                        },
                        icon: Icons.edit_outlined,
                        iconColor: limeGreen,
                        gradientColors: [
                          limeGreen.withOpacity(0.18),
                          limeGreen.withOpacity(0.06),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildIconAction(
                        onTap: () => _deleteChannel(context, ref),
                        icon: Icons.delete_outline,
                        iconColor: Colors.red[400]!,
                        gradientColors: [
                          Colors.red.withOpacity(0.18),
                          Colors.red.withOpacity(0.06),
                        ],
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: limeGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: limeGreen,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
