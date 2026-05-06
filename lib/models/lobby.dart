class Lobby {
  final String id;
  final String name;
  final String description;
  final String createdByUserId;
  final List<String> memberIds;
  final String inviteCode;
  final DateTime createdAt;

  Lobby({
    required this.id,
    required this.name,
    required this.description,
    required this.createdByUserId,
    required this.memberIds,
    required this.inviteCode,
    required this.createdAt,
  });

  Lobby copyWith({
    String? id,
    String? name,
    String? description,
    String? createdByUserId,
    List<String>? memberIds,
    String? inviteCode,
    DateTime? createdAt,
  }) {
    return Lobby(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      memberIds: memberIds ?? this.memberIds,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Lobby.fromMap(Map<String, dynamic> map) {
    return Lobby(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdByUserId: map['createdByUserId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      inviteCode: map['inviteCode'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdByUserId': createdByUserId,
      'memberIds': memberIds,
      'inviteCode': inviteCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}