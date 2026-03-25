import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/common/widgets/loader.dart';
import 'package:northern_trader/common/widgets/post_card.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';
import 'package:northern_trader/features/channels/controller/channels_controller.dart';
import 'package:northern_trader/features/channels/screens/create_post_screen.dart';
import 'package:northern_trader/features/channels/screens/channel_post_detail_screen.dart';
import 'package:northern_trader/models/channel.dart';
import 'package:northern_trader/models/channel_post.dart';

class ChannelPostsScreen extends ConsumerStatefulWidget {
  final Channel channel;
  const ChannelPostsScreen({
    Key? key,
    required this.channel,
  }) : super(key: key);

  @override
  ConsumerState<ChannelPostsScreen> createState() => _ChannelPostsScreenState();
}

class _ChannelPostsScreenState extends ConsumerState<ChannelPostsScreen> {
  @override
  Widget build(BuildContext context) {
    final postsStream = ref.watch(channelsControllerProvider).getChannelPosts(widget.channel.id);
    final userData = ref.watch(userDataAuthProvider);
    final isOwner = userData.value?.isOwner ?? false;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.appBarColor,
        title: Text(widget.channel.name),
        actions: isOwner
            ? [
                IconButton(
                  icon: Icon(Icons.add, color: colors.accentColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostScreen(
                          channel: widget.channel,
                        ),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: StreamBuilder<List<ChannelPost>>(
        stream: postsStream,
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
                    Icon(Icons.error_outline, color: colors.accentColor.withOpacity(0.6), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка: ${snapshot.error}',
                      style: TextStyle(color: colors.greyColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article, size: 64, color: colors.greyColor),
                  const SizedBox(height: 16),
                  Text(
                    'Пока нет постов',
                    style: TextStyle(color: colors.greyColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1200 : double.infinity,
                  ),
                  child: ListView.builder(
                    itemCount: posts.length,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 12,
                      vertical: isDesktop ? 20 : 12,
                    ),
                    itemBuilder: (context, index) {
                      if (index >= posts.length || posts[index].id.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final post = posts[index];
                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 800 : double.infinity,
                          ),
                          child: GestureDetector(
                            onLongPress: isOwner && post.id.isNotEmpty
                                ? () => _showPostActions(context, post, colors, isDark)
                                : null,
                            child: PostCard(
                              post: post,
                              channel: widget.channel,
                              showChannelInfo: false,
                              compact: !isDesktop,
                              onTap: () {
                                if (post.id.isNotEmpty && widget.channel.id.isNotEmpty) {
                                  ref.read(channelsControllerProvider).incrementViews(
                                        widget.channel.id,
                                        post.id,
                                      );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChannelPostDetailScreen(
                                        channel: widget.channel,
                                        post: post,
                                        isOwner: isOwner,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


  void _showPostActions(BuildContext context, ChannelPost post, AppColors colors, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark ? [
              colors.cardColor,
              colors.appBarColor,
            ] : [
              cardColorLight,
              appBarColorLight,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: colors.greyColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Text(
              'Действия с постом',
              style: TextStyle(
                color: colors.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.15),
                    Colors.red.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _deletePost(context, post, colors, isDark);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.delete_rounded,
                            color: Colors.red[400],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Удалить',
                                style: TextStyle(
                                  color: Colors.red[400],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Удалить пост навсегда',
                                style: TextStyle(
                                  color: colors.greyColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.red[400],
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _deletePost(BuildContext context, ChannelPost post, AppColors colors, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? colors.cardColor : cardColorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.red[300], size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Удалить пост?',
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
          'Вы уверены, что хотите удалить этот пост? Это действие нельзя отменить.',
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
                color: isDark ? colors.cardGreyColor : textColorSecondaryLight,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (widget.channel.id.isEmpty || post.id.isEmpty) {
                showSnackBar(context: context, content: 'Ошибка: ID канала или поста пустой');
                Navigator.pop(context);
                return;
              }
              try {
                await ref.read(channelsControllerProvider).deletePost(
                  widget.channel.id,
                  post.id,
                );
                Navigator.pop(context);
                showSnackBar(context: context, content: 'Пост удален');
              } catch (e) {
                Navigator.pop(context);
                showSnackBar(context: context, content: 'Ошибка: ${e.toString()}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[300],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  Widget _buildPostContent(ChannelPost post, AppColors colors, {bool isPreview = false, required bool isDark}) {
    if (post.contentType == 'quill') {
      try {
        final deltaJson = jsonDecode(post.content) as List;
        final document = quill.Document.fromJson(deltaJson);
        final controller = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );

        if (isPreview) {
          return Text(
            controller.document.toPlainText(),
            style: TextStyle(
              color: colors.textColor,
              fontSize: 16,
              height: 1.7,
              letterSpacing: 0.2,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          );
        } else {
          return Container(
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
        }
      } catch (e) {
        return Text(
          'Ошибка загрузки контента',
          style: TextStyle(color: Colors.red[300]),
        );
      }
    } else {
      if (isPreview) {
        return Text(
          post.content.replaceAll(RegExp(r'[#*`>\-\[\]]+'), '').trim(),
          style: TextStyle(
            color: colors.textColor,
            fontSize: 16,
            height: 1.7,
            letterSpacing: 0.2,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        );
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            h2: TextStyle(
              color: colors.textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            h3: TextStyle(
              color: colors.textColor,
              fontSize: 21,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
            listBullet: TextStyle(
              color: colors.accentColor,
              fontSize: 18,
            ),
            listIndent: 24,
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
  }
}

