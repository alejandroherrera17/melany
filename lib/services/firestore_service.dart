import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/expense.dart';
import '../models/employee.dart';
import '../models/workday.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> streamProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addProduct(Product product) async {
    await _db.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  Stream<List<Sale>> streamSales() {
    return _db.collection('sales').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Sale.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> registerSale({
    required Product product,
    required int quantity,
    required String employeeId,
    required String employeeName,
  }) async {
    final saleRef = _db.collection('sales').doc();
    final productRef = _db.collection('products').doc(product.id);
    await _db.runTransaction((transaction) async {
      final productSnap = await transaction.get(productRef);
      final data = productSnap.data() as Map<String, dynamic>;
      final currentStock = (data['stock'] as num?)?.toInt() ?? 0;
      if (currentStock < quantity) {
        throw Exception('Stock insuficiente');
      }
      final newStock = currentStock - quantity;
      transaction.update(productRef, {'stock': newStock});
      final total = product.price * quantity;
      transaction.set(saleRef, Sale(
        id: saleRef.id,
        productId: product.id,
        productName: product.name,
        quantity: quantity,
        unitPrice: product.price,
        total: total,
        employeeId: employeeId,
        employeeName: employeeName,
        createdAt: DateTime.now(),
      ).toMap());
    });
  }

  Stream<List<Expense>> streamExpenses() {
    return _db.collection('expenses').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Expense.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addExpense(Expense expense) async {
    await _db.collection('expenses').add(expense.toMap());
  }

  Stream<List<Employee>> streamEmployees() {
    return _db.collection('employees').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Employee.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addEmployee(Employee employee) async {
    await _db.collection('employees').add(employee.toMap());
  }

  Future<void> addWorkday(Workday workday) async {
    await _db.collection('workdays').add(workday.toMap());
  }

  Stream<List<Workday>> streamWorkdaysForEmployee(String employeeId) {
    return _db
        .collection('workdays')
        .where('employeeId', isEqualTo: employeeId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workday.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> reportSalesByDate({
    required DateTime start,
  }) {
    return _db
        .collection('sales')
        .where('createdAt', isGreaterThanOrEqualTo: start.toIso8601String())
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> reportExpensesByDate({
    required DateTime start,
  }) {
    return _db
        .collection('expenses')
        .where('createdAt', isGreaterThanOrEqualTo: start.toIso8601String())
        .snapshots();
  }
}
