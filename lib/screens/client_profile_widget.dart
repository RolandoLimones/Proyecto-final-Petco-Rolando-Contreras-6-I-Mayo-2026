// lib/screens/client_profile_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/cliente_model.dart';
import '../providers/auth_provider.dart';
import '../providers/clients_provider.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

class ClientProfileWidget extends StatefulWidget {
  final Cliente cliente;
  final VoidCallback onProfileUpdated;

  const ClientProfileWidget({
    Key? key,
    required this.cliente,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  State<ClientProfileWidget> createState() => _ClientProfileWidgetState();
}

class _ClientProfileWidgetState extends State<ClientProfileWidget> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cardNumberController;
  late TextEditingController _cardNameController;
  late TextEditingController _expiryController;
  late TextEditingController _cvcController;

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cliente.nombre);
    _phoneController = TextEditingController(text: widget.cliente.telefono);
    _addressController = TextEditingController(text: widget.cliente.direccion);
    _cardNumberController = TextEditingController(
      text: widget.cliente.tarjetaNumero ?? '',
    );
    _cardNameController = TextEditingController(
      text: widget.cliente.tarjetaNombre ?? '',
    );
    _expiryController = TextEditingController(
      text: widget.cliente.tarjetaExpiry ?? '',
    );
    _cvcController = TextEditingController(
      text: widget.cliente.tarjetaCvc ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedCliente = widget.cliente.copyWith(
      nombre: _nameController.text.trim(),
      telefono: _phoneController.text.trim(),
      direccion: _addressController.text.trim(),
      tarjetaNumero: _cardNumberController.text.trim().isEmpty
          ? null
          : _cardNumberController.text.trim(),
      tarjetaNombre: _cardNameController.text.trim().isEmpty
          ? null
          : _cardNameController.text.trim(),
      tarjetaExpiry: _expiryController.text.trim().isEmpty
          ? null
          : _expiryController.text.trim(),
      tarjetaCvc: _cvcController.text.trim().isEmpty
          ? null
          : _cvcController.text.trim(),
    );

    try {
      await Provider.of<ClientsProvider>(
        context,
        listen: false,
      ).updateCliente(updatedCliente);
      widget.onProfileUpdated(); // Refrescar en pantalla principal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: AppColors.darkRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Personal',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              labelText: 'Nombre completo',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingrese su nombre' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _phoneController,
              labelText: 'Teléfono',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_android_rounded),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingrese su teléfono' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _addressController,
              labelText: 'Dirección de envío',
              maxLines: 2,
              prefixIcon: const Icon(Icons.location_on_rounded),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingrese su dirección' : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Datos de tarjeta (opcional)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _cardNumberController,
              labelText: 'Número de tarjeta (16 dígitos)',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.credit_card_rounded),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final clean = v.replaceAll(RegExp(r'\s+'), '');
                if (clean.length != 16 || int.tryParse(clean) == null) {
                  return 'Debe tener 16 dígitos';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _cardNameController,
              labelText: 'Nombre en la tarjeta',
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _expiryController,
                    labelText: 'Vencimiento (MM/YY)',
                    keyboardType: TextInputType.datetime,
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (!RegExp(
                        r'^(0[1-9]|1[0-2])\/\d{2}$',
                      ).hasMatch(v.trim())) {
                        return 'Formato MM/YY';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _cvcController,
                    labelText: 'CVC',
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (v.trim().length < 3 ||
                          v.trim().length > 4 ||
                          int.tryParse(v) == null) {
                        return 'CVC inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(
                  Icons.exit_to_app_rounded,
                  color: AppColors.darkRed,
                ),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkRed,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.darkRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
