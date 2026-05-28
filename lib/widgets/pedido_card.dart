import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/pedido_model.dart';
import '../utils/app_colors.dart';

class PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onViewDetails;
  final VoidCallback onDelete;
  final VoidCallback? onEdit; // ← este debe existir
  final void Function(String)? onChangeStatus;
  final bool isAdmin;

  const PedidoCard({
    Key? key,
    required this.pedido,
    required this.onViewDetails,
    required this.onDelete,
    this.onEdit,
    this.onChangeStatus,
    this.isAdmin = false,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'entregado':
        return Colors.green.shade300;
      case 'enviado':
        return Colors.purple.shade300;
      case 'cancelado':
        return AppColors.darkRed;
      case 'pendiente':
      default:
        return AppColors.darkBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(pedido.estado);
    final shortId = pedido.id.length > 6
        ? pedido.id.substring(pedido.id.length - 6).toUpperCase()
        : pedido.id;
    final dateStr =
        '${pedido.fecha.day}/${pedido.fecha.month}/${pedido.fecha.year} ${pedido.fecha.hour.toString().padLeft(2, '0')}:${pedido.fecha.minute.toString().padLeft(2, '0')}';

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
                  Text(
                    'Pedido #$shortId',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      pedido.estado,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Fecha: $dateStr',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.0,
                  color: AppColors.textSecondary,
                ),
              ),
              if (isAdmin)
                Text(
                  'Cliente: ${pedido.clienteNombre}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              const SizedBox(height: 4.0),
              Text(
                'Envío a: ${pedido.direccionEnvio}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.0,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${pedido.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkRed,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.darkBlue,
                          size: 22.0,
                        ),
                        onPressed: onViewDetails,
                        tooltip: 'Ver detalles',
                      ),
                      if (isAdmin && onChangeStatus != null) ...[
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.edit_road_rounded,
                            color: AppColors.textSecondary,
                            size: 22.0,
                          ),
                          tooltip: 'Cambiar estado',
                          onSelected: onChangeStatus,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'Pendiente',
                              child: Text('Pendiente'),
                            ),
                            const PopupMenuItem(
                              value: 'Enviado',
                              child: Text('Enviado'),
                            ),
                            const PopupMenuItem(
                              value: 'Entregado',
                              child: Text('Entregado'),
                            ),
                            const PopupMenuItem(
                              value: 'Cancelado',
                              child: Text('Cancelado'),
                            ),
                          ],
                        ),
                      ],
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.darkRed,
                          size: 22.0,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Eliminar pedido',
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
