import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/proveedor_model.dart';
import '../utils/app_colors.dart';

class ProveedorCard extends StatelessWidget {
  final Proveedor proveedor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProveedorCard({
    Key? key,
    required this.proveedor,
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
                      color: AppColors.primaryRed.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: AppColors.darkRed,
                      size: 24.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      proveedor.nombre,
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
                children: [
                  const Icon(Icons.person_rounded, size: 16.0, color: AppColors.textSecondary),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Contacto: ${proveedor.contacto}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.0,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
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
                    proveedor.telefono,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              Row(
                children: [
                  const Icon(Icons.email_rounded, size: 16.0, color: AppColors.textSecondary),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      proveedor.email,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.0,
                        color: AppColors.textPrimary,
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
