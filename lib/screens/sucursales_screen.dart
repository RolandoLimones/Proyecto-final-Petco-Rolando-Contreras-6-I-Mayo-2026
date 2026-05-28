import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/branches_provider.dart';
import '../widgets/sucursal_card.dart';
import '../utils/app_colors.dart';

class SucursalesScreen extends StatefulWidget {
  const SucursalesScreen({Key? key}) : super(key: key);

  @override
  State<SucursalesScreen> createState() => _SucursalesScreenState();
}

class _SucursalesScreenState extends State<SucursalesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<BranchesProvider>(context, listen: false).fetchSucursales());
  }

  void _deleteConfirm(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Sucursal?', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text('¿Está seguro de que desea eliminar esta sucursal? Esta acción no se puede deshacer.', style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await Provider.of<BranchesProvider>(context, listen: false).deleteSucursal(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sucursal eliminada con éxito'), backgroundColor: Colors.green),
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
    final provider = Provider.of<BranchesProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sucursales'),
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
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue),
            ),
          ),
          provider.loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.darkBlue))
              : provider.sucursales.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.storefront_rounded, size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay sucursales registradas',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size.width > 900 ? 3 : (size.width > 600 ? 2 : 1),
                        childAspectRatio: 1.6,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: provider.sucursales.length,
                      itemBuilder: (context, index) {
                        final item = provider.sucursales[index];
                        return SucursalCard(
                          sucursal: item,
                          onEdit: () {
                            context.push('/sucursales/edit/${item.id}', extra: item);
                          },
                          onDelete: () => _deleteConfirm(context, item.id),
                        );
                      },
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/sucursales/add');
        },
        backgroundColor: AppColors.darkBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
