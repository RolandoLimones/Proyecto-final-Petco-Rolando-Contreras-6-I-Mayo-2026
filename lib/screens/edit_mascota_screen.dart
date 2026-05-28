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

class EditMascotaScreen extends StatefulWidget {
  final String id;
  final Mascota? mascota;

  const EditMascotaScreen({Key? key, required this.id, this.mascota})
      : super(key: key);

  @override
  State<EditMascotaScreen> createState() => _EditMascotaScreenState();
}

class _EditMascotaScreenState extends State<EditMascotaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _especieController;
  late TextEditingController _razaController;
  late TextEditingController _edadController;
  late TextEditingController _pesoController;

  // Para el dropdown de clientes (solo admin)
  List<Cliente> _clientes = [];
  Cliente? _selectedCliente;
  bool _isAdmin = false;
  bool _loadingClientes = true;

  Mascota? _currentMascota;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Obtener la mascota actual
    final petsProvider = Provider.of<PetsProvider>(context, listen: false);
    _currentMascota =
        widget.mascota ??
        petsProvider.mascotas.firstWhere(
          (m) => m.id == widget.id,
          orElse: () => Mascota(
            id: widget.id,
            nombre: '',
            especie: '',
            raza: '',
            edad: 0,
            clienteId: '',
          ),
        );

    // Inicializar controladores
    _nombreController = TextEditingController(text: _currentMascota?.nombre);
    _especieController = TextEditingController(text: _currentMascota?.especie);
    _razaController = TextEditingController(text: _currentMascota?.raza);
    _edadController = TextEditingController(
      text: _currentMascota?.edad.toString(),
    );
    _pesoController = TextEditingController(
      text: _currentMascota?.peso?.toString() ?? '',
    );

    // Determinar si el usuario actual es admin
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
    if (currentUserId != null) {
      final firestoreService = FirestoreService();
      final cliente = await firestoreService.getClienteById(currentUserId);
      final isAdmin = cliente == null;
      setState(() {
        _isAdmin = isAdmin;
      });

      if (isAdmin) {
        // Cargar lista de clientes y seleccionar el dueño actual
        final clientsProvider = Provider.of<ClientsProvider>(
          context,
          listen: false,
        );
        await clientsProvider.fetchClientes();
        final clientesList = clientsProvider.clientes;
        final clienteActual = clientesList.firstWhere(
          (c) => c.id == _currentMascota?.clienteId,
          orElse: () => clientesList.first,
        );
        setState(() {
          _clientes = clientesList;
          _selectedCliente = clienteActual;
          _loadingClientes = false;
        });
      } else {
        setState(() {
          _loadingClientes = false;
        });
      }
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
    if (_currentMascota == null) return;

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
    final clienteId = _isAdmin ? _selectedCliente!.id : _currentMascota!.clienteId;

    final updatedMascota = _currentMascota!.copyWith(
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
      await petsProvider.updateMascota(updatedMascota);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${updatedMascota.nombre}" modificada con éxito.'),
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
            content: Text('Error al modificar mascota: $e'),
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

    if (_currentMascota == null || _currentMascota!.clienteId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Editar Mascota')),
        body: const Center(child: Text('Mascota no encontrada o inaccesible.')),
      );
    }

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
                'Editar Mascota',
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
            right: -20,
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
            left: -30,
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
                                    'Modificar Detalles de la Mascota',
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
                                        fillColor: Colors.white.withOpacity(0.65),
                                        prefixIcon: const Icon(
                                          Icons.person_outline,
                                          color: AppColors.textSecondary,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: const BorderSide(
                                            color: AppColors.border,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
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

                                  // Nombre
                                  CustomTextField(
                                    controller: _nombreController,
                                    labelText: 'Nombre',
                                    prefixIcon: const Icon(
                                      Icons.badge_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Ingresa el nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Especie (texto libre)
                                  CustomTextField(
                                    controller: _especieController,
                                    labelText: 'Especie',
                                    prefixIcon: const Icon(
                                      Icons.category_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Ingresa la especie';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Raza
                                  CustomTextField(
                                    controller: _razaController,
                                    labelText: 'Raza',
                                    prefixIcon: const Icon(
                                      Icons.pets_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Ingresa la raza (ej. Mestizo, Criollo, etc.)';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Edad
                                  CustomTextField(
                                    controller: _edadController,
                                    labelText: 'Edad (años)',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
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

                                  // Peso
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
                                      if (value != null && value.trim().isNotEmpty) {
                                        if (double.tryParse(value) == null) {
                                          return 'Ingresa un número válido';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32.0),

                                  // Botones
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
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        child: petsProvider.loading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
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