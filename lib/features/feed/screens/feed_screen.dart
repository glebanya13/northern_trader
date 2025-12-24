import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
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

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 3;
    } else if (width > 600) {
      return 2;
    } else {
      return 1;
    }
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 0.75;
    } else if (width > 600) {
      return 0.8;
    } else {
      return 1.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedPostsAsync = ref.watch(feedPostsProvider);

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
              _buildHeader(context),
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article,
                        size: 64,
                        color: greyColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Пока нет постов в ленте'
                            : 'По вашему запросу ничего не найдено',
                        style: TextStyle(color: greyColor, fontSize: 16),
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
          backgroundColor: cardColor,
          child: CustomScrollView(
            slivers: [
              _buildHeader(context),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
                  vertical: 16,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                    childCount: filteredPosts.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => CustomScrollView(
        slivers: [
          _buildHeader(context),
          const SliverFillRemaining(
            child: Loader(),
          ),
        ],
      ),
      error: (error, stackTrace) => CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка: $error',
                      style: const TextStyle(color: greyColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: 20,
        ),
        color: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Анализ рынков и обучающие материалы по торговле',
                    style: TextStyle(
                      color: textColor,
                      fontSize: isMobile ? 20 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isMobile) const SizedBox(width: 24),
                if (!isMobile)
                  SizedBox(
                    width: 300,
                    child: _buildSearchBar(context),
                  ),
              ],
            ),
            if (isMobile) ...[
              const SizedBox(height: 16),
              _buildSearchBar(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Поиск',
          hintStyle: TextStyle(color: greyColor),
          prefixIcon: Icon(Icons.search, color: greyColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: greyColor),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: TextStyle(color: textColor),
      ),
    );
  }
}
