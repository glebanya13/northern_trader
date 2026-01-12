import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/common/widgets/loader.dart';
import 'package:northern_trader/features/channels/controller/channels_controller.dart';
import 'package:northern_trader/features/feed/controller/feed_controller.dart';
import 'package:northern_trader/features/feed/widgets/feed_post_card.dart';
import 'package:northern_trader/features/feed/screens/post_detail_screen.dart';

class AllPostsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/all-posts';
  
  const AllPostsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AllPostsScreen> createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends ConsumerState<AllPostsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final feedPostsAsync = ref.watch(feedPostsProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);

    return feedPostsAsync.when(
      data: (feedPosts) {
        return Scaffold(
          backgroundColor: colors.backgroundColor,
          appBar: AppBar(
            title: const Text('Все торговые идеи'),
            backgroundColor: colors.appBarColor,
            elevation: 0,
            iconTheme: IconThemeData(color: colors.textColor),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final crossAxisCount = availableWidth > 1200
                  ? 4
                  : availableWidth > 900
                      ? 3
                      : availableWidth > 600
                          ? 2
                          : 1;
              final childAspectRatio = availableWidth > 1200
                  ? 0.75
                  : availableWidth > 900
                      ? 0.8
                      : availableWidth > 600
                          ? 0.85
                          : 0.95;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
                      vertical: 12,
                    ),
                    child: feedPosts.isEmpty
                        ? Center(
                            child: Text(
                              'Нет постов',
                              style: TextStyle(
                                fontSize: 18,
                                color: colors.textColorSecondary,
                              ),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: feedPosts.length,
                            itemBuilder: (context, index) {
                              final feedPost = feedPosts[index];
                              return FeedPostCard(
                                post: feedPost.post,
                                channel: feedPost.channel,
                                onTap: () {
                                  ref
                                      .read(channelsControllerProvider)
                                      .incrementViews(
                                        feedPost.channel.id,
                                        feedPost.post.id,
                                      );
                                  Navigator.pushNamed(
                                    context,
                                    PostDetailScreen.routeName,
                                    arguments: {
                                      'post': feedPost.post,
                                      'channel': feedPost.channel,
                                    },
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.appBarColor,
                  colors.backgroundColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                // Возвращаемся на главную страницу при нажатии на любую вкладку
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              backgroundColor: Colors.transparent,
              selectedItemColor: colors.accentColorDark,
              unselectedItemColor: colors.greyColor,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
              ),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.accentColorDark.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.dynamic_feed_rounded,
                      size: 26,
                    ),
                  ),
                  label: 'Посты',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      size: 26,
                    ),
                  ),
                  label: 'Обзоры',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.rss_feed_outlined,
                      size: 26,
                    ),
                  ),
                  label: 'Каналы',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.chat_outlined,
                      size: 26,
                    ),
                  ),
                  label: 'Чат',
                ),
              ],
            ),
          ),
        );
      },
      loading: () {
        return Scaffold(
          backgroundColor: colors.backgroundColor,
          appBar: AppBar(
            title: const Text('Все торговые идеи'),
            backgroundColor: colors.appBarColor,
            elevation: 0,
            iconTheme: IconThemeData(color: colors.textColor),
          ),
          body: const Loader(),
        );
      },
      error: (error, stackTrace) {
        return Scaffold(
          backgroundColor: colors.backgroundColor,
          appBar: AppBar(
            title: const Text('Все торговые идеи'),
            backgroundColor: colors.appBarColor,
            elevation: 0,
            iconTheme: IconThemeData(color: colors.textColor),
          ),
          body: Center(
            child: Text(
              'Ошибка загрузки: $error',
              style: TextStyle(color: colors.textColor),
            ),
          ),
        );
      },
    );
  }
}

