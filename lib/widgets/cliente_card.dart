import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/cliente_model.dart';
import '../utils/app_colors.dart';

class ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClienteCard({
    Key? key,
    required this.cliente,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initial = cliente.nombre.isNotEmpty ? cliente.nombre[0].toUpperCase() : '?';

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
                  CircleAvatar(
                    radius: 24.0,
                    backgroundColor: AppColors.primaryBlue,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.nombre,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          cliente.email,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.0,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              if (cliente.telefono.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.phone_rounded, size: 16.0, color: AppColors.textSecondary),
                    const SizedBox(width: 8.0),
                    Text(
                      cliente.telefono,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.0,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              if (cliente.direccion.isNotEmpty) ...[
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16.0, color: AppColors.textSecondary),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        cliente.direccion,
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
              ],
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
