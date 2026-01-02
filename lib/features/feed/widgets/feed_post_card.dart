import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/models/channel_post.dart';
import 'package:northern_trader/models/channel.dart';

class FeedPostCard extends ConsumerWidget {
  final ChannelPost post;
  final Channel channel;
  final VoidCallback? onTap;

  const FeedPostCard({
    Key? key,
    required this.post,
    required this.channel,
    this.onTap,
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
          child: ClipRect(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Название канала вверху
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 6.0),
                  child: Text(
                    channel.name,
                    style: TextStyle(
                      color: colors.accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Изображение (если есть)
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                  ClipRRect(
                    child: AspectRatio(
                      aspectRatio: 2.0,
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: colors.cardColorLight,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: colors.accentColor,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: colors.cardColorLight,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: isDark ? colors.greyColor : greyColorDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Контент поста
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Заголовок поста
                        Text(
                          post.title,
                          style: TextStyle(
                            color: isDark ? colors.textColor : textColorDark,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Превью контента
                        if (_getContentPreview(post).isNotEmpty)
                          Flexible(
                            child: Text(
                              _getContentPreview(post),
                              style: TextStyle(
                                color: isDark ? colors.textColorSecondary : textColorSecondaryDark,
                                fontSize: 14,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 6),
                        // Дата и статистика
                        Row(
                          children: [
                            Text(
                              _formatDate(post.createdAt),
                              style: TextStyle(
                                color: isDark ? colors.greyColor : greyColorDark,
                                fontSize: 11,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 14,
                              color: isDark ? colors.greyColor : greyColorDark,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '0',
                              style: TextStyle(
                                color: isDark ? colors.greyColor : greyColorDark,
                                fontSize: 11,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.rocket_launch_outlined,
                              size: 14,
                              color: isDark ? colors.greyColor : greyColorDark,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '${post.views}',
                                style: TextStyle(
                                  color: isDark ? colors.greyColor : greyColorDark,
                                  fontSize: 11,
                                  height: 1.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getContentPreview(ChannelPost post) {
    if (post.contentType == 'quill') {
      try {
        final deltaJson = jsonDecode(post.content) as List;
        final document = quill.Document.fromJson(deltaJson);
        final controller = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
        return controller.document.toPlainText();
      } catch (e) {
        return '';
      }
    } else {
      return post.content.replaceAll(RegExp(r'[#*`>\-\[\]]+'), '').trim();
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
}

