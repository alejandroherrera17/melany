import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../utils/date_utils.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';

class SalesScreen extends StatefulWidget {
  static const routeName = '/sales';

  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _service = FirestoreService();
  final _quantityController = TextEditingController(text: '1');
  Product? _selectedProduct;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _registerSale(UserProfile profile) async {
    if (_selectedProduct == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _service.registerSale(
        product: _selectedProduct!,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        employeeId: profile.id,
        employeeName: profile.name,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ModalRoute.of(context)!.settings.arguments as UserProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Registrar venta'),
                    const SizedBox(height: 12),
                    StreamBuilder<List<Product>>(
                      stream: _service.streamProducts(),
                      builder: (context, snapshot) {
                        final products = snapshot.data ?? [];
                        _selectedProduct ??= products.isNotEmpty ? products.first : null;
                        return DropdownButtonFormField<Product>(
                          value: _selectedProduct,
                          items: products
                              .map(
                                (product) => DropdownMenuItem(
                                  value: product,
                                  child: Text('${product.name} (Stock: ${product.stock})'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _selectedProduct = value),
                          decoration: const InputDecoration(labelText: 'Producto'),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Cantidad'),
                      keyboardType: TextInputType.number,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : () => _registerSale(profile),
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Guardar venta'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Historial de ventas'),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<List<Sale>>(
                  stream: _service.streamSales(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final sales = snapshot.data!;
                    return ListView.separated(
                      itemCount: sales.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final sale = sales[index];
                        return AppCard(
                          child: ListTile(
                            title: Text(sale.productName),
                            subtitle: Text('${formatDate(sale.createdAt)} • ${sale.employeeName}'),
                            trailing: Text('Total: \$${sale.total.toStringAsFixed(2)}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
