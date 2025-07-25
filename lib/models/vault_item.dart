class VaultItem {
  final String id;
  final String title;
  final String content;
  final VaultItemType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaultItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'type': type.index,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory VaultItem.fromJson(Map<String, dynamic> json) => VaultItem(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    type: VaultItemType.values[json['type']],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

enum VaultItemType { note, password, file, image }