// lib/widgets/cita_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/cita_model.dart';
import '../utils/app_colors.dart';

class CitaCard extends StatelessWidget {
  final Cita cita;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isAdmin; // if admin, we can change status or delete

  const CitaCard({
    Key? key,
    required this.cita,
    required this.onEdit,
    required this.onDelete,
    this.isAdmin = false,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'realizada':
        return Colors.green.shade300;
      case 'cancelada':
        return AppColors.darkRed;
      case 'pendiente':
      default:
        return AppColors.darkBlue;
    }
  }

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.darkBlue,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          '${cita.fecha} a las ${cita.hora}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(cita.estado).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: _getStatusColor(cita.estado),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      cita.estado,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(cita.estado),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                'Mascota: ${cita.mascotaNombre}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isAdmin)
                Text(
                  'Cliente: ${cita.clienteNombre}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              if (cita.motivoTipo.isNotEmpty) ...[
                const SizedBox(height: 4.0),
                Text(
                  'Motivo: ${cita.motivoTipo} (\$${cita.precio.toInt()})',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.0,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (cita.sucursalNombre.isNotEmpty) ...[
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Icon(
                      Icons.store_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sucursal: ${cita.sucursalNombre}',
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Icon(
                    Icons.payment_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pago: ${cita.metodoPago == 'Tarjeta' ? cita.estadoPago : cita.metodoPago}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20.0,
                      color: AppColors.darkBlue,
                    ),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 20.0,
                      color: AppColors.darkRed,
                    ),
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
