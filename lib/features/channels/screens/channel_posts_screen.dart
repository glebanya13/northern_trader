import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/common/widgets/loader.dart';
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
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              if (index >= posts.length || posts[index].id.isEmpty) {
                return const SizedBox.shrink();
              }
              final post = posts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Card(
                  color: cardColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: dividerColor, width: 1),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (post.id.isNotEmpty && widget.channel.id.isNotEmpty) {
                        ref.read(channelsControllerProvider).incrementViews(
                          widget.channel.id,
                          post.id,
                        );
                        _showPostDetail(context, post, isOwner);
                      }
                    },
                    onLongPress: isOwner && post.id.isNotEmpty
                        ? () => _showPostActions(context, post)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrl!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 200,
                                color: appBarColor,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: limeGreen,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 200,
                                color: appBarColor,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: greyColor,
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title,
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Html(
                                data: post.content,
                                style: {
                                  "body": Style(
                                    color: textColorSecondary,
                                    fontSize: FontSize(15),
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                    maxLines: 3,
                                    textOverflow: TextOverflow.ellipsis,
                                  ),
                                  "p": Style(
                                    margin: Margins.only(bottom: 8),
                                  ),
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: greyColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('dd.MM.yyyy HH:mm').format(post.createdAt),
                                    style: const TextStyle(
                                      color: greyColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.visibility,
                                    size: 16,
                                    color: greyColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${post.views}',
                                    style: const TextStyle(
                                      color: greyColor,
                                      fontSize: 13,
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isOwner)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: limeGreen),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditPostDialog(context, post);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          Navigator.pop(context);
                          _deletePost(context, post);
                        },
                      ),
                    ],
                  ),
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                  const SizedBox(height: 16),
                Text(
                  post.title,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Html(
                  data: post.content,
                  style: {
                    "body": Style(
                      color: textColor,
                      fontSize: FontSize(16),
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "p": Style(
                      margin: Margins.only(bottom: 12),
                    ),
                    "h1": Style(
                      fontSize: FontSize(24),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 12),
                    ),
                    "h2": Style(
                      fontSize: FontSize(20),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 10),
                    ),
                    "h3": Style(
                      fontSize: FontSize(18),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 8),
                    ),
                    "img": Style(
                      width: Width(double.infinity),
                      margin: Margins.symmetric(vertical: 8),
                    ),
                    "a": Style(
                      color: limeGreen,
                      textDecoration: TextDecoration.underline,
                    ),
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Просмотров: ${post.views}',
                  style: const TextStyle(
                    color: greyColor,
                    fontSize: 12,
                  ),
                ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: limeGreen),
              title: const Text('Редактировать', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                _showEditPostDialog(context, post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deletePost(context, post);
              },
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Редактировать пост', style: TextStyle(color: textColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Заголовок',
                  labelStyle: TextStyle(color: greyColor),
                ),
                style: const TextStyle(color: textColor),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Содержание (HTML)',
                  labelStyle: TextStyle(color: greyColor),
                ),
                style: const TextStyle(color: textColor),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL изображения (необязательно)',
                  labelStyle: TextStyle(color: greyColor),
                ),
                style: const TextStyle(color: textColor),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: greyColor)),
          ),
          TextButton(
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
            child: const Text('Сохранить', style: TextStyle(color: limeGreen)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Удалить пост?', style: TextStyle(color: textColor)),
        content: const Text('Вы уверены, что хотите удалить этот пост?', style: TextStyle(color: greyColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: greyColor)),
          ),
          TextButton(
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
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

