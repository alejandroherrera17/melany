class Sale {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;
  final String employeeId;
  final String employeeName;
  final DateTime createdAt;

  Sale({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.employeeId,
    required this.employeeName,
    required this.createdAt,
  });

  factory Sale.fromMap(String id, Map<String, dynamic> data) {
    return Sale(
      id: id,
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      employeeId: data['employeeId'] as String? ?? '',
      employeeName: data['employeeName'] as String? ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
