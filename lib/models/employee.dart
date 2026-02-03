class Employee {
  final String id;
  final String name;
  final String contractType;
  final String payType;
  final double rate;
  final DateTime createdAt;

  Employee({
    required this.id,
    required this.name,
    required this.contractType,
    required this.payType,
    required this.rate,
    required this.createdAt,
  });

  factory Employee.fromMap(String id, Map<String, dynamic> data) {
    return Employee(
      id: id,
      name: data['name'] as String? ?? '',
      contractType: data['contractType'] as String? ?? '',
      payType: data['payType'] as String? ?? 'daily',
      rate: (data['rate'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contractType': contractType,
      'payType': payType,
      'rate': rate,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
