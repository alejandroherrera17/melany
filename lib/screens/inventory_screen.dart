import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';

class InventoryScreen extends StatelessWidget {
  static const routeName = '/inventory';

  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = ModalRoute.of(context)!.settings.arguments as UserProfile;
    final isAdmin = profile.role == 'admin';
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showProductDialog(context, service),
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: StreamBuilder<List<Product>>(
          stream: service.streamProducts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final products = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Productos'),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final lowStock = product.stock <= product.lowStockThreshold;
                        return AppCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(product.name),
                            subtitle: Text('${product.category} • ${product.subcategory}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Stock: ${product.stock}'),
                                if (lowStock)
                                  Text(
                                    'Stock bajo',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                            onTap: isAdmin
                                ? () => _showProductDialog(context, service, product: product)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showProductDialog(
    BuildContext context,
    FirestoreService service, {
    Product? product,
  }) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final categoryController = TextEditingController(text: product?.category ?? '');
    final subcategoryController = TextEditingController(text: product?.subcategory ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final costController = TextEditingController(text: product?.cost.toString() ?? '');
    final thresholdController =
        TextEditingController(text: product?.lowStockThreshold.toString() ?? '5');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Nuevo producto' : 'Editar producto'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: subcategoryController,
                  decoration: const InputDecoration(labelText: 'Subcategoría'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Precio de venta'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: costController,
                  decoration: const InputDecoration(labelText: 'Costo'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: thresholdController,
                  decoration: const InputDecoration(labelText: 'Alerta stock bajo'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (product != null)
            TextButton(
              onPressed: () async {
                await service.deleteProduct(product.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Eliminar'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newProduct = Product(
                id: product?.id ?? '',
                name: nameController.text.trim(),
                category: categoryController.text.trim(),
                subcategory: subcategoryController.text.trim(),
                stock: int.tryParse(stockController.text) ?? 0,
                price: double.tryParse(priceController.text) ?? 0,
                cost: double.tryParse(costController.text) ?? 0,
                lowStockThreshold: int.tryParse(thresholdController.text) ?? 5,
              );
              if (product == null) {
                await service.addProduct(newProduct);
              } else {
                await service.updateProduct(newProduct);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
