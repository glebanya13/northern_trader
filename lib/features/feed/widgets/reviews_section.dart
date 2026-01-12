import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/features/reviews/controller/reviews_controller.dart';
import 'package:northern_trader/features/reviews/widgets/review_card.dart';
import 'package:northern_trader/features/reviews/screens/review_detail_screen.dart';
import 'package:northern_trader/features/reviews/screens/reviews_screen.dart';
import 'package:northern_trader/mobile_layout_screen.dart';

class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(latestReviewsProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 24),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: colors.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.accentColorDark.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок секции
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.accentColorDark.withOpacity(0.2),
                            colors.accentColorDark.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.accentColorDark.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        color: colors.accentColorDark,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Обзоры рынка',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.cardTextColor,
                            ),
                          ),
                          Text(
                            'Аналитика и прогнозы',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.cardTextColorSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Переход на экран обзоров через навигацию
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ReviewsScreen(showBottomNav: true),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: colors.accentColorDark,
                      ),
                      label: Text(
                        'Все',
                        style: TextStyle(
                          color: colors.accentColorDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: colors.accentColorDark.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: colors.accentColorDark.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Горизонтальный список обзоров
              SizedBox(
                height: 320,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return SizedBox(
                      width: 300,
                      child: ReviewCard(
                        review: review,
                        compact: true,
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
