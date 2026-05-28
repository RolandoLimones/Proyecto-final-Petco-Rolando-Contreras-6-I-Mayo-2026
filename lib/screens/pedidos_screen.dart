// lib/screens/pedidos_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/pedido_card.dart';
import '../models/pedido_model.dart';
import '../models/detalle_pedido_model.dart';
import '../utils/app_colors.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({Key? key}) : super(key: key);

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<OrdersProvider>(context, listen: false).fetchPedidos(),
    );
  }

  void _showOrderDetails(BuildContext context, Pedido pedido) async {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) {
        return FutureBuilder<List<DetallePedido>>(
          future: ordersProvider.fetchDetalles(pedido.id),
          builder: (context, snapshot) {
            final loading = snapshot.connectionState == ConnectionState.waiting;
            final items = snapshot.data ?? [];

            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    width: double.maxFinite,
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 600,
                    ),
                    decoration: AppColors.glassDecoration(borderRadius: 20.0),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Detalles del Pedido',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 8.0),

                        Text(
                          'Cliente: ${pedido.clienteNombre}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Dirección de envío: ${pedido.direccionEnvio}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Tarjeta: **** **** **** ${pedido.numeroTarjeta.isNotEmpty && pedido.numeroTarjeta.length >= 4 ? pedido.numeroTarjeta.substring(pedido.numeroTarjeta.length - 4) : 'Simulada'}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.0,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 16.0),
                        const Text(
                          'Productos',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8.0),

                        Expanded(
                          child: loading
                              ? const Center(child: CircularProgressIndicator())
                              : items.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay detalles registrados',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final d = items[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                // Imagen miniatura del producto
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        4.0,
                                                      ),
                                                  child:
                                                      d.productoImagenUrl !=
                                                              null &&
                                                          d
                                                              .productoImagenUrl!
                                                              .isNotEmpty
                                                      ? Image.network(
                                                          d.productoImagenUrl!,
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (_, __, ___) =>
                                                                  const Icon(
                                                                    Icons.image,
                                                                    size: 40,
                                                                  ),
                                                        )
                                                      : Container(
                                                          width: 40,
                                                          height: 40,
                                                          color: AppColors
                                                              .primaryBlue
                                                              .withOpacity(0.3),
                                                          child: const Icon(
                                                            Icons.pets_rounded,
                                                            size: 24,
                                                          ),
                                                        ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        d.productoNombre,
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14.0,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${d.cantidad} x \$${d.precioUnitario.toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins',
                                                          color: AppColors
                                                              .textSecondary,
                                                          fontSize: 12.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '\$${d.subtotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),

                        const Divider(color: AppColors.border),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pagado',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${pedido.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteConfirm(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          '¿Eliminar Pedido?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: const Text(
          '¿Está seguro de que desea eliminar este pedido? Esta acción no se puede deshacer.',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await Provider.of<OrdersProvider>(
                  context,
                  listen: false,
                ).deletePedido(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pedido eliminado con éxito'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: AppColors.darkRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkRed),
            child: const Text(
              'Eliminar',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrdersProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pedidos'),
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          provider.loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.darkBlue),
                )
              : provider.pedidos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay pedidos registrados',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: size.width > 900
                        ? 3
                        : (size.width > 600 ? 2 : 1),
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: provider.pedidos.length,
                  itemBuilder: (context, index) {
                    final item = provider.pedidos[index];
                    return PedidoCard(
                      pedido: item,
                      isAdmin: true,
                      onViewDetails: () => _showOrderDetails(context, item),
                      onDelete: () => _deleteConfirm(context, item.id),
                      onChangeStatus: (status) async {
                        try {
                          await provider.updatePedidoStatus(item.id, status);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Estado actualizado a $status'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: AppColors.darkRed,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
