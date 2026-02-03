class Workday {
  final String id;
  final String employeeId;
  final DateTime date;

  Workday({
    required this.id,
    required this.employeeId,
    required this.date,
  });

  factory Workday.fromMap(String id, Map<String, dynamic> data) {
    return Workday(
      id: id,
      employeeId: data['employeeId'] as String? ?? '',
      date: DateTime.tryParse(data['date'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'date': date.toIso8601String(),
    };
  }
}
