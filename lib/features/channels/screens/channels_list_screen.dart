import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
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
                  Icon(Icons.error_outline, color: limeGreen.withOpacity(0.6), size: 48),
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
                      heroTag: 'create_channel_fab_desktop',
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
                        color: blackColor,
                        size: 30,
                      ),
                    ),
                  )
                : null,
          );
        }

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              // Определяем количество колонок и соотношение сторон в зависимости от ширины экрана
              int crossAxisCount;
              double childAspectRatio;
              double horizontalPadding;
              
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 5;
                childAspectRatio = 0.65;
                horizontalPadding = 24;
              } else if (constraints.maxWidth > 900) {
                crossAxisCount = 4;
                childAspectRatio = 0.68;
                horizontalPadding = 20;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3;
                childAspectRatio = 0.7;
                horizontalPadding = 18;
              } else {
                // Мобильные устройства - 2 колонки, но больше и читабельнее
                crossAxisCount = 2;
                childAspectRatio = 0.75; // Немного выше для лучшей видимости
                horizontalPadding = 12;
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding, 
                      vertical: constraints.maxWidth <= 600 ? 16 : 20,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: constraints.maxWidth <= 600 ? 12 : 16,
                      mainAxisSpacing: constraints.maxWidth <= 600 ? 12 : 16,
                    ),
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
                      if (index >= channels.length || channels[index].id.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final channel = channels[index];
                      return _ChannelCard(
                        channel: channel,
                        isMobile: constraints.maxWidth <= 600,
                      );
                    },
                  ),
                ),
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
                    heroTag: 'create_channel_fab_mobile',
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
                      color: blackColor,
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
  final bool isMobile;

  const _ChannelCard({
    required this.channel,
    this.isMobile = false,
  });

  Widget _buildIconAction({
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    bool isMobile = false,
  }) {
    final size = isMobile ? 32.0 : 28.0;
    final iconSize = isMobile ? 18.0 : 16.0;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }

  void _deleteChannel(BuildContext context, WidgetRef ref) {
    final themeMode = ref.read(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? colors.cardColor : cardColorLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colors.accentColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.red[400], size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Удалить канал?',
                style: TextStyle(
                  color: isDark ? colors.cardTextColor : textColorLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Вы уверены, что хотите удалить этот канал? Это действие нельзя отменить. Канал можно удалить только если в нем нет постов.',
          style: TextStyle(
            color: isDark ? colors.cardTextColorSecondary : textColorSecondaryLight,
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
            child: Text(
              'Отмена',
              style: TextStyle(
                color: isDark ? colors.cardTextColorSecondary : textColorSecondaryLight,
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
              backgroundColor: Colors.red[500],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 2,
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);
    
    return Container(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.accentColor.withOpacity(isDark ? 0.35 : 0.5),
          width: isMobile ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.1),
            blurRadius: isMobile ? 8 : 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: colors.accentColor.withOpacity(isDark ? 0.08 : 0.12),
            blurRadius: isMobile ? 16 : 12,
            offset: const Offset(0, 0),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: limeGreen.withOpacity(0.15),
          highlightColor: limeGreen.withOpacity(0.08),
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
          child: Column(
            children: [
              // Верхняя часть с логотипом
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.cardColorDark,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(17),
                      topRight: Radius.circular(17),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(17),
                      topRight: Radius.circular(17),
                    ),
                    child: channel.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: channel.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: colors.accentColor,
                                strokeWidth: 3,
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Icons.rss_feed_rounded,
                                size: isMobile ? 80 : 64,
                                color: colors.greyColor.withOpacity(0.5),
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.rss_feed_rounded,
                              size: isMobile ? 80 : 64,
                              color: colors.greyColor.withOpacity(0.5),
                            ),
                          ),
                  ),
                ),
              ),
              
              // Нижняя часть с названием и описанием
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16 : 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.cardColorLight,
                      colors.cardColorDark,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(17),
                    bottomRight: Radius.circular(17),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: TextStyle(
                        color: colors.cardTextColor,
                        fontSize: isMobile ? 18 : 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 8 : 6),
                    Text(
                      channel.description,
                      style: TextStyle(
                        color: colors.cardTextColorSecondary,
                        fontSize: isMobile ? 14 : 13,
                        height: 1.4,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Кнопки действий для владельца
                    if (isOwner) ...[
                      SizedBox(height: isMobile ? 10 : 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                            iconColor: colors.accentColor,
                            backgroundColor: colors.accentColor.withOpacity(0.2),
                            isMobile: isMobile,
                          ),
                          SizedBox(width: isMobile ? 8 : 6),
                          _buildIconAction(
                            onTap: () => _deleteChannel(context, ref),
                            icon: Icons.delete_outline,
                            iconColor: Colors.red[400]!,
                            backgroundColor: Colors.red.withOpacity(0.2),
                            isMobile: isMobile,
                          ),
                        ],
                      ),
                    ],
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
