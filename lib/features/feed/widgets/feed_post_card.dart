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
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
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
                        color: backgroundColor,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 32,
                          color: greyColor,
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    if (_getContentPreview(post).isNotEmpty)
                      Text(
                        _getContentPreview(post),
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'от ${channel.name}',
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(post.createdAt),
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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

