import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/models/channel_post.dart';
import 'package:northern_trader/models/channel.dart';
import 'package:northern_trader/features/channels/screens/edit_post_screen.dart';
import 'package:northern_trader/features/channels/controller/channels_controller.dart';
import 'package:northern_trader/common/utils/utils.dart';

class ChannelPostDetailScreen extends ConsumerWidget {
  final ChannelPost post;
  final Channel channel;
  final bool isOwner;

  const ChannelPostDetailScreen({
    Key? key,
    required this.post,
    required this.channel,
    required this.isOwner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          channel.name,
          style: TextStyle(color: colors.textColor),
        ),
        actions: isOwner
            ? [
                IconButton(
                  icon: Icon(Icons.edit, color: colors.accentColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPostScreen(
                          channel: channel,
                          post: post,
                        ),
                      ),
                    );
                  },
                  tooltip: 'Редактировать',
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                  onPressed: () {
                    ChannelPostDetailScreen._showDeleteDialog(context, ref, channel, post, colors, isDark);
                  },
                  tooltip: 'Удалить',
                ),
              ]
            : null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          constraints: const BoxConstraints(
                            maxHeight: 500,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: limeGreenLight,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Container(
                                height: 300,
                                color: colors.cardColor,
                                child: Center(
                                  child: CircularProgressIndicator(color: colors.accentColor),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 300,
                                color: colors.cardColor,
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                  color: colors.cardGreyColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width > 600 ? 16 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: colors.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: isMobile ? 40 : 50,
                              height: isMobile ? 40 : 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.accentColor.withOpacity(0.2),
                                border: Border.all(
                                  color: colors.accentColor.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: channel.imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: channel.imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: colors.backgroundColor,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: colors.backgroundColor,
                                          child: Icon(
                                            Icons.rss_feed_rounded,
                                            size: isMobile ? 20 : 24,
                                            color: colors.accentColor,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: colors.backgroundColor,
                                        child: Icon(
                                          Icons.rss_feed_rounded,
                                          size: isMobile ? 20 : 24,
                                          color: colors.accentColor,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: isMobile ? 12 : 16),
                            Expanded(
                              child: Text(
                                channel.name,
                                style: TextStyle(
                                  color: colors.cardTextColor,
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: isMobile ? 12 : 16),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: isMobile ? 16 : 16,
                              color: colors.cardGreyColor,
                            ),
                            SizedBox(width: isMobile ? 6 : 8),
                            Text(
                              DateFormat('dd.MM.yyyy HH:mm')
                                  .format(post.createdAt),
                              style: TextStyle(
                                color: colors.cardGreyColor,
                                fontSize: isMobile ? 12 : 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        post.title,
                        style: TextStyle(
                          color: isDark ? colors.textColor : textColorLight,
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPostContent(post, colors, isDark),
                      const SizedBox(height: 32),
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

  Widget _buildPostContent(ChannelPost post, AppColors colors, bool isDark) {
    if (post.contentType == 'quill') {
      try {
        final deltaJson = jsonDecode(post.content) as List;
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
                      fontSize: 17,
                      height: 1.8,
                    ),
                    bodyMedium: TextStyle(
                      color: colors.textColor,
                      fontSize: 17,
                      height: 1.8,
                    ),
                  ),
                ),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: colors.textColor,
                    fontSize: 17,
                    height: 1.8,
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
          'Ошибка загрузки контента',
          style: TextStyle(color: Colors.red[300]),
        );
      }
    } else {
      return MarkdownBody(
        data: post.content,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            color: colors.textColor,
            fontSize: 17,
            height: 1.8,
            letterSpacing: 0.3,
          ),
          h1: TextStyle(
            color: colors.textColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          h2: TextStyle(
            color: colors.textColor,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          h3: TextStyle(
            color: colors.textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          listBullet: TextStyle(
            color: colors.accentColor,
            fontSize: 17,
          ),
          listIndent: 28,
          blockquoteDecoration: BoxDecoration(
            color: isDark ? colors.cardColorLight : cardColorLightLight,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: colors.accentColor, width: 4),
            ),
          ),
          blockquotePadding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
          blockquote: TextStyle(
            color: isDark ? colors.textColorSecondary : textColorSecondaryLight,
            fontStyle: FontStyle.italic,
            fontSize: 16,
            height: 1.7,
          ),
          code: TextStyle(
            backgroundColor: isDark ? colors.cardColorLight : cardColorLightLight,
            color: colors.accentColor,
            fontSize: 15,
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: isDark ? colors.cardColorLight : cardColorLightLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colors.accentColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          codeblockPadding: const EdgeInsets.all(16),
          strong: TextStyle(
            color: colors.textColor,
            fontWeight: FontWeight.bold,
          ),
          em: TextStyle(
            color: colors.textColorSecondary,
            fontStyle: FontStyle.italic,
          ),
          a: TextStyle(
            color: colors.accentColor,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w600,
          ),
          h1Padding: const EdgeInsets.only(top: 32, bottom: 24),
          h2Padding: const EdgeInsets.only(top: 28, bottom: 20),
          h3Padding: const EdgeInsets.only(top: 24, bottom: 18),
          pPadding: const EdgeInsets.only(bottom: 20),
        ),
      );
    }
  }

  static void _showDeleteDialog(BuildContext context, WidgetRef ref, Channel channel, ChannelPost post, AppColors colors, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? colors.cardColor : cardColorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Удалить пост?',
          style: TextStyle(
            color: isDark ? colors.cardTextColor : textColorLight,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите удалить этот пост? Это действие нельзя отменить.',
          style: TextStyle(
            color: isDark ? colors.cardTextColorSecondary : textColorSecondaryLight,
            fontSize: 15,
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
                color: isDark ? colors.cardGreyColor : textColorSecondaryLight,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(channelsControllerProvider).deletePost(
                  channel.id,
                  post.id,
                );
                if (context.mounted) {
                  Navigator.pop(context); // Закрываем диалог
                  Navigator.pop(context); // Возвращаемся на предыдущий экран
                  showSnackBar(context: context, content: 'Пост удален');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  showSnackBar(context: context, content: 'Ошибка: ${e.toString()}');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
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
}

