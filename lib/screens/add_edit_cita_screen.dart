// lib/screens/add_edit_cita_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/cita_model.dart';
import '../models/cliente_model.dart';
import '../models/mascota_model.dart';
import '../models/sucursal_model.dart';
import '../providers/appointments_provider.dart';
import '../providers/clients_provider.dart';
import '../providers/branches_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

class AddEditCitaScreen extends StatefulWidget {
  final String? id;
  final Cita? cita;

  const AddEditCitaScreen({Key? key, this.id, this.cita}) : super(key: key);

  @override
  State<AddEditCitaScreen> createState() => _AddEditCitaScreenState();
}

class _AddEditCitaScreenState extends State<AddEditCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  String? _selectedClienteId;
  String? _selectedClienteNombre;
  String? _selectedMascotaId;
  String? _selectedMascotaNombre;
  String? _selectedSucursalId;
  String? _selectedSucursalNombre;

  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  String _selectedMotivo = 'Consulta Veterinaria';
  double _precio = 250.0;
  String _metodoPago = 'Presencial';
  String _estadoPago = 'Pendiente';
  String _estado = 'Pendiente';

  // Campos para pago con tarjeta
  final _cardController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  bool _showCardForm = false;

  List<Mascota> _mascotas = [];
  List<Sucursal> _sucursales = [];
  bool _loadingMascotas = false;
  bool get isEdit => widget.id != null;

  final Map<String, double> _motivosPrecios = {
    'Consulta Veterinaria': 250.0,
    'Baño y estética': 300.0,
    'Aplicación de vacuna': 100.0,
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final clientsProvider = Provider.of<ClientsProvider>(
        context,
        listen: false,
      );
      final branchesProvider = Provider.of<BranchesProvider>(
        context,
        listen: false,
      );
      await clientsProvider.fetchClientes();
      await branchesProvider.fetchSucursales();

      setState(() {
        _sucursales = branchesProvider.sucursales;
      });

      if (isEdit && widget.cita != null) {
        setState(() {
          _selectedClienteId = widget.cita!.clienteId;
          _selectedClienteNombre = widget.cita!.clienteNombre;
          _selectedMascotaId = widget.cita!.mascotaId;
          _selectedMascotaNombre = widget.cita!.mascotaNombre;
          _selectedSucursalId = widget.cita!.sucursalId;
          _selectedSucursalNombre = widget.cita!.sucursalNombre;
          _fechaController.text = widget.cita!.fecha;
          _horaController.text = widget.cita!.hora;
          _selectedMotivo = widget.cita!.motivoTipo;
          _precio = widget.cita!.precio;
          _metodoPago = widget.cita!.metodoPago;
          _estadoPago = widget.cita!.estadoPago;
          _estado = widget.cita!.estado;
          _showCardForm = (_metodoPago == 'Tarjeta' && !isEdit);
        });
        if (_selectedClienteId != null) {
          _loadMascotasForCliente(_selectedClienteId!);
        }
      }
    });
  }

  Future<void> _loadMascotasForCliente(String clienteId) async {
    setState(() => _loadingMascotas = true);
    try {
      final list = await _firestoreService.getMascotasByUser(clienteId);
      setState(() {
        _mascotas = list;
        if (!_mascotas.any((m) => m.id == _selectedMascotaId)) {
          _selectedMascotaId = null;
          _selectedMascotaNombre = null;
        }
      });
    } catch (e) {}
    setState(() => _loadingMascotas = false);
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    _cardController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _horaController.text = picked.format(context);
      });
    }
  }

  void _onMotivoChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedMotivo = value;
        _precio = _motivosPrecios[value]!;
      });
    }
  }

  void _onMetodoPagoChanged(String? value) {
    if (value != null) {
      setState(() {
        _metodoPago = value;
        _showCardForm = (value == 'Tarjeta');
        if (value == 'Presencial') {
          _estadoPago = 'Presencial';
        } else {
          _estadoPago = 'Pendiente';
        }
      });
    }
  }

  Future<bool> _processCardPayment() async {
    if (_cardController.text.trim().isEmpty ||
        _cardNameController.text.trim().isEmpty ||
        _expiryController.text.trim().isEmpty ||
        _cvcController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete los datos de la tarjeta'),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return false;
    }
    final cleanCard = _cardController.text.replaceAll(RegExp(r'\s+'), '');
    if (cleanCard.length != 16 || int.tryParse(cleanCard) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Número de tarjeta inválido (16 dígitos)'),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return false;
    }
    final expiryPattern = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
    if (!expiryPattern.hasMatch(_expiryController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fecha de expiración inválida (MM/YY)'),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return false;
    }
    final cvc = _cvcController.text.trim();
    if (cvc.length < 3 || cvc.length > 4 || int.tryParse(cvc) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CVC inválido'),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return false;
    }
    return true;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClienteId == null ||
        _selectedMascotaId == null ||
        _selectedSucursalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione cliente, mascota y sucursal'),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return;
    }

    if (_metodoPago == 'Tarjeta' && !isEdit) {
      bool valid = await _processCardPayment();
      if (!valid) return;
      setState(() {
        _estadoPago = 'Pagado';
      });
    }

    final provider = Provider.of<AppointmentsProvider>(context, listen: false);
    final cita = Cita(
      id: widget.id ?? '',
      clienteId: _selectedClienteId!,
      clienteNombre: _selectedClienteNombre!,
      mascotaId: _selectedMascotaId!,
      mascotaNombre: _selectedMascotaNombre!,
      fecha: _fechaController.text,
      hora: _horaController.text,
      motivoTipo: _selectedMotivo,
      precio: _precio,
      metodoPago: _metodoPago,
      estadoPago: _estadoPago,
      estado: _estado,
      sucursalId: _selectedSucursalId!,
      sucursalNombre: _selectedSucursalNombre!,
    );

    try {
      if (isEdit) {
        await provider.updateCita(cita);
      } else {
        await provider.addCita(cita);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Cita actualizada' : 'Cita agendada'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
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
  }

  @override
  Widget build(BuildContext context) {
    final clientsProvider = Provider.of<ClientsProvider>(context);
    final provider = Provider.of<AppointmentsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Cita' : 'Programar Cita'),
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
            top: -30,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: AppColors.glassDecoration(borderRadius: 24.0),
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEdit
                                ? Icons.edit_calendar_rounded
                                : Icons.add_moderator_rounded,
                            size: 48,
                            color: AppColors.darkBlue,
                          ),
                          const SizedBox(height: 24),

                          // Cliente dropdown
                          DropdownButtonFormField<String>(
                            isExpanded: true, // 👈 EVITA OVERFLOW
                            value: _selectedClienteId,
                            decoration: InputDecoration(
                              labelText: 'Cliente',
                              prefixIcon: const Icon(
                                Icons.person_rounded,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.65),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ), // 👈 Ajuste
                            ),
                            items: clientsProvider.clientes
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(
                                      c.nombre,
                                      overflow: TextOverflow
                                          .ellipsis, // 👈 Por si es muy largo
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final client = clientsProvider.clientes
                                    .firstWhere((c) => c.id == val);
                                setState(() {
                                  _selectedClienteId = val;
                                  _selectedClienteNombre = client.nombre;
                                  _selectedMascotaId = null;
                                  _selectedMascotaNombre = null;
                                  _mascotas = [];
                                });
                                _loadMascotasForCliente(val);
                              }
                            },
                            validator: (v) =>
                                v == null ? 'Seleccione cliente' : null,
                          ),
                          const SizedBox(height: 16),

                          // Mascota dropdown
                          _loadingMascotas
                              ? const CircularProgressIndicator()
                              : DropdownButtonFormField<String>(
                                  value: _selectedMascotaId,
                                  decoration: InputDecoration(
                                    labelText: 'Mascota',
                                    prefixIcon: const Icon(
                                      Icons.pets_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.65),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: _mascotas
                                      .map(
                                        (m) => DropdownMenuItem(
                                          value: m.id,
                                          child: Text(m.nombre),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _selectedClienteId == null
                                      ? null
                                      : (val) {
                                          if (val != null) {
                                            final pet = _mascotas.firstWhere(
                                              (m) => m.id == val,
                                            );
                                            setState(() {
                                              _selectedMascotaId = val;
                                              _selectedMascotaNombre =
                                                  pet.nombre;
                                            });
                                          }
                                        },
                                  validator: (v) =>
                                      v == null ? 'Seleccione mascota' : null,
                                ),
                          const SizedBox(height: 16),

                          // Fecha
                          InkWell(
                            onTap: _selectDate,
                            child: IgnorePointer(
                              child: CustomTextField(
                                controller: _fechaController,
                                labelText: 'Fecha',
                                prefixIcon: const Icon(
                                  Icons.calendar_today_rounded,
                                  color: AppColors.textSecondary,
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Seleccione fecha'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Hora
                          InkWell(
                            onTap: _selectTime,
                            child: IgnorePointer(
                              child: CustomTextField(
                                controller: _horaController,
                                labelText: 'Hora',
                                prefixIcon: const Icon(
                                  Icons.access_time_rounded,
                                  color: AppColors.textSecondary,
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Seleccione hora'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Motivo dropdown
                          // Motivo dropdown
                          DropdownButtonFormField<String>(
                            isExpanded: true, // 👈 EVITA OVERFLOW
                            value: _selectedMotivo,
                            decoration: InputDecoration(
                              labelText: 'Motivo de consulta',
                              prefixIcon: const Icon(
                                Icons.medical_services_rounded,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.65),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            items: _motivosPrecios.keys
                                .map(
                                  (motivo) => DropdownMenuItem(
                                    value: motivo,
                                    child: Text(
                                      '$motivo (\$${_motivosPrecios[motivo]!.toInt()})',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => _onMotivoChanged(val),
                            validator: (v) =>
                                v == null ? 'Seleccione motivo' : null,
                          ),
                          const SizedBox(height: 16),

                          // Sucursal dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedSucursalId,
                            decoration: InputDecoration(
                              labelText: 'Sucursal',
                              prefixIcon: const Icon(
                                Icons.store_rounded,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.65),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: _sucursales.map((sucursal) {
                              return DropdownMenuItem<String>(
                                value: sucursal.id,
                                child: Text(sucursal.nombre),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final selected = _sucursales.firstWhere(
                                  (s) => s.id == val,
                                );
                                setState(() {
                                  _selectedSucursalId = val;
                                  _selectedSucursalNombre = selected.nombre;
                                });
                              }
                            },
                            validator: (v) =>
                                v == null ? 'Seleccione una sucursal' : null,
                          ),
                          const SizedBox(height: 16),

                          // Método de pago
                          // Método de pago
                          DropdownButtonFormField<String>(
                            isExpanded: true, // 👈 EVITA OVERFLOW
                            value: _metodoPago,
                            decoration: InputDecoration(
                              labelText: 'Método de pago',
                              prefixIcon: const Icon(
                                Icons.payment_rounded,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.65),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Presencial',
                                child: Text(
                                  'Presencial',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Tarjeta',
                                child: Text(
                                  'Tarjeta de crédito/débito',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            onChanged: (val) => _onMetodoPagoChanged(val),
                            validator: (v) =>
                                v == null ? 'Seleccione método de pago' : null,
                          ),
                          const SizedBox(height: 16),

                          // Formulario de tarjeta (si aplica)
                          if (_showCardForm && !isEdit) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: _cardController,
                                    labelText: 'Número de tarjeta (16 dígitos)',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: const Icon(
                                      Icons.credit_card_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  CustomTextField(
                                    controller: _cardNameController,
                                    labelText: 'Nombre en la tarjeta',
                                    prefixIcon: const Icon(
                                      Icons.person_outline_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextField(
                                          controller: _expiryController,
                                          labelText: 'Vencimiento (MM/YY)',
                                          keyboardType: TextInputType.datetime,
                                          prefixIcon: const Icon(
                                            Icons.calendar_today_rounded,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: CustomTextField(
                                          controller: _cvcController,
                                          labelText: 'CVC',
                                          keyboardType: TextInputType.number,
                                          obscureText: true,
                                          prefixIcon: const Icon(
                                            Icons.lock_outline_rounded,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Estado (solo para admin en edición)
                          if (isEdit) ...[
                            DropdownButtonFormField<String>(
                              value: _estado,
                              decoration: InputDecoration(
                                labelText: 'Estado de la cita',
                                prefixIcon: const Icon(
                                  Icons.star_half_rounded,
                                  color: AppColors.textSecondary,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.65),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Pendiente',
                                  child: Text('Pendiente'),
                                ),
                                DropdownMenuItem(
                                  value: 'Realizada',
                                  child: Text('Realizada'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cancelada',
                                  child: Text('Cancelada'),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => _estado = val!),
                            ),
                            const SizedBox(height: 16),
                            // Mostrar estado de pago (solo lectura?)
                            Text(
                              'Estado de pago: $_estadoPago',
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                            const SizedBox(height: 16),
                          ],

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: provider.loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                                foregroundColor: Colors.white,
                              ),
                              child: provider.loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      isEdit
                                          ? 'Guardar Cambios'
                                          : 'Agendar Cita',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
