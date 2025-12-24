import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/common/widgets/loader.dart';
import 'package:northern_trader/common/widgets/post_card.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';
import 'package:northern_trader/features/channels/controller/channels_controller.dart';
import 'package:northern_trader/features/channels/screens/create_post_screen.dart';
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(widget.channel.name),
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.add, color: limeGreen),
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
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка: ${snapshot.error}',
                      style: const TextStyle(color: greyColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article, size: 64, color: greyColor),
                  SizedBox(height: 16),
                  Text(
                    'Пока нет постов',
                    style: TextStyle(color: greyColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              if (index >= posts.length || posts[index].id.isEmpty) {
                return const SizedBox.shrink();
              }
              final post = posts[index];
              return GestureDetector(
                onLongPress: isOwner && post.id.isNotEmpty
                    ? () => _showPostActions(context, post)
                    : null,
                child: PostCard(
                  post: post,
                  channel: widget.channel,
                  showChannelInfo: false,
                  onTap: () {
                    if (post.id.isNotEmpty && widget.channel.id.isNotEmpty) {
                      ref.read(channelsControllerProvider).incrementViews(
                            widget.channel.id,
                            post.id,
                          );
                      _showPostDetail(context, post, isOwner);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPostDetail(BuildContext context, ChannelPost post, bool isOwner) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: greyColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (isOwner)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditPostDialog(context, post);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Редактировать'),
                          style: TextButton.styleFrom(
                            foregroundColor: limeGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _deletePost(context, post);
                          },
                          icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                          label: Text('Удалить', style: TextStyle(color: Colors.red[400])),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red[400],
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: appBarColor,
                        child: Center(
                          child: CircularProgressIndicator(color: limeGreen),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: appBarColor,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: greyColor,
                        ),
                      ),
                    ),
                  ),
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                  const SizedBox(height: 24),
                                Text(
                                  post.title,
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                _buildPostContent(post, isPreview: false),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: appBarColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: dividerColor, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility_outlined, size: 18, color: greyColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Просмотров: ${post.views}',
                                        style: const TextStyle(
                                          color: greyColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(Icons.calendar_today_outlined, size: 18, color: greyColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat('dd.MM.yyyy HH:mm').format(post.createdAt),
                                        style: const TextStyle(
                                          color: greyColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  void _showPostActions(BuildContext context, ChannelPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cardColor,
              appBarColor,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
                color: greyColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Text(
              'Действия с постом',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    limeGreen.withOpacity(0.15),
                    limeGreen.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: limeGreen.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _showEditPostDialog(context, post);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: limeGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: limeGreen.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: limeGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Редактировать',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Изменить содержимое поста',
                                style: TextStyle(
                                  color: greyColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: limeGreen,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                    _deletePost(context, post);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
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
                              const Text(
                                'Удалить пост навсегда',
                                style: TextStyle(
                                  color: greyColor,
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


  void _showEditPostDialog(BuildContext context, ChannelPost post) {
    final titleController = TextEditingController(text: post.title);
    final contentController = TextEditingController(text: post.content);
    final imageUrlController = TextEditingController(text: post.imageUrl ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Редактировать пост',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: textColor, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Заголовок',
                  labelStyle: const TextStyle(color: greyColor),
                  filled: true,
                  fillColor: appBarColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: limeGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 10,
                style: const TextStyle(color: textColor, fontSize: 15, height: 1.5),
                decoration: InputDecoration(
                  labelText: 'Содержание (Markdown)',
                  labelStyle: const TextStyle(color: greyColor),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: appBarColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: limeGreen, width: 2),
                  ),
                  hintText: '# Заголовок\n\n**Жирный** *Курсив*\n\n- Список',
                  hintStyle: TextStyle(color: greyColor.withOpacity(0.5), fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                style: const TextStyle(color: textColor, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'URL изображения (необязательно)',
                  labelStyle: const TextStyle(color: greyColor),
                  filled: true,
                  fillColor: appBarColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: limeGreen, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Отмена',
              style: TextStyle(
                color: greyColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (widget.channel.id.isEmpty || post.id.isEmpty) {
                showSnackBar(context: context, content: 'Ошибка: ID канала или поста пустой');
                return;
              }
              if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
                showSnackBar(context: context, content: 'Заполните все обязательные поля');
                return;
              }
              
              try {
                await ref.read(channelsControllerProvider).updatePost(
                  widget.channel.id,
                  post.id,
                  {
                    'title': titleController.text.trim(),
                    'content': contentController.text.trim(),
                    'imageUrl': imageUrlController.text.trim().isEmpty ? null : imageUrlController.text.trim(),
                  },
                );
                Navigator.pop(context);
                showSnackBar(context: context, content: 'Пост обновлен');
              } catch (e) {
                showSnackBar(context: context, content: 'Ошибка: ${e.toString()}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: limeGreen,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Сохранить',
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deletePost(BuildContext context, ChannelPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
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
            const Expanded(
              child: Text(
                'Удалить пост?',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Вы уверены, что хотите удалить этот пост? Это действие нельзя отменить.',
          style: TextStyle(
            color: textColorSecondary,
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
            child: const Text(
              'Отмена',
              style: TextStyle(
                color: greyColor,
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

  Widget _buildPostContent(ChannelPost post, {bool isPreview = false}) {
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
            style: const TextStyle(
              color: Color.fromRGBO(210, 210, 210, 1),
              fontSize: 16,
              height: 1.7,
              letterSpacing: 0.2,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          );
        } else {
          return AbsorbPointer(
            absorbing: true,
            child: quill.QuillEditor(
              controller: controller,
              focusNode: FocusNode(),
              scrollController: ScrollController(),
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
          style: const TextStyle(
            color: Color.fromRGBO(210, 210, 210, 1),
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
            p: const TextStyle(
              color: Color.fromRGBO(220, 220, 220, 1),
              fontSize: 18,
              height: 1.9,
              letterSpacing: 0.3,
            ),
            h1: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            h2: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            h3: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontSize: 21,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
            listBullet: const TextStyle(
              color: limeGreen,
              fontSize: 18,
            ),
            listIndent: 24,
            blockquoteDecoration: BoxDecoration(
              color: const Color.fromRGBO(35, 35, 35, 0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: limeGreen, width: 4),
              ),
            ),
            blockquotePadding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            blockquote: const TextStyle(
              color: Color.fromRGBO(200, 200, 200, 1),
              fontStyle: FontStyle.italic,
              fontSize: 17,
              height: 1.7,
            ),
            code: const TextStyle(
              backgroundColor: Color.fromRGBO(35, 35, 35, 1),
              color: limeGreen,
              fontSize: 16,
              fontFamily: 'monospace',
            ),
            codeblockDecoration: BoxDecoration(
              color: const Color.fromRGBO(35, 35, 35, 1),
              borderRadius: BorderRadius.circular(8),
            ),
            codeblockPadding: const EdgeInsets.all(16),
            strong: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontWeight: FontWeight.bold,
            ),
            em: const TextStyle(
              color: Color.fromRGBO(200, 200, 200, 1),
              fontStyle: FontStyle.italic,
            ),
            a: const TextStyle(
              color: limeGreen,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
            h1Padding: const EdgeInsets.only(top: 32, bottom: 24),
            h2Padding: const EdgeInsets.only(top: 28, bottom: 20),
            h3Padding: const EdgeInsets.only(top: 24, bottom: 18),
            pPadding: const EdgeInsets.only(bottom: 24),
          ),
        );
      }
    }
  }
}

