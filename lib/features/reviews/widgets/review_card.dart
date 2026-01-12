import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/models/review.dart';

class ReviewCard extends ConsumerWidget {
  final Review review;
  final VoidCallback? onTap;
  final bool compact; // Компактный режим для отображения на главной

  const ReviewCard({
    Key? key,
    required this.review,
    this.onTap,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);

    return Container(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: limeGreenLight.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Тег "Обзор" и категория
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 6.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.accentColorDark.withOpacity(0.25),
                            colors.accentColorDark.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colors.accentColorDark.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 14,
                            color: colors.accentColorDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ОБЗОР',
                            style: TextStyle(
                              color: colors.accentColorDark,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getCategoryName(review.category),
                        style: TextStyle(
                          color: colors.accentColor.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Изображение (если есть)
              if (review.imageUrl != null && review.imageUrl!.isNotEmpty)
                ClipRRect(
                  child: AspectRatio(
                    aspectRatio: compact ? 2.2 : 2.0,
                    child: CachedNetworkImage(
                      imageUrl: review.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colors.cardColorLight,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _getCategoryColor(review.category),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colors.cardColorLight,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: colors.cardGreyColor,
                        ),
                      ),
                    ),
                  ),
                ),
              // Контент обзора
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Заголовок обзора
                    Text(
                      review.title,
                      style: TextStyle(
                        color: colors.cardTextColor,
                        fontSize: compact ? 16 : 17,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Превью контента
                    if (_getContentPreview(review).isNotEmpty && !compact) ...[
                      const SizedBox(height: 6),
                      Text(
                        _getContentPreview(review),
                        style: TextStyle(
                          color: colors.cardTextColorSecondary,
                          fontSize: 14,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    // Автор, дата и статистика
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: colors.cardGreyColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            review.authorName,
                            style: TextStyle(
                              color: colors.cardGreyColor,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(
                            color: colors.cardGreyColor,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.visibility_outlined,
                          size: 14,
                          color: colors.cardGreyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${review.views}',
                          style: TextStyle(
                            color: colors.cardGreyColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
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

  String _getContentPreview(Review review) {
    if (review.contentType == 'quill') {
      try {
        final deltaJson = jsonDecode(review.content) as List;
        final document = quill.Document.fromJson(deltaJson);
        final controller = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
        final plainText = controller.document.toPlainText();
        // Убираем лишние символы новой строки и пробелы
        return plainText
            .replaceAll(RegExp(r'\n+'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
      } catch (e) {
        return '';
      }
    } else {
      // Для Markdown - убираем разметку и форматируем
      return review.content
          .replaceAll(RegExp(r'#+\s'), '') // Убираем заголовки
          .replaceAll(RegExp(r'\*\*([^\*]+)\*\*'), r'$1') // Убираем жирный
          .replaceAll(RegExp(r'\*([^\*]+)\*'), r'$1') // Убираем курсив
          .replaceAll(RegExp(r'`([^`]+)`'), r'$1') // Убираем код
          .replaceAll(RegExp(r'>\s'), '') // Убираем цитаты
          .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1') // Убираем ссылки
          .replaceAll(RegExp(r'[-*]\s'), '') // Убираем маркеры списков
          .replaceAll(RegExp(r'\n+'), ' ') // Убираем переносы строк
          .replaceAll(RegExp(r'\s+'), ' ') // Убираем множественные пробелы
          .trim();
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек'
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'market':
        return const Color(0xFF6366F1); // Indigo
      case 'technical':
        return const Color(0xFF8B5CF6); // Purple
      case 'fundamental':
        return const Color(0xFF10B981); // Green
      case 'crypto':
        return const Color(0xFFF59E0B); // Amber
      case 'forex':
        return const Color(0xFF3B82F6); // Blue
      case 'stocks':
        return const Color(0xFFEC4899); // Pink
      default:
        return const Color(0xFF00D68F); // Default color
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
}
