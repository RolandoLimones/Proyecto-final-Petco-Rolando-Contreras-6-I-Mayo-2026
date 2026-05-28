import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/pets_provider.dart';
import '../providers/clients_provider.dart';
import '../models/mascota_model.dart';
import '../models/cliente_model.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

class AddMascotaScreen extends StatefulWidget {
  const AddMascotaScreen({Key? key}) : super(key: key);

  @override
  State<AddMascotaScreen> createState() => _AddMascotaScreenState();
}

class _AddMascotaScreenState extends State<AddMascotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _especieController = TextEditingController(); // new
  final _razaController = TextEditingController();
  final _edadController = TextEditingController();
  final _pesoController = TextEditingController();

  // Para administrador: selección de cliente dueño
  List<Cliente> _clientes = [];
  Cliente? _selectedCliente;
  bool _isAdmin = false;
  bool _loadingClientes = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentUserId = authProvider.user?.uid;
    if (_currentUserId == null) return;

    // Determinar si el usuario actual es admin (no existe en clientes)
    final firestoreService = FirestoreService();
    final cliente = await firestoreService.getClienteById(_currentUserId!);
    final isAdmin = cliente == null;
    setState(() {
      _isAdmin = isAdmin;
    });

    if (isAdmin) {
      // Cargar lista de clientes para el dropdown
      final clientsProvider = Provider.of<ClientsProvider>(
        context,
        listen: false,
      );
      await clientsProvider.fetchClientes();
      setState(() {
        _clientes = clientsProvider.clientes;
        _loadingClientes = false;
      });
    } else {
      setState(() {
        _loadingClientes = false;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _especieController.dispose();
    _razaController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    // Validar que se haya seleccionado un cliente (solo para admin)
    if (_isAdmin && _selectedCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un cliente dueño'),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return;
    }

    final petsProvider = Provider.of<PetsProvider>(context, listen: false);
    final clienteId = _isAdmin ? _selectedCliente!.id : _currentUserId!;

    final nuevaMascota = Mascota(
      id: '',
      nombre: _nombreController.text.trim(),
      especie: _especieController.text.trim(),
      raza: _razaController.text.trim(),
      edad: int.parse(_edadController.text),
      peso: _pesoController.text.trim().isEmpty
          ? null
          : double.tryParse(_pesoController.text),
      clienteId: clienteId,
    );

    try {
      await petsProvider.addMascota(nuevaMascota);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${nuevaMascota.nombre}" agregada con éxito.'),
            backgroundColor: AppColors.darkBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar mascota: $e'),
            backgroundColor: AppColors.darkRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petsProvider = Provider.of<PetsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.6),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => context.pop(),
              ),
              title: const Text(
                'Nueva Mascota',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
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
          SafeArea(
            child: Center(
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
                      padding: const EdgeInsets.all(28.0),
                      child: _loadingClientes
                          ? const Center(child: CircularProgressIndicator())
                          : Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Detalles de la Mascota',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 24.0),

                                  // --- Cliente dueño (solo para admin) ---
                                  if (_isAdmin) ...[
                                    DropdownButtonFormField<Cliente>(
                                      value: _selectedCliente,
                                      decoration: InputDecoration(
                                        labelText: 'Cliente dueño',
                                        labelStyle: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14.0,
                                          color: AppColors.textSecondary,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.65,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.person_outline,
                                          color: AppColors.textSecondary,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.border,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.darkBlue,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14.0,
                                        color: AppColors.textPrimary,
                                      ),
                                      items: _clientes.map((Cliente c) {
                                        return DropdownMenuItem<Cliente>(
                                          value: c,
                                          child: Text(c.nombre),
                                        );
                                      }).toList(),
                                      onChanged: (Cliente? newValue) {
                                        setState(() {
                                          _selectedCliente = newValue;
                                        });
                                      },
                                      validator: (value) => value == null
                                          ? 'Seleccione un cliente'
                                          : null,
                                    ),
                                    const SizedBox(height: 16.0),
                                  ],

                                  // Name
                                  CustomTextField(
                                    controller: _nombreController,
                                    labelText: 'Nombre',
                                    prefixIcon: const Icon(
                                      Icons.badge_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Ingresa el nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Species (free text)
                                  CustomTextField(
                                    controller: _especieController,
                                    labelText: 'Especie',
                                    prefixIcon: const Icon(
                                      Icons.category_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Ingresa la especie';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Breed
                                  CustomTextField(
                                    controller: _razaController,
                                    labelText: 'Raza',
                                    prefixIcon: const Icon(
                                      Icons.pets_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Ingresa la raza (ej. Mestizo, Criollo, etc.)';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Age
                                  CustomTextField(
                                    controller: _edadController,
                                    labelText: 'Edad (años)',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Ingresa la edad';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Ingresa un número entero';
                                      }
                                      if (int.parse(value) < 0) {
                                        return 'La edad no puede ser negativa';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Weight
                                  CustomTextField(
                                    controller: _pesoController,
                                    labelText: 'Peso (kg) - Opcional',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    prefixIcon: const Icon(
                                      Icons.monitor_weight_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: (value) {
                                      if (value != null &&
                                          value.trim().isNotEmpty) {
                                        if (double.tryParse(value) == null) {
                                          return 'Ingresa un número válido';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32.0),

                                  // Buttons row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => context.pop(),
                                        child: const Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      ElevatedButton(
                                        onPressed: petsProvider.loading
                                            ? null
                                            : _save,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.darkRed,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0,
                                            vertical: 12.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                        ),
                                        child: petsProvider.loading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.0,
                                                    ),
                                              )
                                            : const Text(
                                                'Guardar',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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