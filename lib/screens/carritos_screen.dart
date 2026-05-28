// lib/screens/carritos_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/carritos_provider.dart';
import '../providers/clients_provider.dart';
import '../models/carrito_model.dart';
import '../utils/app_colors.dart';

class CarritosScreen extends StatefulWidget {
  const CarritosScreen({Key? key}) : super(key: key);

  @override
  State<CarritosScreen> createState() => _CarritosScreenState();
}

class _CarritosScreenState extends State<CarritosScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Cargar clientes (necesario para mostrar nombres)
    final clientsProvider = Provider.of<ClientsProvider>(
      context,
      listen: false,
    );
    await clientsProvider.fetchClientes();

    // Cargar carritos
    final carritosProvider = Provider.of<CarritosProvider>(
      context,
      listen: false,
    );
    await carritosProvider.fetchCarritos(); // ← AÑADIR ESTA LÍNEA
  }

  @override
  Widget build(BuildContext context) {
    final carritosProvider = Provider.of<CarritosProvider>(context);
    final carritos = carritosProvider.carritos;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Carritos de Clientes'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.white.withOpacity(0.4)),
          ),
        ),
      ),
      body: carritosProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : carritos.isEmpty
          ? const Center(child: Text('No hay carritos registrados'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: carritos.length,
              itemBuilder: (context, index) {
                final carrito = carritos[index];
                return Card(
                  color: Colors.white.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.darkBlue,
                      child: Icon(Icons.shopping_cart, color: Colors.white),
                    ),
                    title: Text(
                      carrito.userName.isNotEmpty
                          ? carrito.userName
                          : carrito.userId,
                    ),
                    subtitle: Text('${carrito.items.length} producto(s)'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.darkBlue,
                          ),
                          onPressed: () {
                            context.push(
                              '/carritos/edit/${carrito.userId}',
                              extra: carrito,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.darkRed,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Eliminar carrito'),
                                content: Text(
                                  '¿Eliminar carrito de ${carrito.userName}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await carritosProvider.deleteCarrito(
                                carrito.userId,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Carrito eliminado'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkBlue,
        child: const Icon(Icons.add),
        onPressed: () {
          context.push('/carritos/add');
        },
      ),
    );
  }
}
