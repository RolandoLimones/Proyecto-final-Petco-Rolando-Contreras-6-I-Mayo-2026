import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/products_provider.dart';
import '../models/producto_model.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';
import '../providers/branches_provider.dart';
import '../providers/providers_provider.dart';

class EditProductoScreen extends StatefulWidget {
  final String id;
  final Producto? producto;

  const EditProductoScreen({Key? key, required this.id, this.producto})
    : super(key: key);

  @override
  State<EditProductoScreen> createState() => _EditProductoScreenState();
}

class _EditProductoScreenState extends State<EditProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  late TextEditingController _imagenUrlController;
  String? _selectedSucursalId;
  String? _selectedProveedorId;

  late String _selectedCategoria;
  final List<String> _categorias = [
    'Alimento',
    'Juguetes',
    'Accesorios',
    'Higiene',
    'Otros',
  ];

  Producto? _currentProducto;

  @override
  void initState() {
    super.initState();
    // Retrieve product either from widget arguments or from products provider using ID
    final productsProvider = Provider.of<ProductsProvider>(
      context,
      listen: false,
    );
    _currentProducto =
        widget.producto ??
        productsProvider.productos.firstWhere(
          (p) => p.id == widget.id,
          orElse: () => Producto(
            id: widget.id,
            nombre: '',
            descripcion: '',
            precio: 0.0,
            categoria: 'Alimento',
            creadorId: '',
          ),
        );

    _nombreController = TextEditingController(text: _currentProducto?.nombre);
    _descripcionController = TextEditingController(
      text: _currentProducto?.descripcion,
    );
    _precioController = TextEditingController(
      text: _currentProducto?.precio.toString(),
    );
    _imagenUrlController = TextEditingController(
      text: _currentProducto?.imagenUrl ?? '',
    );
    _selectedCategoria = _categorias.contains(_currentProducto?.categoria)
        ? _currentProducto!.categoria
        : 'Alimento';
    _selectedSucursalId = _currentProducto?.sucursalId;
    _selectedProveedorId = _currentProducto?.proveedorId;

    // Cargar listas para dropdowns
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final branchesProvider = Provider.of<BranchesProvider>(
        context,
        listen: false,
      );
      if (branchesProvider.sucursales.isEmpty)
        branchesProvider.fetchSucursales();
      final providersProvider = Provider.of<ProvidersProvider>(
        context,
        listen: false,
      );
      if (providersProvider.proveedores.isEmpty)
        providersProvider.fetchProveedores();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentProducto == null) return;

    final productsProvider = Provider.of<ProductsProvider>(
      context,
      listen: false,
    );

    final updatedProducto = _currentProducto!.copyWith(
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      precio: double.parse(_precioController.text),
      categoria: _selectedCategoria,
      imagenUrl: _imagenUrlController.text.trim().isEmpty
          ? null
          : _imagenUrlController.text.trim(),
      sucursalId: _selectedSucursalId,
      proveedorId: _selectedProveedorId,
    );

    try {
      await productsProvider.updateProducto(updatedProducto);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${updatedProducto.nombre}" modificado con éxito.'),
            backgroundColor: AppColors.darkBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al modificar producto: $e'),
            backgroundColor: AppColors.darkRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);

    if (_currentProducto == null || _currentProducto!.creadorId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Editar Producto')),
        body: const Center(
          child: Text('Producto no encontrado o inaccesible.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.6),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => context.pop(),
              ),
              title: const Text(
                'Editar Producto',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: AppColors.glassDecoration(borderRadius: 24.0),
                      padding: const EdgeInsets.all(28.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Modificar Detalles del Producto',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 24.0),

                            // Name
                            CustomTextField(
                              controller: _nombreController,
                              labelText: 'Nombre del producto',
                              prefixIcon: const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.textSecondary,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingresa el nombre del producto';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Description
                            CustomTextField(
                              controller: _descripcionController,
                              labelText: 'Descripción',
                              maxLines: 3,
                              prefixIcon: const Icon(
                                Icons.description_outlined,
                                color: AppColors.textSecondary,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingresa una descripción';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Price
                            CustomTextField(
                              controller: _precioController,
                              labelText: 'Precio (\$)',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              prefixIcon: const Icon(
                                Icons.attach_money_rounded,
                                color: AppColors.textSecondary,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingresa el precio';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Ingresa un número válido';
                                }
                                if (double.parse(value) <= 0) {
                                  return 'El precio debe ser mayor a 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Category Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedCategoria,
                              decoration: InputDecoration(
                                labelText: 'Categoría',
                                labelStyle: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14.0,
                                  color: AppColors.textSecondary,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.65),
                                prefixIcon: const Icon(
                                  Icons.category_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.darkBlue,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.0,
                                color: AppColors.textPrimary,
                              ),
                              items: _categorias.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedCategoria = newValue;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Image URL
                            CustomTextField(
                              controller: _imagenUrlController,
                              labelText: 'URL de Imagen (Opcional)',
                              prefixIcon: const Icon(
                                Icons.image_outlined,
                                color: AppColors.textSecondary,
                              ),
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 32.0),

                            // Sucursal dropdown
                            Consumer<BranchesProvider>(
                              builder: (context, branchesProvider, _) {
                                final sucursales = branchesProvider.sucursales;
                                return DropdownButtonFormField<String>(
                                  value: _selectedSucursalId,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'Sucursal (Opcional)',
                                    labelStyle: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14.0,
                                      color: AppColors.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.65),
                                    prefixIcon: const Icon(
                                      Icons.store_mall_directory_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: AppColors.darkBlue,
                                      ),
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Ninguna'),
                                    ),
                                    ...sucursales.map(
                                      (s) => DropdownMenuItem<String>(
                                        value: s.id,
                                        child: Text(s.nombre),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) => setState(
                                    () => _selectedSucursalId = value,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 16.0),

                            // Proveedor dropdown
                            Consumer<ProvidersProvider>(
                              builder: (context, providersProvider, _) {
                                final proveedores =
                                    providersProvider.proveedores;
                                return DropdownButtonFormField<String>(
                                  value: _selectedProveedorId,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'Proveedor (Opcional)',
                                    labelStyle: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14.0,
                                      color: AppColors.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.65),
                                    prefixIcon: const Icon(
                                      Icons.local_shipping_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: AppColors.darkBlue,
                                      ),
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Ninguno'),
                                    ),
                                    ...proveedores.map(
                                      (p) => DropdownMenuItem<String>(
                                        value: p.id,
                                        child: Text(p.nombre),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) => setState(
                                    () => _selectedProveedorId = value,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Buttons row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                ElevatedButton(
                                  onPressed: productsProvider.loading
                                      ? null
                                      : _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkRed,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                      vertical: 12.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: productsProvider.loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.0,
                                          ),
                                        )
                                      : const Text(
                                          'Guardar',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
