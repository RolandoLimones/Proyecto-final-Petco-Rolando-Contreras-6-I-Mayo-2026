// lib/screens/productos_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/producto_card.dart';
import '../utils/app_colors.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({Key? key}) : super(key: key);

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).fetchProductos();
    });
  }

  void _showDeleteDialog(BuildContext context, String id, String nombre) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
              side: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            title: const Text(
              '¿Eliminar producto?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            content: Text(
              '¿Estás seguro de que deseas eliminar "$nombre"? Esta acción no se puede deshacer.',
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await Provider.of<ProductsProvider>(
                      context,
                      listen: false,
                    ).deleteProducto(id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '"$nombre" ha sido eliminado con éxito.',
                          ),
                          backgroundColor: AppColors.darkRed,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar producto: $e'),
                          backgroundColor: AppColors.darkRed,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final productsProvider = Provider.of<ProductsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.uid ?? '';

    // Responsive columns
    final crossAxisCount = size.width > 900
        ? 4
        : size.width > 600
        ? 3
        : 2;

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
                'Productos',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22.0,
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
          // Decoraciones de fondo
          Positioned(
            top: 100,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed,
              ),
            ),
          ),
          SafeArea(
            child: productsProvider.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.darkBlue),
                  )
                : productsProvider.productos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 80.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        const Text(
                          'No hay productos.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          '¡Agrega el primero presionando el botón de abajo!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: productsProvider.productos.length,
                    itemBuilder: (context, index) {
                      final product = productsProvider.productos[index];
                      return ProductoCard(
                        producto: product,
                        currentUserId: currentUserId,
                        isAdmin:
                            true, // Siempre mostrar botones (solo admin accede)
                        onEdit: () {
                          context.push(
                            '/productos/edit/${product.id}',
                            extra: product,
                          );
                        },
                        onDelete: () {
                          _showDeleteDialog(
                            context,
                            product.id,
                            product.nombre,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/productos/add');
        },
        backgroundColor: AppColors.darkRed,
        foregroundColor: Colors.white,
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Agregar Producto',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
