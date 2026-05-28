import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/cliente_model.dart';
import '../providers/clients_provider.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

class AddEditClienteScreen extends StatefulWidget {
  final String? id;
  final Cliente? cliente;

  const AddEditClienteScreen({Key? key, this.id, this.cliente})
    : super(key: key);

  @override
  State<AddEditClienteScreen> createState() => _AddEditClienteScreenState();
}

class _AddEditClienteScreenState extends State<AddEditClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _passwordController = TextEditingController(); // Solo para creación

  // Campos de tarjeta (opcionales)
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  bool _showCardFields = false;

  bool get isEdit => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEdit && widget.cliente != null) {
      _nombreController.text = widget.cliente!.nombre;
      _emailController.text = widget.cliente!.email;
      _telefonoController.text = widget.cliente!.telefono;
      _direccionController.text = widget.cliente!.direccion;

      // Cargar datos de tarjeta si existen
      if (widget.cliente!.tarjetaNumero != null &&
          widget.cliente!.tarjetaNumero!.isNotEmpty) {
        _cardNumberController.text = widget.cliente!.tarjetaNumero!;
        _cardNameController.text = widget.cliente!.tarjetaNombre ?? '';
        _expiryController.text = widget.cliente!.tarjetaExpiry ?? '';
        _cvcController.text = widget.cliente!.tarjetaCvc ?? '';
        _showCardFields = true;
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _passwordController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  // Validación de número de tarjeta (16 dígitos, opcional)
  String? _validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final clean = value.replaceAll(RegExp(r'\s+'), '');
    if (clean.length != 16) {
      return 'La tarjeta debe tener 16 dígitos';
    }
    if (int.tryParse(clean) == null) {
      return 'Solo números válidos';
    }
    return null;
  }

  // Validación de nombre en tarjeta (opcional)
  String? _validateCardName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length < 3) {
      return 'Ingrese un nombre válido';
    }
    return null;
  }

  // Validación de fecha de expiración (MM/YY, opcional)
  String? _validateExpiry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final pattern = RegExp(r'^(0[1-9]|1[0-2])\/(\d{2})$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Formato MM/YY';
    }
    final parts = value.trim().split('/');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]);
    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;

    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Tarjeta vencida';
    }
    return null;
  }

  // Validación de CVC (3-4 dígitos, opcional)
  String? _validateCvc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final clean = value.trim();
    if (clean.length < 3 || clean.length > 4) {
      return 'CVC debe tener 3 o 4 dígitos';
    }
    if (int.tryParse(clean) == null) {
      return 'Solo números';
    }
    return null;
  }

  // Validación grupal de tarjeta
  String? _validateCardGroup() {
    final hasNumber = _cardNumberController.text.trim().isNotEmpty;
    final hasName = _cardNameController.text.trim().isNotEmpty;
    final hasExpiry = _expiryController.text.trim().isNotEmpty;
    final hasCvc = _cvcController.text.trim().isNotEmpty;

    if (hasNumber || hasName || hasExpiry || hasCvc) {
      if (!hasNumber) return 'Número de tarjeta requerido';
      if (!hasName) return 'Nombre en tarjeta requerido';
      if (!hasExpiry) return 'Fecha de expiración requerida';
      if (!hasCvc) return 'CVC requerido';
    }
    return null;
  }

  // Validación de contraseña (solo para creación)
  String? _validatePassword(String? value) {
    if (isEdit) {
      return null; // En edición no se usa contraseña
    }
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese una contraseña';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  // Validación de email (en edición es de solo lectura, pero validamos igual)
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese un correo';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cardGroupError = _validateCardGroup();
    if (cardGroupError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cardGroupError),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return;
    }

    final provider = Provider.of<ClientsProvider>(context, listen: false);

    final cardNumber = _cardNumberController.text.trim().isEmpty
        ? null
        : _cardNumberController.text.trim();
    final cardName = _cardNameController.text.trim().isEmpty
        ? null
        : _cardNameController.text.trim();
    final expiry = _expiryController.text.trim().isEmpty
        ? null
        : _expiryController.text.trim();
    final cvc = _cvcController.text.trim().isEmpty
        ? null
        : _cvcController.text.trim();

    final cliente = Cliente(
      id: widget.id ?? '',
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
      tarjetaNumero: cardNumber,
      tarjetaNombre: cardName,
      tarjetaExpiry: expiry,
      tarjetaCvc: cvc,
    );

    try {
      if (isEdit) {
        // En edición NO se actualiza correo ni contraseña
        await provider.updateCliente(cliente);
      } else {
        // En creación, la contraseña es obligatoria
        final password = _passwordController.text.trim();
        if (password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ingrese una contraseña para el cliente'),
              backgroundColor: AppColors.darkRed,
            ),
          );
          return;
        }
        await provider.addCliente(cliente, password);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Cliente actualizado con éxito'
                  : 'Cliente agregado con éxito',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.darkRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClientsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Cliente' : 'Agregar Cliente'),
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
            bottom: -30,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed,
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
                                ? Icons.person_rounded
                                : Icons.person_add_rounded,
                            size: 48,
                            color: AppColors.darkBlue,
                          ),
                          const SizedBox(height: 24.0),

                          // Nombre
                          CustomTextField(
                            controller: _nombreController,
                            labelText: 'Nombre del Cliente',
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.textSecondary,
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Ingrese el nombre'
                                : null,
                          ),
                          const SizedBox(height: 16.0),

                          // Email (solo lectura en edición)
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Correo Electrónico',
                            keyboardType: TextInputType.emailAddress,
                            readOnly: isEdit, // 👈 No editable en edición
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.textSecondary,
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 16.0),

                          // Contraseña (SOLO en creación)
                          if (!isEdit) ...[
                            CustomTextField(
                              controller: _passwordController,
                              labelText: 'Contraseña (para acceso del cliente)',
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.textSecondary,
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 16.0),
                          ],

                          // Si es edición, mostrar un texto informativo
                          if (isEdit)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: AppColors.darkBlue,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'El correo no se puede modificar. '
                                      'Eso podria causar problemas con la autenticación',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          CustomTextField(
                            controller: _telefonoController,
                            labelText: 'Teléfono',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(
                              Icons.phone_rounded,
                              color: AppColors.textSecondary,
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Ingrese un teléfono'
                                : null,
                          ),
                          const SizedBox(height: 16.0),

                          CustomTextField(
                            controller: _direccionController,
                            labelText: 'Dirección de Envío',
                            maxLines: 2,
                            prefixIcon: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.textSecondary,
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Ingrese una dirección'
                                : null,
                          ),
                          const SizedBox(height: 24.0),

                          // Switch para mostrar/ocultar campos de tarjeta
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Datos de pago (tarjeta)',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: const Text(
                              'Opcional - Complete si desea guardar tarjeta',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: _showCardFields,
                            onChanged: (value) {
                              setState(() {
                                _showCardFields = value;
                                if (!value) {
                                  _cardNumberController.clear();
                                  _cardNameController.clear();
                                  _expiryController.clear();
                                  _cvcController.clear();
                                }
                              });
                            },
                            activeColor: AppColors.darkBlue,
                          ),
                          const SizedBox(height: 8.0),

                          // Campos de tarjeta (opcionales)
                          if (_showCardFields) ...[
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: _cardNumberController,
                                    labelText: 'Número de tarjeta (16 dígitos)',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: const Icon(
                                      Icons.credit_card_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: _validateCardNumber,
                                  ),
                                  const SizedBox(height: 12.0),

                                  CustomTextField(
                                    controller: _cardNameController,
                                    labelText: 'Nombre en la tarjeta',
                                    prefixIcon: const Icon(
                                      Icons.person_outline_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: _validateCardName,
                                  ),
                                  const SizedBox(height: 12.0),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextField(
                                          controller: _expiryController,
                                          labelText: 'Vencimiento (MM/YY)',
                                          keyboardType: TextInputType.text,
                                          prefixIcon: const Icon(
                                            Icons.calendar_today_rounded,
                                            color: AppColors.textSecondary,
                                          ),
                                          validator: _validateExpiry,
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
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
                                          validator: _validateCvc,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16.0),
                          ],

                          const SizedBox(height: 16.0),
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
                                          : 'Registrar Cliente',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.0,
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
