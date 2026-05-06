enum ActivityType {
  lobbyCreated,
  memberAdded,
  memberRemoved,
  expenseAdded,
  expenseEdited,
  expenseDeleted,
  settlementAdded,
}

class ActivityLog {
  final String id;
  final String lobbyId;
  final String userId;
  final ActivityType type;
  final String message;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.lobbyId,
    required this.userId,
    required this.type,
    required this.message,
    required this.createdAt,
  });

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'] ?? '',
      lobbyId: map['lobbyId'] ?? '',
      userId: map['userId'] ?? '',
      type: ActivityType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => ActivityType.expenseAdded,
      ),
      message: map['message'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lobbyId': lobbyId,
      'userId': userId,
      'type': type.name,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}