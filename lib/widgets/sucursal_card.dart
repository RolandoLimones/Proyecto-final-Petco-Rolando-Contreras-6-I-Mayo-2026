import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/sucursal_model.dart';
import '../utils/app_colors.dart';

class SucursalCard extends StatelessWidget {
  final Sucursal sucursal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SucursalCard({
    Key? key,
    required this.sucursal,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: AppColors.glassDecoration(borderRadius: 16.0),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.store_mall_directory_rounded,
                      color: AppColors.darkBlue,
                      size: 24.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      sucursal.nombre,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_rounded, size: 16.0, color: AppColors.textSecondary),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      sucursal.direccion,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.0,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              Row(
                children: [
                  const Icon(Icons.phone_rounded, size: 16.0, color: AppColors.textSecondary),
                  const SizedBox(width: 8.0),
                  Text(
                    sucursal.telefono,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  const Icon(Icons.access_time_filled_rounded, size: 16.0, color: AppColors.textSecondary),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      sucursal.horario,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.0,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20.0, color: AppColors.darkBlue),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20.0, color: AppColors.darkRed),
                    onPressed: onDelete,
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
