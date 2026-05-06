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