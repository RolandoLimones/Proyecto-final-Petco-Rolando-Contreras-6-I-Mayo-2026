// lib/screens/citas_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/appointments_provider.dart';
import '../models/cita_model.dart';
import '../utils/app_colors.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({Key? key}) : super(key: key);

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<AppointmentsProvider>(
        context,
        listen: false,
      ).fetchCitas(),
    );
  }

  void _deleteConfirm(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          '¿Eliminar Cita?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: const Text(
          '¿Está seguro de que desea eliminar esta cita? Esta acción no se puede deshacer.',
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
                await Provider.of<AppointmentsProvider>(
                  context,
                  listen: false,
                ).deleteCita(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cita eliminada con éxito'),
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
    final provider = Provider.of<AppointmentsProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Citas Veterinarias'),
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
              : provider.citas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay citas registradas',
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
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: provider.citas.length,
                  itemBuilder: (context, index) {
                    final cita = provider.citas[index];
                    return Card(
                      color: Colors.white.withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${cita.mascotaNombre} - ${cita.clienteNombre}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cita.estado == 'Pendiente'
                                        ? Colors.orange.shade100
                                        : cita.estado == 'Realizada'
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    cita.estado,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: cita.estado == 'Pendiente'
                                          ? Colors.orange.shade800
                                          : cita.estado == 'Realizada'
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '📅 ${cita.fecha} - ${cita.hora}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '🩺 ${cita.motivoTipo} - \$${cita.precio.toInt()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  cita.metodoPago == 'Tarjeta'
                                      ? Icons.credit_card_rounded
                                      : Icons.money_rounded,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  cita.metodoPago == 'Tarjeta'
                                      ? 'Pago: ${cita.estadoPago}'
                                      : 'Pago: Presencial',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: AppColors.darkBlue,
                                  ),
                                  onPressed: () => context.push(
                                    '/citas/edit/${cita.id}',
                                    extra: cita,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: AppColors.darkRed,
                                  ),
                                  onPressed: () =>
                                      _deleteConfirm(context, cita.id),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/citas/add');
        },
        backgroundColor: AppColors.darkBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
