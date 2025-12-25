import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/models/channel_post.dart';
import 'package:northern_trader/models/channel.dart';

class FeedPostCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: limeGreen.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: limeGreen.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
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
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: AspectRatio(
                    aspectRatio: 2.0,
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: cardColorLight,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: limeGreen,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: cardColorLight,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: greyColor,
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    if (_getContentPreview(post).isNotEmpty)
                      Text(
                        _getContentPreview(post),
                        style: const TextStyle(
                          color: textColorSecondary,
                          fontSize: 15,
                          height: 1.25,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          'от ${channel.name}',
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 12,
                            height: 1.0,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(post.createdAt),
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 12,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 16,
                          color: greyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '0',
                          style: TextStyle(
                            color: greyColor,
                            fontSize: 12,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.rocket_launch_outlined,
                          size: 16,
                          color: greyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.views}',
                          style: TextStyle(
                            color: greyColor,
                            fontSize: 12,
                            height: 1.0,
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

