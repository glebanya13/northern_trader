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
    final double imageHeight = compact ? 140 : 200;
    final EdgeInsets contentPadding =
        compact ? const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 10.0) : const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 10.0);
    final double titleFontSize = compact ? 17 : 20;
    final double previewFontSize = compact ? 14 : 16;
    final int previewMaxLines = compact ? 2 : 3;
    final double channelAvatarSize = compact ? 32 : 36;
    final double containerMarginBottom = compact ? 8 : 10;
    final double metaVerticalPadding = compact ? 6 : 6;
    final double metaHorizontalPadding = compact ? 10 : 12;

    return Container(
      margin: EdgeInsets.only(bottom: containerMarginBottom),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
        border: Border.all(
          color: limeGreen.withOpacity(0.25),
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
            color: limeGreen.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
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
                                      height: 1.0,
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
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 8 : 8),
                      ],
                      Text(
                        post.title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          height: compact ? 1.2 : 1.15,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: compact ? 5 : 5),
                      _buildPostPreview(
                        post,
                        fontSize: previewFontSize,
                        maxLines: previewMaxLines,
                      ),
                      SizedBox(height: compact ? 7 : 7),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: metaHorizontalPadding,
                          vertical: metaVerticalPadding,
                        ),
                        decoration: BoxDecoration(
                          color: cardColorLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: dividerColor.withOpacity(0.2),
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
                                  height: 1.0,
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
                                      height: 1.0,
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
            color: textColorSecondary,
            fontSize: fontSize,
            height: 1.25,
            letterSpacing: 0.2,
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        );
      } catch (e) {
        return Text(
          'Ошибка загрузки контента',
          style: TextStyle(color: limeGreen.withOpacity(0.7)),
        );
      }
    } else {
      return Text(
        post.content.replaceAll(RegExp(r'[#*`>\-\[\]]+'), '').trim(),
        style: TextStyle(
          color: textColorSecondary,
          fontSize: fontSize,
          height: 1.25,
          letterSpacing: 0.2,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}

