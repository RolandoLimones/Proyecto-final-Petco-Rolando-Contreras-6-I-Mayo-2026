// lib/widgets/producto_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../utils/app_colors.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final String currentUserId;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductoCard({
    Key? key,
    required this.producto,
    required this.currentUserId,
    this.isAdmin = false,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  Color _getPastelColor(String name) {
    if (name.isEmpty) return AppColors.primaryBlue;
    final charCode = name.toUpperCase().codeUnitAt(0);
    final colors = [
      AppColors.primaryBlue,
      AppColors.primaryRed,
      const Color(0xFFC3E5D8),
      const Color(0xFFE2C9F3),
      const Color(0xFFF7E2AD),
      const Color(0xFFF9C5D1),
      const Color(0xFFC5F3E2),
    ];
    return colors[charCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bool showButtons = isAdmin || producto.creadorId == currentUserId;
    final initial = producto.nombre.isNotEmpty
        ? producto.nombre[0].toUpperCase()
        : '?';
    final avatarColor = _getPastelColor(producto.nombre);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: AppColors.glassDecoration(borderRadius: 12.0),
          padding: const EdgeInsets.all(8.0),
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar centrado
              Center(
                child:
                    producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28.0),
                        child: Image.network(
                          producto.imagenUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => CircleAvatar(
                            radius: 28.0,
                            backgroundColor: avatarColor,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 28.0,
                        backgroundColor: avatarColor,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 8.0),
              // Nombre
              Text(
                producto.nombre,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Categoría
              Text(
                producto.categoria,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6.0),
              // Precio y botones (pegado al final)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '\$${producto.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkRed,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showButtons)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.darkBlue,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onEdit,
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
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
