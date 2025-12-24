import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/models/channel_post.dart';
import 'package:northern_trader/models/channel.dart';

class PostDetailScreen extends StatelessWidget {
  final ChannelPost post;
  final Channel channel;

  static const routeName = '/post-detail';

  const PostDetailScreen({
    Key? key,
    required this.post,
    required this.channel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: backgroundColor,
                      child: Center(
                        child: CircularProgressIndicator(color: limeGreen),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: backgroundColor,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: greyColor,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: limeGreen.withOpacity(0.2),
                            border: Border.all(
                              color: limeGreen.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: channel.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: channel.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: backgroundColor,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: backgroundColor,
                                      child: const Icon(
                                        Icons.rss_feed_rounded,
                                        size: 24,
                                        color: limeGreen,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: backgroundColor,
                                    child: const Icon(
                                      Icons.rss_feed_rounded,
                                      size: 24,
                                      color: limeGreen,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                channel.name,
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd.MM.yyyy HH:mm')
                                    .format(post.createdAt),
                                style: const TextStyle(
                                  color: greyColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  const SizedBox(height: 24),
                  _buildPostContent(post),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined,
                            size: 20, color: greyColor),
                        const SizedBox(width: 8),
                        Text(
                          'Просмотров: ${post.views}',
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.calendar_today_outlined,
                            size: 20, color: greyColor),
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContent(ChannelPost post) {
    if (post.contentType == 'quill') {
      try {
        final deltaJson = jsonDecode(post.content) as List;
        final document = quill.Document.fromJson(deltaJson);
        final controller = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
        return AbsorbPointer(
          absorbing: true,
          child: quill.QuillEditor(
            controller: controller,
            focusNode: FocusNode(),
            scrollController: ScrollController(),
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
          p: const TextStyle(
            color: textColor,
            fontSize: 16,
            height: 1.7,
            letterSpacing: 0.2,
          ),
          h1: const TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          h2: const TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          h3: const TextStyle(
            color: textColor,
            fontSize: 21,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          listBullet: const TextStyle(
            color: limeGreen,
            fontSize: 16,
          ),
          listIndent: 24,
          blockquoteDecoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: limeGreen, width: 4),
            ),
          ),
          blockquotePadding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
          blockquote: const TextStyle(
            color: textColor,
            fontStyle: FontStyle.italic,
            fontSize: 16,
            height: 1.7,
          ),
          code: const TextStyle(
            backgroundColor: backgroundColor,
            color: limeGreen,
            fontSize: 14,
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          codeblockPadding: const EdgeInsets.all(16),
          strong: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
          em: const TextStyle(
            color: textColor,
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

