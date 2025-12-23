class Channel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final DateTime createdAt;
  final bool isActive;

  Channel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  factory Channel.fromMap(Map<String, dynamic> map) {
    return Channel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      isActive: map['isActive'] ?? true,
    );
  }
}

