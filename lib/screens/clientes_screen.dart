import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/clients_provider.dart';
import '../widgets/cliente_card.dart';
import '../utils/app_colors.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({Key? key}) : super(key: key);

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ClientsProvider>(context, listen: false).fetchClientes());
  }

  void _deleteConfirm(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Cliente?', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text('¿Está seguro de que desea eliminar este cliente? Esta acción no se puede deshacer.', style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await Provider.of<ClientsProvider>(context, listen: false).deleteCliente(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cliente eliminado con éxito'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: AppColors.darkRed),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkRed),
            child: const Text('Eliminar', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClientsProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clientes'),
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
            top: -20,
            left: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue),
            ),
          ),
          provider.loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.darkBlue))
              : provider.clientes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_alt_rounded, size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay clientes registrados',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size.width > 900 ? 3 : (size.width > 600 ? 2 : 1),
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: provider.clientes.length,
                      itemBuilder: (context, index) {
                        final item = provider.clientes[index];
                        return ClienteCard(
                          cliente: item,
                          onEdit: () {
                            context.push('/clientes/edit/${item.id}', extra: item);
                          },
                          onDelete: () => _deleteConfirm(context, item.id),
                        );
                      },
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/clientes/add');
        },
        backgroundColor: AppColors.darkBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
