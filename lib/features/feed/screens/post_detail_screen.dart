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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Container(
                                height: 300,
                                color: cardColor,
                                child: Center(
                                  child: CircularProgressIndicator(color: limeGreen),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 300,
                                color: cardColor,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                  color: greyColor,
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
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: limeGreen.withOpacity(0.2),
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
                              width: MediaQuery.of(context).size.width > 600 ? 50 : 40,
                              height: MediaQuery.of(context).size.width > 600 ? 50 : 40,
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
                                          child: Icon(
                                            Icons.rss_feed_rounded,
                                            size: MediaQuery.of(context).size.width > 600 ? 24 : 20,
                                            color: limeGreen,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: backgroundColor,
                                        child: Icon(
                                          Icons.rss_feed_rounded,
                                          size: MediaQuery.of(context).size.width > 600 ? 24 : 20,
                                          color: limeGreen,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width > 600 ? 16 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    channel.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd.MM.yyyy HH:mm')
                                        .format(post.createdAt),
                                    style: TextStyle(
                                      color: greyColor,
                                      fontSize: MediaQuery.of(context).size.width > 600 ? 13 : 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                        style: TextStyle(
                          color: textColor,
                          fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 22,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPostContent(post),
                      const SizedBox(height: 32),
                      Container(
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width > 600 ? 20 : 16,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: dividerColor.withOpacity(0.3),
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
                            Icon(Icons.visibility_outlined,
                                size: 20, color: greyColor),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Просмотров: ${post.views}',
                                style: const TextStyle(
                                  color: greyColor,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.calendar_today_outlined,
                                size: 20, color: greyColor),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                DateFormat('dd.MM.yyyy HH:mm').format(post.createdAt),
                                style: const TextStyle(
                                  color: greyColor,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
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
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AbsorbPointer(
            absorbing: true,
            child: Builder(
              builder: (context) => Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.copyWith(
                    bodyLarge: const TextStyle(
                      color: Color.fromRGBO(220, 220, 220, 1),
                      fontSize: 17,
                      height: 1.8,
                    ),
                    bodyMedium: const TextStyle(
                      color: Color.fromRGBO(220, 220, 220, 1),
                      fontSize: 17,
                      height: 1.8,
                    ),
                  ),
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Color.fromRGBO(220, 220, 220, 1),
                    fontSize: 17,
                    height: 1.8,
                  ),
                  child: quill.QuillEditor(
                    controller: controller,
                    focusNode: FocusNode(),
                    scrollController: ScrollController(),
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
          p: const TextStyle(
            color: Color.fromRGBO(220, 220, 220, 1),
            fontSize: 17,
            height: 1.8,
            letterSpacing: 0.3,
          ),
          h1: const TextStyle(
            color: textColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          h2: const TextStyle(
            color: textColor,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          h3: const TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          listBullet: const TextStyle(
            color: limeGreen,
            fontSize: 17,
          ),
          listIndent: 28,
          blockquoteDecoration: BoxDecoration(
            color: cardColorLight,
            borderRadius: BorderRadius.circular(8),
            border: const Border(
              left: BorderSide(color: limeGreen, width: 4),
            ),
          ),
          blockquotePadding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
          blockquote: const TextStyle(
            color: textColorSecondary,
            fontStyle: FontStyle.italic,
            fontSize: 16,
            height: 1.7,
          ),
          code: TextStyle(
            backgroundColor: cardColorLight,
            color: limeGreen,
            fontSize: 15,
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: cardColorLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: limeGreen.withOpacity(0.2),
              width: 1,
            ),
          ),
          codeblockPadding: const EdgeInsets.all(16),
          strong: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
          em: const TextStyle(
            color: textColorSecondary,
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
          pPadding: const EdgeInsets.only(bottom: 20),
        ),
      );
    }
  }
}

