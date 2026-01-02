import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/common/widgets/theme_toggle_button.dart';
import 'package:northern_trader/common/widgets/loader.dart';
import 'package:northern_trader/features/channels/controller/channels_controller.dart';
import 'package:northern_trader/features/feed/controller/feed_controller.dart';
import 'package:northern_trader/features/feed/widgets/feed_post_card.dart';
import 'package:northern_trader/features/feed/screens/post_detail_screen.dart';
import 'package:northern_trader/router.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedPostsAsync = ref.watch(feedPostsProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);

    return feedPostsAsync.when(
      data: (feedPosts) {
        final filteredPosts = _searchQuery.isEmpty
            ? feedPosts
            : feedPosts.where((feedPost) {
                return feedPost.post.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    feedPost.post.content
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    feedPost.channel.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
              }).toList();

        if (filteredPosts.isEmpty) {
          return CustomScrollView(
            slivers: [
              _buildHeader(context, colors),
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article,
                        size: 64,
                        color: colors.greyColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Пока нет постов в ленте'
                            : 'По вашему запросу ничего не найдено',
                        style: TextStyle(color: colors.greyColor, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(feedPostsProvider);
          },
          color: limeGreen,
          backgroundColor: colors.cardColor,
          child: CustomScrollView(
            slivers: [
              _buildHeader(context, colors),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
                        vertical: 12,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Учитываем ограниченную ширину для расчета количества колонок
                          final availableWidth = constraints.maxWidth;
                          final crossAxisCount = availableWidth > 1200
                              ? 3
                              : availableWidth > 600
                                  ? 2
                                  : 1;
                          final childAspectRatio = availableWidth > 1200
                              ? 1.0
                              : availableWidth > 600
                                  ? 1.05
                                  : 1.2;
                          
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: filteredPosts.length,
                            itemBuilder: (context, index) {
                              final feedPost = filteredPosts[index];
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
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () {
        final themeMode = ref.watch(themeProvider);
        final isDark = themeMode == ThemeMode.dark;
        final colors = AppColors(isDark);
        return CustomScrollView(
          slivers: [
            _buildHeader(context, colors),
            const SliverFillRemaining(
              child: Loader(),
            ),
          ],
        );
      },
      error: (error, stackTrace) {
        final themeMode = ref.watch(themeProvider);
        final isDark = themeMode == ThemeMode.dark;
        final colors = AppColors(isDark);
        return CustomScrollView(
          slivers: [
            _buildHeader(context, colors),
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          color: limeGreen.withOpacity(0.6), size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка: $error',
                        style: TextStyle(color: colors.greyColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppColors colors) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: 20,
        ),
        color: colors.backgroundColor,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Анализ рынков и обучающие материалы по торговле',
                        style: TextStyle(
                          color: colors.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      _buildSearchBar(context, colors),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Анализ рынков и обучающие материалы по торговле',
                          style: TextStyle(
                            color: colors.textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 400,
                        child: _buildSearchBar(context, colors),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppColors colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.hardEdge,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: colors.searchBarColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.accentColor.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.accentColor.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: 'Поиск',
            hintStyle: TextStyle(
              color: colors.textColorSecondary,
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: colors.accentColor,
              size: 22,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: colors.accentColor,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    iconSize: 20,
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            isDense: false,
            filled: false,
          ),
          style: TextStyle(
            color: colors.textColor,
            fontSize: 15,
            height: 1.2,
          ),
        ),
      ),
    ),
    );
  }
}
