enum ScheduleSlotStatus { normal, cancelled, reported }

class ScheduleSlot {
  final String subjectName;
  final String teacherId;
  final String teacherName;
  final String room;
  final String startTime; // Format HH:mm
  final String endTime;   // Format HH:mm
  final String type;      // CM, TD, TP
  final ScheduleSlotStatus status;
  final String? cancelReason;
  final String? newSlot;

  ScheduleSlot({
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.status = ScheduleSlotStatus.normal,
    this.cancelReason,
    this.newSlot,
  });

  factory ScheduleSlot.fromMap(Map<String, dynamic> map) {
    return ScheduleSlot(
      subjectName: map['subjectName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      room: map['room'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      type: map['type'] ?? '',
      status: ScheduleSlotStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ScheduleSlotStatus.normal,
      ),
      cancelReason: map['cancelReason'],
      newSlot: map['newSlot'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'room': room,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
      'status': status.toString().split('.').last,
      'cancelReason': cancelReason,
      'newSlot': newSlot,
    };
  }
}

class ScheduleModel {
  final String weekKey; // e.g., 2024-W42
  final List<ScheduleSlot> slots;

  ScheduleModel({
    required this.weekKey,
    required this.slots,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map, String weekKey) {
    return ScheduleModel(
      weekKey: weekKey,
      slots: (map['slots'] as List<dynamic>?)
              ?.map((e) => ScheduleSlot.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slots': slots.map((e) => e.toMap()).toList(),
    };
  }
}
