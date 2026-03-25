import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/common/widgets/loader.dart';
import 'package:northern_trader/features/reviews/controller/reviews_controller.dart';
import 'package:northern_trader/features/reviews/widgets/review_card.dart';
import 'package:northern_trader/features/reviews/screens/review_detail_screen.dart';
import 'package:northern_trader/features/reviews/screens/create_review_screen.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/reviews';
  final bool showBottomNav;
  
  const ReviewsScreen({Key? key, this.showBottomNav = false}) : super(key: key);

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 1; // Обзоры - вторая вкладка
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(allReviewsProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);
    final userData = ref.watch(userDataAuthProvider);
    final isOwner = userData.value?.isOwner ?? false;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: reviewsAsync.when(
      data: (reviews) {
        // Фильтрация по поиску
        var filteredReviews = reviews;

        if (_searchQuery.isNotEmpty) {
          filteredReviews = filteredReviews.where((review) {
            return review.title
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                review.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                review.authorName.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }

        if (filteredReviews.isEmpty) {
          return CustomScrollView(
            slivers: [
              _buildHeader(context, colors),
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: colors.greyColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Пока нет обзоров'
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
            ref.invalidate(allReviewsProvider);
          },
          color: colors.accentColorDark,
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
                          final availableWidth = constraints.maxWidth;
                          final crossAxisCount = availableWidth > 1200
                              ? 3
                              : availableWidth > 600
                                  ? 2
                                  : 1;
                          final childAspectRatio = availableWidth > 1200
                              ? 0.75
                              : availableWidth > 600
                                  ? 0.85
                                  : 0.95;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: filteredReviews.length,
                            itemBuilder: (context, index) {
                              final review = filteredReviews[index];
                              return ReviewCard(
                                review: review,
                                onTap: () {
                                  ref
                                      .read(reviewsControllerProvider)
                                      .incrementViews(review.id);
                                  Navigator.pushNamed(
                                    context,
                                    ReviewDetailScreen.routeName,
                                    arguments: {'review': review},
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
                          color: colors.accentColorDark.withOpacity(0.6), size: 48),
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
                heroTag: 'create_review_fab',
                onPressed: () {
                  Navigator.pushNamed(context, CreateReviewScreen.routeName);
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
      bottomNavigationBar: widget.showBottomNav ? Container(
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
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.dynamic_feed_outlined,
                  size: 26,
                ),
              ),
              label: 'Посты',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.accentColorDark.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
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
      ) : null,
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  limeGreen.withOpacity(0.2),
                                  limeGreen.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.analytics_rounded,
                              color: colors.accentColorDark,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Аналитические обзоры рынка',
                              style: TextStyle(
                                color: colors.textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSearchBar(context, colors),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.accentColorDark.withOpacity(0.2),
                              colors.accentColorDark.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.analytics_rounded,
                          color: colors.accentColorDark,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Аналитические обзоры рынка',
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
              hintText: 'Поиск обзоров',
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
