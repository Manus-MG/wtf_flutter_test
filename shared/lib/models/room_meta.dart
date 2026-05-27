class RoomMeta {
  const RoomMeta({
    required this.id,
    required this.callRequestId,
    required this.hmsRoomId,
    required this.hmsRoleMember,
    required this.hmsRoleTrainer,
  });

  final String id;
  final String callRequestId;
  final String hmsRoomId;
  final String hmsRoleMember;
  final String hmsRoleTrainer;

  Map<String, Object?> toJson() => {
        'id': id,
        'callRequestId': callRequestId,
        'hmsRoomId': hmsRoomId,
        'hmsRoleMember': hmsRoleMember,
        'hmsRoleTrainer': hmsRoleTrainer,
      };

  factory RoomMeta.fromJson(Map<String, Object?> json) {
    return RoomMeta(
      id: json['id'] as String,
      callRequestId: json['callRequestId'] as String,
      hmsRoomId: json['hmsRoomId'] as String,
      hmsRoleMember: json['hmsRoleMember'] as String,
      hmsRoleTrainer: json['hmsRoleTrainer'] as String,
    );
  }
}
