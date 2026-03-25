import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';
import 'package:northern_trader/features/reviews/controller/reviews_controller.dart';
import 'package:northern_trader/features/reviews/widgets/video_player_widget.dart';
import 'package:northern_trader/models/review.dart';

class ReviewDetailScreen extends ConsumerWidget {
  static const String routeName = '/review-detail';
  final Review review;

  const ReviewDetailScreen({
    Key? key,
    required this.review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Обзор',
          style: TextStyle(
            color: colors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Кнопки редактирования и удаления (только для админов)
          FutureBuilder(
            future: ref.read(authControllerProvider).getUserData(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user == null || !user.isOwner) {
                return const SizedBox.shrink();
              }
              
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: colors.accentColor),
                    onPressed: () => _showEditDialog(context, ref),
                    tooltip: 'Редактировать',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: isDark ? Colors.red[400] : Colors.red[600]),
                    onPressed: () => _showDeleteDialog(context, ref),
                    tooltip: 'Удалить',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Изображение обзора (только если нет видео)
                if ((review.videoUrl == null || review.videoUrl!.isEmpty) &&
                    review.imageUrl != null && review.imageUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: review.imageUrl!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 300,
                      color: colors.cardColorLight,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: colors.accentColorDark,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 300,
                      color: colors.cardColorLight,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: colors.greyColor,
                      ),
                    ),
                  ),
                // Видео обзора (если есть)
                if (review.videoUrl != null && review.videoUrl!.isNotEmpty) ...[
                  if (review.imageUrl != null && review.imageUrl!.isNotEmpty)
                    const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: VideoPlayerWidget(videoUrl: review.videoUrl!),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Тег и категория
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getCategoryColor(review.category)
                                      .withOpacity(0.25),
                                  _getCategoryColor(review.category)
                                      .withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getCategoryColor(review.category)
                                    .withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: 16,
                                  color: _getCategoryColor(review.category),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'ОБЗОР',
                                  style: TextStyle(
                                    color: _getCategoryColor(review.category),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colors.accentColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getCategoryName(review.category),
                              style: TextStyle(
                                color: colors.accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Заголовок
                      Text(
                        review.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colors.textColor,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Автор и дата
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colors.accentColorDark.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
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
                                  review.authorName,
                                  style: TextStyle(
                                    color: colors.textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatDate(review.createdAt),
                                  style: TextStyle(
                                    color: colors.greyColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? colors.cardColor : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 16,
                                  color: colors.accentColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${review.views}',
                                  style: TextStyle(
                                    color: colors.accentColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: colors.greyColor.withOpacity(0.2)),
                      const SizedBox(height: 24),
                      // Контент
                      _buildContent(context, colors),
                      const SizedBox(height: 32),
                      // Теги
                      if (review.tags.isNotEmpty) ...[
                        Text(
                          'Теги',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: review.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? colors.cardColor : Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colors.accentColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  color: colors.accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppColors colors) {
    if (review.contentType == 'quill') {
      try {
        final deltaJson = jsonDecode(review.content) as List;
        final document = quill.Document.fromJson(deltaJson);
        final controller = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: colors.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AbsorbPointer(
            absorbing: true,
            child: Builder(
              builder: (context) => Theme(
                data: Theme.of(context).copyWith(
                  scaffoldBackgroundColor: colors.backgroundColor,
                  textTheme: Theme.of(context).textTheme.copyWith(
                    bodyLarge: TextStyle(
                      color: colors.textColor,
                      fontSize: 16,
                      height: 1.6,
                    ),
                    bodyMedium: TextStyle(
                      color: colors.textColor,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: colors.textColor,
                    fontSize: 16,
                    height: 1.6,
                  ),
                  child: Container(
                    color: colors.backgroundColor,
                    child: quill.QuillEditor(
                      controller: controller,
                      focusNode: FocusNode(),
                      scrollController: ScrollController(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } catch (e) {
        return Text(
          'Ошибка при загрузке контента',
          style: TextStyle(color: colors.greyColor),
        );
      }
    } else {
      return MarkdownBody(
        data: review.content,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: colors.textColor,
          ),
          h1: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: colors.textColor,
          ),
          h2: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.textColor,
          ),
          h3: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.textColor,
          ),
          strong: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.textColor,
          ),
          em: TextStyle(
            fontStyle: FontStyle.italic,
            color: colors.textColor,
          ),
          code: TextStyle(
            backgroundColor: colors.cardColor,
            color: colors.cardTextColor,
            fontFamily: 'monospace',
          ),
          blockquote: TextStyle(
            color: colors.cardTextColorSecondary,
            fontStyle: FontStyle.italic,
          ),
          blockquoteDecoration: BoxDecoration(
            color: colors.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: colors.accentColorDark,
                width: 4,
              ),
            ),
          ),
          blockquotePadding: const EdgeInsets.all(12),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'market':
        return const Color(0xFF6366F1);
      case 'technical':
        return const Color(0xFF8B5CF6);
      case 'fundamental':
        return const Color(0xFF10B981);
      case 'crypto':
        return const Color(0xFFF59E0B);
      case 'forex':
        return const Color(0xFF3B82F6);
      case 'stocks':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF00D68F);
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'market':
        return 'Рыночный анализ';
      case 'technical':
        return 'Технический анализ';
      case 'fundamental':
        return 'Фундаментальный анализ';
      case 'crypto':
        return 'Криптовалюты';
      case 'forex':
        return 'Форекс';
      case 'stocks':
        return 'Акции';
      default:
        return 'Обзор';
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    Navigator.pushNamed(
      context,
      '/edit-review',
      arguments: review,
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? colors.cardColor : cardColorLight,
        title: Text(
          'Удалить обзор?',
          style: TextStyle(color: isDark ? colors.textColor : textColorLight),
        ),
        content: Text(
          'Это действие нельзя будет отменить.',
          style: TextStyle(color: isDark ? colors.textColorSecondary : textColorSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: isDark ? colors.textColorSecondary : textColorSecondaryLight),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Закрываем диалог
              
              try {
                await ref.read(reviewsControllerProvider).deleteReview(review.id);
                
                if (context.mounted) {
                  Navigator.pop(context); // Возвращаемся на предыдущий экран
                  showSnackBar(
                    context: context,
                    content: 'Обзор удалён',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showSnackBar(
                    context: context,
                    content: 'Ошибка при удалении: ${e.toString()}',
                  );
                }
              }
            },
            child: Text(
              'Удалить',
              style: TextStyle(color: Colors.red[400]),
            ),
          ),
        ],
      ),
    );
  }
}
