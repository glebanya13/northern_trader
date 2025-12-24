import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/models/channel_post.dart';
import 'package:northern_trader/models/channel.dart';

class PostCard extends ConsumerWidget {
  final ChannelPost post;
  final Channel channel;
  final VoidCallback? onTap;
  final bool showChannelInfo;
  final bool compact;

  const PostCard({
    Key? key,
    required this.post,
    required this.channel,
    this.onTap,
    this.showChannelInfo = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double imageHeight = compact ? 160 : 220;
    final EdgeInsets contentPadding =
        compact ? const EdgeInsets.all(14.0) : const EdgeInsets.all(20.0);
    final double titleFontSize = compact ? 18 : 22;
    final double previewFontSize = compact ? 14 : 16;
    final int previewMaxLines = compact ? 2 : 3;
    final double channelAvatarSize = compact ? 34 : 40;
    final double containerMarginBottom = compact ? 12 : 16;
    final double metaVerticalPadding = compact ? 8 : 10;
    final double metaHorizontalPadding = compact ? 12 : 14;

    return Container(
      margin: EdgeInsets.only(bottom: containerMarginBottom),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            cardColorLight.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: limeGreen.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: dividerColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrl!,
                          width: double.infinity,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: imageHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [appBarColor, cardColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: limeGreen,
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: imageHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [appBarColor, cardColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              size: 56,
                              color: greyColor,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                cardColor.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                Padding(
                  padding: contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showChannelInfo) ...[
                        Row(
                          children: [
                            Container(
                              width: channelAvatarSize,
                              height: channelAvatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    limeGreen.withOpacity(0.3),
                                    limeGreen.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: limeGreen.withOpacity(0.4),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: channel.imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: channel.imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: appBarColor,
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [appBarColor, cardColor],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.rss_feed_rounded,
                                            size: 20,
                                            color: limeGreen,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [appBarColor, cardColor],
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.rss_feed_rounded,
                                          size: 20,
                                          color: limeGreen,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    channel.name,
                                    style: const TextStyle(
                                      color: limeGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('dd.MM.yyyy HH:mm').format(post.createdAt),
                                    style: const TextStyle(
                                      color: greyColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 10 : 16),
                      ],
                      Text(
                        post.title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: compact ? 10 : 16),
                      _buildPostPreview(
                        post,
                        fontSize: previewFontSize,
                        maxLines: previewMaxLines,
                      ),
                      SizedBox(height: compact ? 12 : 16                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: metaHorizontalPadding,
                          vertical: metaVerticalPadding,
                        ),
                        decoration: BoxDecoration(
                          color: appBarColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: dividerColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (!showChannelInfo) ...[
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: limeGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: limeGreen,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd.MM.yyyy HH:mm').format(post.createdAt),
                                style: TextStyle(
                                  color: greyColor,
                                  fontSize: compact ? 12 : 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: limeGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.visibility_outlined,
                                    size: 14,
                                    color: limeGreen,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${post.views}',
                                    style: TextStyle(
                                      color: limeGreen,
                                      fontSize: compact ? 12 : 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (showChannelInfo) const Spacer(),
                            if (showChannelInfo)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: limeGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: limeGreen,
                                ),
                              ),
                          ],
                        ),
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

  Widget _buildPostPreview(
    ChannelPost post, {
    required double fontSize,
    required int maxLines,
  }) {
    if (post.contentType == 'quill') {
      try {
        final deltaJson = jsonDecode(post.content) as List;
        final document = quill.Document.fromJson(deltaJson);
        final controller = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );

        return Text(
          controller.document.toPlainText(),
          style: TextStyle(
            color: Color.fromRGBO(210, 210, 210, 1),
            fontSize: fontSize,
            height: 1.7,
            letterSpacing: 0.2,
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        );
      } catch (e) {
        return Text(
          'Ошибка загрузки контента',
          style: TextStyle(color: Colors.red[300]),
        );
      }
    } else {
      return Text(
        post.content.replaceAll(RegExp(r'[#*`>\-\[\]]+'), '').trim(),
        style: TextStyle(
          color: Color.fromRGBO(210, 210, 210, 1),
          fontSize: fontSize,
          height: 1.7,
          letterSpacing: 0.2,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}

