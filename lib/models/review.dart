class Review {
  final String id;
  final String title;
  final String content;
  final String contentType; // 'markdown' или 'quill'
  final String? imageUrl;
  final String? videoUrl;
  final String category; // Категория обзора: 'market', 'technical', 'fundamental', etc.
  final List<String> tags; // Теги для фильтрации
  final DateTime createdAt;
  final int views;
  final String authorId;
  final String authorName;
  final String? sourcePostId; // ID исходного поста (если создан из поста канала)
  final String? sourceChannelId; // ID исходного канала (если создан из поста канала)

  Review({
    required this.id,
    required this.title,
    required this.content,
    this.contentType = 'markdown',
    this.imageUrl,
    this.videoUrl,
    required this.category,
    this.tags = const [],
    required this.createdAt,
    this.views = 0,
    required this.authorId,
    required this.authorName,
    this.sourcePostId,
    this.sourceChannelId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'contentType': contentType,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'category': category,
      'tags': tags,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'views': views,
      'authorId': authorId,
      'authorName': authorName,
      'sourcePostId': sourcePostId,
      'sourceChannelId': sourceChannelId,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      contentType: map['contentType'] ?? 'markdown',
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      category: map['category'] ?? 'market',
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      views: map['views'] ?? 0,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      sourcePostId: map['sourcePostId'],
      sourceChannelId: map['sourceChannelId'],
    );
  }

  Review copyWith({
    String? id,
    String? title,
    String? content,
    String? contentType,
    String? imageUrl,
    String? videoUrl,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    int? views,
    String? authorId,
    String? authorName,
    String? sourcePostId,
    String? sourceChannelId,
  }) {
    return Review(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      sourcePostId: sourcePostId ?? this.sourcePostId,
      sourceChannelId: sourceChannelId ?? this.sourceChannelId,
    );
  }
}
