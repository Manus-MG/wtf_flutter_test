class SessionLog {
  const SessionLog({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    this.rating,
    this.trainerNotes,
    this.memberNotes,
  });

  final String id;
  final String memberId;
  final String trainerId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSec;
  final int? rating;
  final String? trainerNotes;
  final String? memberNotes;

  Map<String, Object?> toJson() => {
        'id': id,
        'memberId': memberId,
        'trainerId': trainerId,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'durationSec': durationSec,
        'rating': rating,
        'trainerNotes': trainerNotes,
        'memberNotes': memberNotes,
      };

  factory SessionLog.fromJson(Map<String, Object?> json) {
    return SessionLog(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      durationSec: json['durationSec'] as int,
      rating: json['rating'] as int?,
      trainerNotes: json['trainerNotes'] as String?,
      memberNotes: json['memberNotes'] as String?,
    );
  }
}
