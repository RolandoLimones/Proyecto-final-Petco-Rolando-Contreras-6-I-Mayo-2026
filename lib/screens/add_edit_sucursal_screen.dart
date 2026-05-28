import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/sucursal_model.dart';
import '../providers/branches_provider.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

class AddEditSucursalScreen extends StatefulWidget {
  final String? id;
  final Sucursal? sucursal;

  const AddEditSucursalScreen({
    Key? key,
    this.id,
    this.sucursal,
  }) : super(key: key);

  @override
  State<AddEditSucursalScreen> createState() => _AddEditSucursalScreenState();
}

class _AddEditSucursalScreenState extends State<AddEditSucursalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _horarioController = TextEditingController();

  bool get isEdit => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEdit && widget.sucursal != null) {
      _nombreController.text = widget.sucursal!.nombre;
      _direccionController.text = widget.sucursal!.direccion;
      _telefonoController.text = widget.sucursal!.telefono;
      _horarioController.text = widget.sucursal!.horario;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<BranchesProvider>(context, listen: false);
    final sucursal = Sucursal(
      id: widget.id ?? '',
      nombre: _nombreController.text.trim(),
      direccion: _direccionController.text.trim(),
      telefono: _telefonoController.text.trim(),
      horario: _horarioController.text.trim(),
    );

    try {
      if (isEdit) {
        await provider.updateSucursal(sucursal);
      } else {
        await provider.addSucursal(sucursal);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Sucursal actualizada con éxito' : 'Sucursal agregada con éxito'),
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
    final provider = Provider.of<BranchesProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Sucursal' : 'Agregar Sucursal'),
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
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryRed),
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
                            isEdit ? Icons.edit_note_rounded : Icons.add_business_rounded,
                            size: 48,
                            color: AppColors.darkBlue,
                          ),
                          const SizedBox(height: 24.0),
                          CustomTextField(
                            controller: _nombreController,
                            labelText: 'Nombre de la Sucursal',
                            prefixIcon: const Icon(Icons.store_mall_directory_rounded, color: AppColors.textSecondary),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingrese un nombre' : null,
                          ),
                          const SizedBox(height: 16.0),
                          CustomTextField(
                            controller: _direccionController,
                            labelText: 'Dirección',
                            maxLines: 2,
                            prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.textSecondary),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingrese una dirección' : null,
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
                            controller: _horarioController,
                            labelText: 'Horario (ej. Lun-Vie: 9am-6pm)',
                            prefixIcon: const Icon(Icons.access_time_filled_rounded, color: AppColors.textSecondary),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingrese un horario' : null,
                          ),
                          const SizedBox(height: 32.0),
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
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      isEdit ? 'Guardar Cambios' : 'Registrar Sucursal',
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
