class ChannelPost {
  final String id;
  final String channelId;
  final String title;
  final String content;
  final String contentType; // 'markdown' или 'quill'
  final String? imageUrl;
  final String? videoUrl;
  final DateTime createdAt;
  final int views;
  final bool showInFeed; // Показывать ли пост в общей ленте

  ChannelPost({
    required this.id,
    required this.channelId,
    required this.title,
    required this.content,
    this.contentType = 'markdown', // По умолчанию markdown для обратной совместимости
    this.imageUrl,
    this.videoUrl,
    required this.createdAt,
    this.views = 0,
    this.showInFeed = true, // По умолчанию показывать в ленте (для обратной совместимости)
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'channelId': channelId,
      'title': title,
      'content': content,
      'contentType': contentType,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'views': views,
      'showInFeed': showInFeed,
    };
  }

  factory ChannelPost.fromMap(Map<String, dynamic> map) {
    return ChannelPost(
      id: map['id'] ?? '',
      channelId: map['channelId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      contentType: map['contentType'] ?? 'markdown', // По умолчанию markdown
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      views: map['views'] ?? 0,
      showInFeed: map['showInFeed'] ?? true, // По умолчанию true для старых постов
    );
  }
}

