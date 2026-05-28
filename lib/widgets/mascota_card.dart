import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/mascota_model.dart';
import '../utils/app_colors.dart';

class MascotaCard extends StatelessWidget {
  final Mascota mascota;
  final String currentUserId;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MascotaCard({
    Key? key,
    required this.mascota,
    required this.currentUserId,
    this.isAdmin = false,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  Color _getSpeciesColor(String especie) {
    switch (especie.toLowerCase()) {
      case 'perro':
        return AppColors.primaryBlue;
      case 'gato':
        return AppColors.primaryRed;
      default:
        return const Color(0xFFC3E5D8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getSpeciesColor(mascota.especie);
    final isOwner = mascota.clienteId == currentUserId;
    final canModify = isAdmin || isOwner;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: AppColors.glassDecoration(borderRadius: 16.0),
          padding: const EdgeInsets.all(10.0), // Reducido de 12 a 10
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize:
                MainAxisSize.min, // 👈 Clave para evitar espacio vacío
            children: [
              Center(
                child: CircleAvatar(
                  radius: 30.0, // Reducido de 36 a 30
                  backgroundColor: avatarColor,
                  child: const Icon(
                    Icons.pets_rounded,
                    size: 30.0, // Reducido de 36 a 30
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10.0), // Reducido de 12 a 10
              Text(
                mascota.nombre,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.0, // Reducido de 16 a 14
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${mascota.especie} • ${mascota.raza}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.0, // Reducido de 12 a 11
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 8.0,
              ), // Espacio antes del Row (reemplaza el Spacer)
              Row(
                children: [
                  // 👇 Información de edad/peso con Expanded para que no empuje
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${mascota.edad} ${mascota.edad == 1 ? 'año' : 'años'}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.0, // Reducido de 13 a 12
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (mascota.peso != null)
                          Text(
                            '${mascota.peso} kg',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.0, // Reducido de 11 a 10
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (canModify)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18.0, // Reducido de 20 a 18
                            color: AppColors.darkBlue,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onEdit,
                        ),
                        const SizedBox(width: 4.0), // Reducido de 8 a 4
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18.0, // Reducido de 20 a 18
                            color: AppColors.darkRed,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
