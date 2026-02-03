class Product {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final int stock;
  final double price;
  final double cost;
  final int lowStockThreshold;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.stock,
    required this.price,
    required this.cost,
    required this.lowStockThreshold,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      subcategory: data['subcategory'] as String? ?? '',
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0,
      cost: (data['cost'] as num?)?.toDouble() ?? 0,
      lowStockThreshold: (data['lowStockThreshold'] as num?)?.toInt() ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'stock': stock,
      'price': price,
      'cost': cost,
      'lowStockThreshold': lowStockThreshold,
    };
  }
}
