import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/pets_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/mascota_card.dart';
import '../utils/app_colors.dart';

class MascotasScreen extends StatefulWidget {
  const MascotasScreen({Key? key}) : super(key: key);

  @override
  State<MascotasScreen> createState() => _MascotasScreenState();
}

class _MascotasScreenState extends State<MascotasScreen> {
  bool _isAdmin = false;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _determineRoleAndLoad();
  }

  Future<void> _determineRoleAndLoad() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.user?.uid ?? '';
    if (uid.isEmpty) return;

    final firestoreService = FirestoreService();
    final cliente = await firestoreService.getClienteById(uid);
    final isAdmin = cliente == null;

    setState(() {
      _isAdmin = isAdmin;
      _loadingRole = false;
    });

    final petsProvider = Provider.of<PetsProvider>(context, listen: false);
    if (isAdmin) {
      await petsProvider.fetchAllMascotas();
    } else {
      await petsProvider.fetchMascotas(uid);
    }
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
              '¿Eliminar mascota?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            content: Text(
              '¿Estás seguro de que deseas eliminar a "$nombre"? Esta acción eliminará su registro de forma permanente.',
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
                    await Provider.of<PetsProvider>(
                      context,
                      listen: false,
                    ).deleteMascota(id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'El registro de "$nombre" ha sido eliminado.',
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
                          content: Text('Error al eliminar mascota: $e'),
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
    final petsProvider = Provider.of<PetsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.uid ?? '';

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
              title: Text(
                _isAdmin ? 'Todas las Mascotas' : 'Mis Mascotas',
                style: const TextStyle(
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
          Positioned(
            top: 100,
            left: -40,
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
            right: -40,
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
            child: _loadingRole
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.darkBlue),
                  )
                : petsProvider.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.darkBlue),
                  )
                : petsProvider.mascotas.isEmpty
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
                            Icons.pets_rounded,
                            size: 80.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        const Text(
                          'No hay mascotas registradas.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          '¡Agrega una mascota presionando el botón de abajo!',
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
                    itemCount: petsProvider.mascotas.length,
                    itemBuilder: (context, index) {
                      final mascota = petsProvider.mascotas[index];
                      return MascotaCard(
                        mascota: mascota,
                        currentUserId: currentUserId,
                        isAdmin: _isAdmin,
                        onEdit: () {
                          context.push(
                            '/mascotas/edit/${mascota.id}',
                            extra: mascota,
                          );
                        },
                        onDelete: () {
                          _showDeleteDialog(
                            context,
                            mascota.id,
                            mascota.nombre,
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
          context.push('/mascotas/add');
        },
        backgroundColor: AppColors.darkRed,
        foregroundColor: Colors.white,
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Agregar Mascota',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
