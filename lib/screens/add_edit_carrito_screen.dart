// lib/screens/add_edit_carrito_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/carrito_model.dart';
import '../models/cart_item_model.dart';
import '../models/producto_model.dart';
import '../models/cliente_model.dart';
import '../providers/carritos_provider.dart';
import '../providers/products_provider.dart';
import '../providers/clients_provider.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

class AddEditCarritoScreen extends StatefulWidget {
  final String? userId; // ID del documento (clienteId) para edición
  final Carrito? carrito;

  const AddEditCarritoScreen({Key? key, this.userId, this.carrito})
    : super(key: key);

  @override
  State<AddEditCarritoScreen> createState() => _AddEditCarritoScreenState();
}

class _AddEditCarritoScreenState extends State<AddEditCarritoScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<CartItem> _items;
  Cliente? _selectedCliente;
  List<Cliente> _clientes = [];
  bool _loadingClientes = true;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.userId != null || widget.carrito != null;
    _items = widget.carrito?.items ?? [];
    _loadData();
  }

  // lib/screens/add_edit_carrito_screen.dart (fragmento modificado)

  Future<void> _loadData() async {
    final clientsProvider = Provider.of<ClientsProvider>(
      context,
      listen: false,
    );
    final productsProvider = Provider.of<ProductsProvider>(
      context,
      listen: false,
    );

    // Cargar clientes y productos
    await Future.wait([
      clientsProvider.fetchClientes(),
      productsProvider.fetchProductos(),
    ]);

    setState(() {
      _clientes = clientsProvider.clientes;
      _loadingClientes = false;
    });

    if (_isEdit && widget.carrito != null) {
      _selectedCliente = _clientes.firstWhere(
        (c) => c.id == widget.carrito!.userId,
        orElse: () => _clientes.first,
      );
    } else if (_isEdit && widget.userId != null) {
      final carritosProvider = Provider.of<CarritosProvider>(
        context,
        listen: false,
      );
      await carritosProvider.fetchCarritos();
      final carritoExistente = carritosProvider.carritos.firstWhere(
        (c) => c.userId == widget.userId,
        orElse: () => Carrito(userId: '', userName: '', items: []),
      );
      if (carritoExistente.userId.isNotEmpty) {
        _items = carritoExistente.items;
        _selectedCliente = _clientes.firstWhere(
          (c) => c.id == carritoExistente.userId,
          orElse: () => _clientes.first,
        );
      }
    }
  }

  Future<void> _addProduct() async {
    final productsProvider = Provider.of<ProductsProvider>(
      context,
      listen: false,
    );
    if (productsProvider.productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay productos disponibles'),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return;
    }

    Producto? selectedProduct;
    int quantity = 1;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: AppColors.glassDecoration(borderRadius: 20),
                child: StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Agregar producto',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Producto>(
                          isExpanded: true, // 👈 EVITA EL OVERFLOW
                          decoration: const InputDecoration(
                            labelText: 'Producto',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ), // 👈 Ajuste
                          ),
                          items: productsProvider.productos.map((p) {
                            return DropdownMenuItem<Producto>(
                              value: p,
                              child: Text(
                                p.nombre,
                                overflow: TextOverflow
                                    .ellipsis, // 👈 Por si el nombre es muy largo
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setStateDialog(() => selectedProduct = value);
                          },
                          validator: (v) =>
                              v == null ? 'Seleccione un producto' : null,
                        ),
                        const SizedBox(height: 16),
                        // Usamos TextFormField normal, no CustomTextField, para initialValue
                        TextFormField(
                          initialValue: '1',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Cantidad',
                          ),
                          onChanged: (value) {
                            quantity = int.tryParse(value) ?? 1;
                            if (quantity < 1) quantity = 1;
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (selectedProduct != null && quantity > 0) {
                                  final existingIndex = _items.indexWhere(
                                    (i) => i.id == selectedProduct!.id,
                                  );
                                  if (existingIndex != -1) {
                                    _items[existingIndex].cantidad += quantity;
                                    setState(() {});
                                  } else {
                                    _items.add(
                                      CartItem(
                                        id: selectedProduct!.id,
                                        nombre: selectedProduct!.nombre,
                                        precio: selectedProduct!.precio,
                                        cantidad: quantity,
                                        imagenUrl: selectedProduct!.imagenUrl,
                                      ),
                                    );
                                  }
                                  Navigator.pop(ctx);
                                }
                              },
                              child: const Text('Agregar'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
    setState(() {});
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(index);
    } else {
      setState(() {
        _items[index].cantidad = newQuantity;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un cliente'),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agregue al menos un producto'),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return;
    }

    final carrito = Carrito(
      userId: _selectedCliente!.id,
      userName: _selectedCliente!.nombre,
      items: _items,
    );

    final provider = Provider.of<CarritosProvider>(context, listen: false);
    try {
      if (_isEdit) {
        // Actualizar: usar updateCarrito con el userId existente
        await provider.updateCarrito(_selectedCliente!.id, carrito);
      } else {
        await provider.addCarrito(carrito);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Carrito actualizado' : 'Carrito creado'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.darkRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Carrito' : 'Crear Carrito'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.white.withOpacity(0.4)),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 600),
                    decoration: AppColors.glassDecoration(borderRadius: 24.0),
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isEdit
                                ? Icons.shopping_cart_rounded
                                : Icons.add_shopping_cart_rounded,
                            size: 48,
                            color: AppColors.darkBlue,
                          ),
                          const SizedBox(height: 24.0),
                          if (_loadingClientes)
                            const CircularProgressIndicator()
                          else
                            DropdownButtonFormField<Cliente>(
                              value: _selectedCliente,
                              decoration: const InputDecoration(
                                labelText: 'Cliente',
                              ),
                              items: _clientes.map((c) {
                                return DropdownMenuItem<Cliente>(
                                  value: c,
                                  child: Text(c.nombre),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedCliente = value),
                              validator: (v) =>
                                  v == null ? 'Seleccione un cliente' : null,
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'Productos en el carrito',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (_items.isEmpty)
                            const Text(
                              'No hay productos',
                              style: TextStyle(color: AppColors.textSecondary),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.nombre,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '\$${item.precio.toStringAsFixed(2)}',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove,
                                                size: 20,
                                              ),
                                              onPressed: () => _updateQuantity(
                                                index,
                                                item.cantidad - 1,
                                              ),
                                            ),
                                            Text(item.cantidad.toString()),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add,
                                                size: 20,
                                              ),
                                              onPressed: () => _updateQuantity(
                                                index,
                                                item.cantidad + 1,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: AppColors.darkRed,
                                              ),
                                              onPressed: () =>
                                                  _removeItem(index),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addProduct,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar producto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                              ),
                              child: const Text(
                                'Guardar Carrito',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
