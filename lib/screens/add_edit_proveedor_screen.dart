import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/proveedor_model.dart';
import '../providers/providers_provider.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

class AddEditProveedorScreen extends StatefulWidget {
  final String? id;
  final Proveedor? proveedor;

  const AddEditProveedorScreen({
    Key? key,
    this.id,
    this.proveedor,
  }) : super(key: key);

  @override
  State<AddEditProveedorScreen> createState() => _AddEditProveedorScreenState();
}

class _AddEditProveedorScreenState extends State<AddEditProveedorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _contactoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();

  bool get isEdit => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEdit && widget.proveedor != null) {
      _nombreController.text = widget.proveedor!.nombre;
      _contactoController.text = widget.proveedor!.contacto;
      _telefonoController.text = widget.proveedor!.telefono;
      _emailController.text = widget.proveedor!.email;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _contactoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ProvidersProvider>(context, listen: false);
    final proveedor = Proveedor(
      id: widget.id ?? '',
      nombre: _nombreController.text.trim(),
      contacto: _contactoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      email: _emailController.text.trim(),
    );

    try {
      if (isEdit) {
        await provider.updateProveedor(proveedor);
      } else {
        await provider.addProveedor(proveedor);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Proveedor actualizado con éxito' : 'Proveedor agregado con éxito'),
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
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<ProvidersProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Proveedor' : 'Agregar Proveedor'),
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
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue),
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
                            isEdit ? Icons.edit_note_rounded : Icons.local_shipping_rounded,
                            size: 48,
                            color: AppColors.darkRed,
                          ),
                          const SizedBox(height: 24.0),
                          CustomTextField(
                            controller: _nombreController,
                            labelText: 'Nombre del Proveedor / Empresa',
                            prefixIcon: const Icon(Icons.business_rounded, color: AppColors.textSecondary),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingrese el nombre' : null,
                          ),
                          const SizedBox(height: 16.0),
                          CustomTextField(
                            controller: _contactoController,
                            labelText: 'Nombre del Contacto',
                            prefixIcon: const Icon(Icons.person_rounded, color: AppColors.textSecondary),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingrese un nombre de contacto' : null,
                          ),
                          const SizedBox(height: 16.0),
                          CustomTextField(
                            controller: _telefonoController,
                            labelText: 'Teléfono',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.textSecondary),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingrese un teléfono' : null,
                          ),
                          const SizedBox(height: 16.0),
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Correo Electrónico',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_rounded, color: AppColors.textSecondary),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Ingrese un correo';
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(val.trim())) return 'Ingrese un correo válido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32.0),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: provider.loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkRed,
                                foregroundColor: Colors.white,
                              ),
                              child: provider.loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      isEdit ? 'Guardar Cambios' : 'Registrar Proveedor',
                                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 16.0, fontWeight: FontWeight.w600),
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
