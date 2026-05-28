// lib/screens/client_home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petcocrud/models/sucursal_model.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../providers/pets_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/appointments_provider.dart';
import '../providers/clients_provider.dart';

import '../models/mascota_model.dart';
import '../models/pedido_model.dart';
import '../models/detalle_pedido_model.dart';
import '../models/cita_model.dart';
import '../models/cliente_model.dart';
import '../providers/branches_provider.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

import '../screens/client_profile_widget.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentTab = 0;
  Cliente? _clientProfile;

  // Checkout form controllers
  final _checkoutFormKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _addressController = TextEditingController();

  // Switch para guardar datos de pago
  bool _savePaymentData = false;
  bool _saveCardDataForAppointment = false;

  // Pet form controllers
  final _petFormKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController();
  final _petSpeciesController = TextEditingController();
  final _petBreedController = TextEditingController();
  final _petAgeController = TextEditingController();
  final _petPesoController = TextEditingController();

  // Appointment form controllers
  final _appointmentFormKey = GlobalKey<FormState>();
  String? _selectedMascotaId;
  String? _selectedMascotaNombre;
  final _appointmentDateController = TextEditingController();
  final _appointmentTimeController = TextEditingController();
  final _appointmentReasonController = TextEditingController();
  String _selectedCategory = 'Todos';
  String _selectedMotivoTipo = 'Consulta Veterinaria';
  double _selectedPrecio = 250.0;
  String _selectedMetodoPago = 'Presencial';
  String _appointmentEstadoPago = 'Presencial';
  bool _showCardFormForAppointment = false;
  List<Sucursal> _sucursales = [];
  String? _selectedSucursalId;
  String? _selectedSucursalNombre;

  final _appointmentCardController = TextEditingController();
  final _appointmentCardNameController = TextEditingController();
  final _appointmentExpiryController = TextEditingController();
  final _appointmentCvcController = TextEditingController();

  final Map<String, double> _motivosPrecios = {
    'Consulta Veterinaria': 250.0,
    'Baño y estética': 300.0,
    'Aplicación de vacuna': 100.0,
  };

  final List<String> _categories = [
    'Todos',
    'Alimento',
    'Juguetes',
    'Accesorios',
    'Higiene',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadInitialData());
  }

  void _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.user?.uid;
    if (uid != null) {
      Provider.of<ProductsProvider>(context, listen: false).fetchProductos();
      Provider.of<PetsProvider>(context, listen: false).fetchMascotas(uid);
      Provider.of<OrdersProvider>(
        context,
        listen: false,
      ).fetchPedidosByUser(uid);
      Provider.of<AppointmentsProvider>(
        context,
        listen: false,
      ).fetchCitasByUser(uid);

      final clientProvider = Provider.of<ClientsProvider>(
        context,
        listen: false,
      );
      await clientProvider.fetchClientes();
      final profile = clientProvider.clientes.firstWhere(
        (c) => c.id == uid,
        orElse: () => Cliente(
          id: uid,
          nombre: authProvider.user?.displayName ?? 'Cliente',
          email: authProvider.user?.email ?? '',
          telefono: '',
          direccion: '',
        ),
      );
      final branchesProvider = Provider.of<BranchesProvider>(
        context,
        listen: false,
      );
      await branchesProvider.fetchSucursales();
      setState(() {
        _sucursales = branchesProvider.sucursales;
      });
      setState(() {
        _clientProfile = profile;
        _addressController.text = profile.direccion;
        // Precargar datos de pago si existen
        if (profile.tarjetaNumero != null &&
            profile.tarjetaNumero!.isNotEmpty) {
          _cardController.text = profile.tarjetaNumero!;
        }
        if (profile.tarjetaNombre != null &&
            profile.tarjetaNombre!.isNotEmpty) {
          _cardNameController.text = profile.tarjetaNombre!;
        }
        if (profile.tarjetaExpiry != null &&
            profile.tarjetaExpiry!.isNotEmpty) {
          _expiryController.text = profile.tarjetaExpiry!;
        }
        if (profile.tarjetaCvc != null && profile.tarjetaCvc!.isNotEmpty) {
          _cvcController.text = profile.tarjetaCvc!;
        }
      });
      _preloadCardDataForAppointment();
    }
  }

  void _openEditPetDialog(Mascota pet) {
    final nombreCtrl = TextEditingController(text: pet.nombre);
    final especieCtrl = TextEditingController(text: pet.especie);
    final razaCtrl = TextEditingController(text: pet.raza);
    final edadCtrl = TextEditingController(text: pet.edad.toString());
    final pesoCtrl = TextEditingController(text: pet.peso?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Container(
                decoration: AppColors.glassDecoration(borderRadius: 20.0),
                padding: const EdgeInsets.all(24.0),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    // 👈 Scroll añadido aquí también
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Editar Mascota',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        CustomTextField(
                          controller: nombreCtrl,
                          labelText: 'Nombre',
                          prefixIcon: const Icon(
                            Icons.pets_rounded,
                            color: AppColors.textSecondary,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Ingrese el nombre'
                              : null,
                        ),
                        const SizedBox(height: 12.0),
                        CustomTextField(
                          controller: especieCtrl,
                          labelText: 'Especie (ej. Perro, Gato)',
                          prefixIcon: const Icon(
                            Icons.category_rounded,
                            color: AppColors.textSecondary,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Ingrese la especie'
                              : null,
                        ),
                        const SizedBox(height: 12.0),
                        CustomTextField(
                          controller: razaCtrl,
                          labelText: 'Raza (Opcional)',
                          prefixIcon: const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        CustomTextField(
                          controller: edadCtrl,
                          labelText: 'Edad (años)',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(
                            Icons.cake_rounded,
                            color: AppColors.textSecondary,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Ingrese la edad';
                            if (int.tryParse(v) == null) return 'Número válido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12.0),
                        CustomTextField(
                          controller: pesoCtrl,
                          labelText: 'Peso (kg) - Opcional',
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixIcon: const Icon(
                            Icons.monitor_weight_outlined,
                            color: AppColors.textSecondary,
                          ),
                          validator: (v) {
                            if (v != null &&
                                v.isNotEmpty &&
                                double.tryParse(v) == null) {
                              return 'Número válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;
                                final updatedPet = pet.copyWith(
                                  nombre: nombreCtrl.text.trim(),
                                  especie: especieCtrl.text.trim(),
                                  raza: razaCtrl.text.trim(),
                                  edad: int.parse(edadCtrl.text),
                                  peso: pesoCtrl.text.trim().isEmpty
                                      ? null
                                      : double.tryParse(pesoCtrl.text),
                                );
                                try {
                                  await Provider.of<PetsProvider>(
                                    context,
                                    listen: false,
                                  ).updateMascota(updatedPet);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Mascota actualizada con éxito',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.of(ctx).pop();
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                              ),
                              child: const Text(
                                'Guardar',
                                style: TextStyle(color: Colors.white),
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
        );
      },
    );
  }

  void _confirmDeletePet(String petId, String petName) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar mascota'),
          content: Text('¿Estás seguro de que deseas eliminar a "$petName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await Provider.of<PetsProvider>(
                    context,
                    listen: false,
                  ).deleteMascota(petId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mascota eliminada'),
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
              child: const Text(
                'Eliminar',
                style: TextStyle(color: AppColors.darkRed),
              ),
            ),
          ],
        );
      },
    );
  }

  void _refreshProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = auth.user?.uid;
    if (uid != null) {
      final clientProvider = Provider.of<ClientsProvider>(
        context,
        listen: false,
      );
      await clientProvider.fetchClientes(); // Recargar lista
      final updated = clientProvider.clientes.firstWhere(
        (c) => c.id == uid,
        orElse: () => _clientProfile!,
      );
      setState(() {
        _clientProfile = updated;
      });
    }
  }

  void _preloadCardDataForAppointment() {
    if (_clientProfile != null) {
      _appointmentCardController.text = _clientProfile!.tarjetaNumero ?? '';
      _appointmentCardNameController.text = _clientProfile!.tarjetaNombre ?? '';
      _appointmentExpiryController.text = _clientProfile!.tarjetaExpiry ?? '';
      _appointmentCvcController.text = _clientProfile!.tarjetaCvc ?? '';
    }
  }

  Widget _buildProfileTab() {
    if (_clientProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ClientProfileWidget(
      cliente: _clientProfile!,
      onProfileUpdated: _refreshProfile,
    );
  }

  // Método para enmascarar la tarjeta (ej: **** **** **** 1234)
  String _getMaskedCardNumber(String fullNumber) {
    final clean = fullNumber.replaceAll(RegExp(r'\s+'), '');
    if (clean.length < 4) return '****';
    final last4 = clean.substring(clean.length - 4);
    return '**** **** **** $last4';
  }

  // Punto de entrada al presionar "Pagar"
  void _processPayment() {
    if (_clientProfile != null &&
        _clientProfile!.tarjetaNumero != null &&
        _clientProfile!.tarjetaNumero!.isNotEmpty) {
      // Hay tarjeta guardada -> mostrar confirmación
      _showSavedCardConfirmationDialog();
    } else {
      // No hay tarjeta guardada -> formulario completo
      _showCheckoutDialog();
    }
  }

  // Diálogo para usar tarjeta guardada
  void _showSavedCardConfirmationDialog() {
    final TextEditingController addressController = TextEditingController(
      text: _clientProfile?.direccion ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Container(
                decoration: AppColors.glassDecoration(borderRadius: 20.0),
                padding: const EdgeInsets.all(20.0),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Usar tarjeta guardada',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.credit_card,
                              color: AppColors.darkBlue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getMaskedCardNumber(
                                  _clientProfile!.tarjetaNumero!,
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      CustomTextField(
                        controller: addressController,
                        labelText: 'Dirección de envío',
                        maxLines: 2,
                        prefixIcon: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.textSecondary,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingrese la dirección'
                            : null,
                      ),
                      const SizedBox(height: 24.0),
                      // 🔽 BOTONES EN VERTICAL 🔽
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (addressController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Ingrese la dirección de envío',
                                      ),
                                      backgroundColor: AppColors.darkRed,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.of(ctx).pop();
                                await _processOrderWithSavedCard(
                                  addressController.text.trim(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Confirmar compra',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                _showCheckoutDialog();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Usar otra tarjeta',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
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
        );
      },
    );
  }

  // Procesar pedido con tarjeta guardada
  Future<void> _processOrderWithSavedCard(String address) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final pedido = Pedido(
      id: '',
      clienteId: auth.user!.uid,
      clienteNombre:
          _clientProfile?.nombre ?? auth.user?.displayName ?? 'Cliente',
      fecha: DateTime.now(),
      total: cart.totalAmount,
      estado: 'Pendiente',
      numeroTarjeta: _clientProfile!.tarjetaNumero!,
      direccionEnvio: address,
    );

    final details = cart.items.map((item) {
      return DetallePedido(
        id: '',
        pedidoId: '',
        productoId: item.id,
        productoNombre: item.nombre,
        cantidad: item.cantidad,
        precioUnitario: item.precio,
        productoImagenUrl: item.imagenUrl,
      );
    }).toList();

    try {
      await Provider.of<OrdersProvider>(
        context,
        listen: false,
      ).addPedido(pedido, details);
      cart.clearCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Compra realizada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _currentTab = 3; // Ir a historial de pedidos
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar compra: $e'),
            backgroundColor: AppColors.darkRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _addressController.dispose();
    _petNameController.dispose();
    _petSpeciesController.dispose();
    _petBreedController.dispose();
    _petAgeController.dispose();
    _petPesoController.dispose();
    _appointmentDateController.dispose();
    _appointmentTimeController.dispose();
    _appointmentReasonController.dispose();
    _appointmentCardController.dispose();
    _appointmentCardNameController.dispose();
    _appointmentExpiryController.dispose();
    _appointmentCvcController.dispose();
    super.dispose();
  }

  void _openRegisterPetDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Container(
                decoration: AppColors.glassDecoration(borderRadius: 20.0),
                padding: const EdgeInsets.all(24.0),
                // Definimos una restricción de altura máxima basada en la pantalla
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Form(
                  key: _petFormKey,
                  child: SingleChildScrollView(
                    // 👈 Evita el overflow al abrir el teclado
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Registrar Mascota',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        CustomTextField(
                          controller: _petNameController,
                          labelText: 'Nombre',
                          prefixIcon: const Icon(
                            Icons.pets_rounded,
                            color: AppColors.textSecondary,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Ingrese el nombre'
                              : null,
                        ),
                        const SizedBox(height: 12.0),
                        CustomTextField(
                          controller: _petSpeciesController,
                          labelText: 'Especie (ej. Perro, Gato)',
                          prefixIcon: const Icon(
                            Icons.category_rounded,
                            color: AppColors.textSecondary,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Ingrese la especie'
                              : null,
                        ),
                        const SizedBox(height: 12.0),
                        CustomTextField(
                          controller: _petBreedController,
                          labelText: 'Raza (Opcional)',
                          prefixIcon: const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        CustomTextField(
                          controller: _petAgeController,
                          labelText: 'Edad (años)',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(
                            Icons.cake_rounded,
                            color: AppColors.textSecondary,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Ingrese la edad';
                            if (int.tryParse(v) == null)
                              return 'Ingrese un número válido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12.0),
                        CustomTextField(
                          controller: _petPesoController,
                          labelText: 'Peso (kg) - Opcional',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixIcon: const Icon(
                            Icons.monitor_weight_outlined,
                            color: AppColors.textSecondary,
                          ),
                          validator: (v) {
                            if (v != null &&
                                v.isNotEmpty &&
                                double.tryParse(v) == null) {
                              return 'Ingrese un número válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                _petNameController.clear();
                                _petSpeciesController.clear();
                                _petBreedController.clear();
                                _petAgeController.clear();
                                _petPesoController.clear();
                                Navigator.of(ctx).pop();
                              },
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                if (!_petFormKey.currentState!.validate())
                                  return;
                                final auth = Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                );
                                final pet = Mascota(
                                  id: '',
                                  nombre: _petNameController.text.trim(),
                                  especie: _petSpeciesController.text.trim(),
                                  raza: _petBreedController.text.trim(),
                                  edad: int.parse(_petAgeController.text),
                                  peso: _petPesoController.text.trim().isEmpty
                                      ? null
                                      : double.tryParse(
                                          _petPesoController.text,
                                        ),
                                  clienteId: auth.user!.uid,
                                );
                                try {
                                  await Provider.of<PetsProvider>(
                                    context,
                                    listen: false,
                                  ).addMascota(pet);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Mascota registrada con éxito',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    _petNameController.clear();
                                    _petSpeciesController.clear();
                                    _petBreedController.clear();
                                    _petAgeController.clear();
                                    _petPesoController.clear();
                                    Navigator.of(ctx).pop();
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                              ),
                              child: const Text(
                                'Guardar',
                                style: TextStyle(color: Colors.white),
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
        );
      },
    );
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    decoration: AppColors.glassDecoration(borderRadius: 20.0),
                    padding: const EdgeInsets.all(20.0), // Reduje de 24 a 20
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                    ),
                    child: Form(
                      key: _checkoutFormKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Pagar Pedido',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16.0), // Reduje de 20 a 16
                            CustomTextField(
                              controller: _cardController,
                              labelText: 'Número de tarjeta (16 dígitos)',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(
                                Icons.credit_card_rounded,
                                color: AppColors.textSecondary,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Ingrese su tarjeta';
                                final clean = v.replaceAll(RegExp(r'\s+'), '');
                                if (clean.length != 16 ||
                                    int.tryParse(clean) == null) {
                                  return 'Debe tener exactamente 16 dígitos';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10.0), // Reduje de 12 a 10
                            CustomTextField(
                              controller: _cardNameController,
                              labelText: 'Nombre en la tarjeta',
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.textSecondary,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Ingrese el nombre del titular'
                                  : null,
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _expiryController,
                                    labelText: 'Fecha vencimiento (MM/YY)',
                                    prefixIcon: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return 'Requerido';
                                      final pattern = RegExp(
                                        r'^(0[1-9]|1[0-2])\/\d{2}$',
                                      );
                                      if (!pattern.hasMatch(v.trim())) {
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
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return 'Requerido';
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
                            const SizedBox(height: 10.0),
                            CustomTextField(
                              controller: _addressController,
                              labelText: 'Dirección de envío',
                              maxLines: 2,
                              prefixIcon: const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.textSecondary,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Ingrese la dirección'
                                  : null,
                            ),
                            const SizedBox(height: 12.0),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Guardar datos de pago',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                ),
                              ),
                              value: _savePaymentData,
                              onChanged: (value) {
                                setStateDialog(() {
                                  _savePaymentData = value;
                                });
                              },
                              activeColor: AppColors.darkBlue,
                            ),
                            const SizedBox(height: 16.0), // Reduje de 24 a 16
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  // 👈 Envolver en Expanded para evitar overflow horizontal
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // ... el código del botón queda igual
                                      if (!_checkoutFormKey.currentState!
                                          .validate())
                                        return;

                                      final cart = Provider.of<CartProvider>(
                                        context,
                                        listen: false,
                                      );
                                      final auth = Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      );
                                      final clientProvider =
                                          Provider.of<ClientsProvider>(
                                            context,
                                            listen: false,
                                          );

                                      final pedido = Pedido(
                                        id: '',
                                        clienteId: auth.user!.uid,
                                        clienteNombre:
                                            _clientProfile?.nombre ??
                                            auth.user?.displayName ??
                                            'Cliente',
                                        fecha: DateTime.now(),
                                        total: cart.totalAmount,
                                        estado: 'Pendiente',
                                        numeroTarjeta: _cardController.text
                                            .trim(),
                                        direccionEnvio: _addressController.text
                                            .trim(),
                                      );

                                      final details = cart.items.map((item) {
                                        return DetallePedido(
                                          id: '',
                                          pedidoId: '',
                                          productoId: item.id,
                                          productoNombre: item.nombre,
                                          cantidad: item.cantidad,
                                          precioUnitario: item.precio,
                                          productoImagenUrl: item.imagenUrl,
                                        );
                                      }).toList();

                                      try {
                                        await Provider.of<OrdersProvider>(
                                          context,
                                          listen: false,
                                        ).addPedido(pedido, details);

                                        if (_savePaymentData) {
                                          final currentClient = _clientProfile;
                                          if (currentClient != null) {
                                            final updatedClient = currentClient
                                                .copyWith(
                                                  tarjetaNumero: _cardController
                                                      .text
                                                      .trim(),
                                                  tarjetaNombre:
                                                      _cardNameController.text
                                                          .trim(),
                                                  tarjetaExpiry:
                                                      _expiryController.text
                                                          .trim(),
                                                  tarjetaCvc: _cvcController
                                                      .text
                                                      .trim(),
                                                );
                                            await clientProvider.updateCliente(
                                              updatedClient,
                                            );
                                            setState(() {
                                              _clientProfile = updatedClient;
                                            });
                                          }
                                        }

                                        cart.clearCart();
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '¡Compra realizada con éxito!',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          _cardController.clear();
                                          _cardNameController.clear();
                                          _expiryController.clear();
                                          _cvcController.clear();
                                          Navigator.of(ctx).pop();
                                          setState(() {
                                            _currentTab = 3;
                                          });
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error al procesar compra: $e',
                                              ),
                                              backgroundColor:
                                                  AppColors.darkRed,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.darkRed,
                                    ),
                                    child: const Text(
                                      'Confirmar compra',
                                      style: TextStyle(color: Colors.white),
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
            );
          },
        );
      },
    );
  }

  Future<void> _selectAppointmentDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _appointmentDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectAppointmentTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      if (mounted) {
        setState(() {
          _appointmentTimeController.text = picked.format(context);
        });
      }
    }
  }

  void _bookAppointment() async {
    if (!_appointmentFormKey.currentState!.validate()) return;
    if (_selectedMascotaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione una mascota para la cita'),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return;
    }

    // Validar datos de tarjeta si se eligió ese método
    if (_selectedMetodoPago == 'Tarjeta') {
      if (_appointmentCardController.text.trim().isEmpty ||
          _appointmentCardNameController.text.trim().isEmpty ||
          _appointmentExpiryController.text.trim().isEmpty ||
          _appointmentCvcController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete los datos de la tarjeta'),
            backgroundColor: AppColors.darkRed,
          ),
        );
        return;
      }
      final cleanCard = _appointmentCardController.text.replaceAll(
        RegExp(r'\s+'),
        '',
      );
      if (cleanCard.length != 16 || int.tryParse(cleanCard) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Número de tarjeta inválido (16 dígitos)'),
            backgroundColor: AppColors.darkRed,
          ),
        );
        return;
      }
      final expiryPattern = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
      if (!expiryPattern.hasMatch(_appointmentExpiryController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fecha de expiración inválida (MM/YY)'),
            backgroundColor: AppColors.darkRed,
          ),
        );
        return;
      }
      final cvc = _appointmentCvcController.text.trim();
      if (cvc.length < 3 || cvc.length > 4 || int.tryParse(cvc) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CVC inválido'),
            backgroundColor: AppColors.darkRed,
          ),
        );
        return;
      }

      // Si todo ok, marcar como pagado
      _appointmentEstadoPago = 'Pagado';
    } else {
      _appointmentEstadoPago = 'Presencial';
    }
    if (_selectedMetodoPago == 'Tarjeta' && _saveCardDataForAppointment) {
      final clientProvider = Provider.of<ClientsProvider>(
        context,
        listen: false,
      );
      final currentClient = _clientProfile;
      if (currentClient != null) {
        final updatedClient = currentClient.copyWith(
          tarjetaNumero: _appointmentCardController.text.trim(),
          tarjetaNombre: _appointmentCardNameController.text.trim(),
          tarjetaExpiry: _appointmentExpiryController.text.trim(),
          tarjetaCvc: _appointmentCvcController.text.trim(),
        );
        await clientProvider.updateCliente(updatedClient);
        setState(() {
          _clientProfile = updatedClient;
        });
      }
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final appointmentsProvider = Provider.of<AppointmentsProvider>(
      context,
      listen: false,
    );

    final cita = Cita(
      id: '',
      clienteId: auth.user!.uid,
      clienteNombre:
          _clientProfile?.nombre ?? auth.user?.displayName ?? 'Cliente',
      mascotaId: _selectedMascotaId!,
      mascotaNombre: _selectedMascotaNombre!,
      fecha: _appointmentDateController.text,
      hora: _appointmentTimeController.text,
      motivoTipo: _selectedMotivoTipo,
      precio: _selectedPrecio,
      metodoPago: _selectedMetodoPago,
      estadoPago: _appointmentEstadoPago,
      sucursalId: _selectedSucursalId!,
      sucursalNombre: _selectedSucursalNombre!,
      estado: 'Pendiente',
    );

    try {
      await appointmentsProvider.addCita(cita);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita programada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        // Limpiar formulario
        _appointmentDateController.clear();
        _appointmentTimeController.clear();
        setState(() {
          _selectedMascotaId = null;
          _selectedMascotaNombre = null;
          _selectedMotivoTipo = 'Consulta Veterinaria';
          _selectedPrecio = 250.0;
          _selectedMetodoPago = 'Presencial';
          _showCardFormForAppointment = false;
          _appointmentEstadoPago = 'Presencial';
          _appointmentCardController.clear();
          _appointmentCardNameController.clear();
          _appointmentExpiryController.clear();
          _appointmentCvcController.clear();
          _saveCardDataForAppointment = false;
        });
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

  Widget _buildProductsTab() {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final size = MediaQuery.of(context).size;

    final filteredProducts = _selectedCategory == 'Todos'
        ? productsProvider.productos
        : productsProvider.productos.where((p) {
            return p.categoria.toLowerCase() == _selectedCategory.toLowerCase();
          }).toList();

    return Stack(
      children: [
        productsProvider.loading
            ? const Center(child: CircularProgressIndicator())
            : productsProvider.productos.isEmpty
            ? const Center(
                child: Text(
                  'No hay productos disponibles',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              )
            : Column(
                children: [
                  // BOTONES DE CATEGORÍAS
                  // BOTONES DE CATEGORÍAS
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;

                        return ChoiceChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: AppColors.darkBlue,
                          backgroundColor: Colors.white.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // GRID DE PRODUCTOS
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay productos en esta categoría',
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16.0),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: size.width > 900
                                  ? 4
                                  : (size.width > 600 ? 3 : 2),
                              // 👇 Aspect ratio dinámico: más alto en móviles pequeños
                              childAspectRatio:
                                  MediaQuery.of(context).size.width < 400
                                  ? 0.62
                                  : 0.72,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final p = filteredProducts[index];
                              // El resto del builder se mantiene igual
                              return GestureDetector(
                                onTap: () =>
                                    context.push('/product-detail', extra: p),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 12.0,
                                      sigmaY: 12.0,
                                    ),
                                    child: Container(
                                      decoration: AppColors.glassDecoration(
                                        borderRadius: 16.0,
                                      ),
                                      padding: const EdgeInsets.all(
                                        8.0,
                                      ), // Reduje el padding interno
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize:
                                            MainAxisSize.min, // 👈 Importante
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                            child:
                                                p.imagenUrl != null &&
                                                    p.imagenUrl!.isNotEmpty
                                                ? Image.network(
                                                    p.imagenUrl!,
                                                    height:
                                                        120, // Bajé de 140 a 120 para dar más espacio
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Container(
                                                          height: 120,
                                                          width:
                                                              double.infinity,
                                                          color: AppColors
                                                              .primaryBlue
                                                              .withOpacity(0.3),
                                                          child: const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size: 48,
                                                            color: AppColors
                                                                .textSecondary,
                                                          ),
                                                        ),
                                                  )
                                                : Container(
                                                    height: 120,
                                                    width: double.infinity,
                                                    color: AppColors.primaryBlue
                                                        .withOpacity(0.3),
                                                    child: const Icon(
                                                      Icons.pets_rounded,
                                                      size: 48,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            p.nombre,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.0,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            p.categoria,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              color: AppColors.textSecondary,
                                              fontSize: 10.0,
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '\$${p.precio.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.darkRed,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons
                                                      .add_shopping_cart_rounded,
                                                  color: AppColors.darkBlue,
                                                  size: 20,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () {
                                                  cartProvider.addProducto(p);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).hideCurrentSnackBar();
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '${p.nombre} agregado al carrito',
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 1,
                                                      ),
                                                      backgroundColor:
                                                          AppColors.darkBlue,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildCartTab() {
    final cartProvider = Provider.of<CartProvider>(context);
    final items = cartProvider.items; // ← ya es List<CartItem>

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tu carrito está vacío',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  color: Colors.white.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child:
                              item.imagenUrl != null &&
                                  item.imagenUrl!.isNotEmpty
                              ? Image.network(
                                  item.imagenUrl!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 48,
                                        height: 48,
                                        color: AppColors.primaryBlue
                                            .withOpacity(0.3),
                                        child: const Icon(Icons.pets_rounded),
                                      ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                  child: const Icon(Icons.pets_rounded),
                                ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                '\$${item.precio.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.darkRed,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline_rounded,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => cartProvider.updateQuantity(
                                item.id,
                                item.cantidad - 1,
                              ),
                            ),
                            Text(
                              '${item.cantidad}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: AppColors.darkBlue,
                              ),
                              onPressed: () => cartProvider.updateQuantity(
                                item.id,
                                item.cantidad + 1,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.darkRed,
                          ),
                          onPressed: () => cartProvider.removeItem(item.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: AppColors.glassDecoration(borderRadius: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total a pagar:',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                    ),
                    child: const Text(
                      'Pagar',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsAndAppointmentsTab() {
    final petsProvider = Provider.of<PetsProvider>(context);
    final appointmentsProvider = Provider.of<AppointmentsProvider>(context);
    final pets = petsProvider.mascotas;
    final appointments = appointmentsProvider.citas;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Mis Mascotas (horizontal) ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Mascotas',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: _openRegisterPetDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          petsProvider.loading
              ? const Center(child: CircularProgressIndicator())
              : pets.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: AppColors.glassDecoration(),
                  child: const Center(
                    child: Text(
                      'Registra tu primer mascota para agendar citas',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 150, // Aumentado de 130 a 150 eyeyeyey
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return Container(
                        width: 150, // Aumentado de 140 a 150
                        margin: const EdgeInsets.only(right: 12),
                        decoration: AppColors.glassDecoration(borderRadius: 12),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min, // 👈 Clave para evitar overflow
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryRed,
                              child: Icon(
                                Icons.pets_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pet.nombre,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${pet.especie} • ${pet.edad} ${pet.edad == 1 ? 'año' : 'años'}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: AppColors.darkBlue,
                                  ),
                                  onPressed: () => _openEditPetDialog(pet),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppColors.darkRed,
                                  ),
                                  onPressed: () =>
                                      _confirmDeletePet(pet.id, pet.nombre),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 32),

          // ---------- Agendar Cita Veterinaria ----------
          const Text(
            'Agendar Cita Veterinaria',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppColors.glassDecoration(),
            child: pets.isEmpty
                ? const Center(
                    child: Text(
                      'Debe registrar una mascota para agendar citas.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : Form(
                    key: _appointmentFormKey,
                    child: Column(
                      children: [
                        // Mascota dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedMascotaId,
                          decoration: InputDecoration(
                            labelText: 'Seleccionar Mascota',
                            prefixIcon: const Icon(
                              Icons.pets_rounded,
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.65),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          items: pets
                              .map(
                                (m) => DropdownMenuItem<String>(
                                  value: m.id,
                                  child: Text(m.nombre),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final pet = pets.firstWhere((p) => p.id == val);
                              setState(() {
                                _selectedMascotaId = val;
                                _selectedMascotaNombre = pet.nombre;
                              });
                            }
                          },
                          validator: (val) =>
                              val == null ? 'Seleccione una mascota' : null,
                        ),
                        const SizedBox(height: 12.0),

                        // Fecha
                        InkWell(
                          onTap: _selectAppointmentDate,
                          child: IgnorePointer(
                            child: CustomTextField(
                              controller: _appointmentDateController,
                              labelText: 'Seleccionar Fecha',
                              prefixIcon: const Icon(
                                Icons.calendar_today_rounded,
                                color: AppColors.textSecondary,
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Seleccione una fecha'
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),

                        // Hora
                        InkWell(
                          onTap: _selectAppointmentTime,
                          child: IgnorePointer(
                            child: CustomTextField(
                              controller: _appointmentTimeController,
                              labelText: 'Seleccionar Hora',
                              prefixIcon: const Icon(
                                Icons.access_time_rounded,
                                color: AppColors.textSecondary,
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Seleccione una hora'
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),

                        // Motivo de consulta (dropdown con precios)
                        DropdownButtonFormField<String>(
                          value: _selectedMotivoTipo,
                          isExpanded: true, // 👈 Evita desborde horizontal
                          decoration: InputDecoration(
                            labelText: 'Motivo de consulta',
                            prefixIcon: const Icon(
                              Icons.medical_services_rounded,
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.65),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ), // 👈 Reduce padding vertical
                          ),
                          items: _motivosPrecios.keys.map((motivo) {
                            return DropdownMenuItem<String>(
                              value: motivo,
                              child: Text(
                                '$motivo (\$${_motivosPrecios[motivo]!.toInt()})',
                                overflow: TextOverflow
                                    .ellipsis, // 👈 Por si el texto es muy largo
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedMotivoTipo = value;
                                _selectedPrecio = _motivosPrecios[value]!;
                              });
                            }
                          },
                          validator: (val) =>
                              val == null ? 'Seleccione un motivo' : null,
                        ),
                        const SizedBox(height: 12.0),

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
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          items: _sucursales.map((s) {
                            return DropdownMenuItem<String>(
                              value: s.id,
                              child: Text(s.nombre),
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
                          validator: (val) =>
                              val == null ? 'Seleccione una sucursal' : null,
                        ),
                        const SizedBox(height: 12.0),
                        // Método de pago
                        DropdownButtonFormField<String>(
                          value: _selectedMetodoPago,
                          decoration: InputDecoration(
                            labelText: 'Método de pago',
                            prefixIcon: const Icon(
                              Icons.payment_rounded,
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.65),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Presencial',
                              child: Text('Presencial'),
                            ),
                            DropdownMenuItem(
                              value: 'Tarjeta',
                              child: Text('Tarjeta de crédito/débito'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedMetodoPago = value!;
                              _showCardFormForAppointment =
                                  (value == 'Tarjeta');
                              if (value == 'Presencial') {
                                _appointmentEstadoPago = 'Presencial';
                              } else {
                                _appointmentEstadoPago = 'Pendiente';
                              }
                            });
                          },
                          validator: (val) =>
                              val == null ? 'Seleccione método de pago' : null,
                        ),
                        const SizedBox(height: 12.0),

                        // Formulario de tarjeta (si se eligió Tarjeta)
                        if (_showCardFormForAppointment)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                CustomTextField(
                                  controller: _appointmentCardController,
                                  labelText: 'Número de tarjeta (16 dígitos)',
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(
                                    Icons.credit_card_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                CustomTextField(
                                  controller: _appointmentCardNameController,
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
                                        controller:
                                            _appointmentExpiryController,
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
                                        controller: _appointmentCvcController,
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
                                const SizedBox(height: 12),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Guardar datos de pago',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                  ),
                                  value: _saveCardDataForAppointment,
                                  onChanged: (value) {
                                    setState(() {
                                      _saveCardDataForAppointment = value;
                                    });
                                  },
                                  activeColor: AppColors.darkBlue,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20.0),

                        // Botón agendar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _bookAppointment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkBlue,
                            ),
                            child: const Text(
                              'Agendar Cita',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 32),

          // ---------- Mis Citas Programadas (vertical) ----------
          const Text(
            'Mis Citas Programadas',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          appointmentsProvider.loading
              ? const Center(child: CircularProgressIndicator())
              : appointments.isEmpty
              ? const Text(
                  'No tienes citas agendadas.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final cita = appointments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      color: Colors.white.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primaryBlue,
                          child: Icon(
                            Icons.medical_services_rounded,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          'Cita de ${cita.mascotaNombre} - ${cita.estado}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha: ${cita.fecha} a las ${cita.hora}'),
                            Text(
                              'Motivo: ${cita.motivoTipo} (\$${cita.precio.toInt()})',
                            ),
                            Text('Sucursal: ${cita.sucursalNombre}'),
                            Text(
                              'Pago: ${cita.metodoPago == 'Tarjeta' ? cita.estadoPago : cita.metodoPago}',
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: AppColors.darkRed,
                          ),
                          onPressed: () async {
                            try {
                              await appointmentsProvider.deleteCita(cita.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cita cancelada con éxito'),
                                  ),
                                );
                              }
                            } catch (e) {}
                          },
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    final ordersProvider = Provider.of<OrdersProvider>(context);
    final orders = ordersProvider.pedidos;

    return ordersProvider.loading
        ? const Center(child: CircularProgressIndicator())
        : orders.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 64,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No tienes pedidos anteriores.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final shortId = order.id.length > 6
                  ? order.id.substring(order.id.length - 6).toUpperCase()
                  : order.id;
              final dateStr =
                  '${order.fecha.day}/${order.fecha.month}/${order.fecha.year}';

              Color statusColor = AppColors.darkBlue;
              if (order.estado == 'Entregado')
                statusColor = Colors.green.shade400;
              if (order.estado == 'Enviado')
                statusColor = Colors.purple.shade300;
              if (order.estado == 'Cancelado') statusColor = AppColors.darkRed;

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                color: Colors.white.withOpacity(0.75),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Pedido #$shortId',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  subtitle: Text(
                    'Fecha: $dateStr • Total: \$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      order.estado,
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  children: [
                    FutureBuilder<List<DetallePedido>>(
                      future: ordersProvider.fetchDetalles(order.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          );
                        }
                        final list = snapshot.data ?? [];
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dirección: ${order.direccionEnvio}',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              const Text(
                                'Productos:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                ),
                              ),
                              ...list.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4.0,
                                            ),
                                            child:
                                                item.productoImagenUrl !=
                                                        null &&
                                                    item
                                                        .productoImagenUrl!
                                                        .isNotEmpty
                                                ? Image.network(
                                                    item.productoImagenUrl!,
                                                    width: 30,
                                                    height: 30,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            const Icon(
                                                              Icons.image,
                                                              size: 30,
                                                            ),
                                                  )
                                                : Container(
                                                    width: 30,
                                                    height: 30,
                                                    color: AppColors.primaryBlue
                                                        .withOpacity(0.3),
                                                    child: const Icon(
                                                      Icons.pets_rounded,
                                                      size: 18,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${item.cantidad} x ${item.productoNombre}',
                                            style: const TextStyle(
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '\$${item.subtotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName =
        _clientProfile?.nombre ?? authProvider.user?.displayName ?? 'Cliente';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _currentTab == 0
              ? 'Catálogo de Tienda'
              : _currentTab == 1
              ? 'Carrito de Compras'
              : _currentTab == 2
              ? 'Mascotas y Citas'
              : _currentTab == 3
              ? 'Historial de Pedidos'
              : 'Mi Perfil',
        ),
        actions: [
          if (_currentTab == 0)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_rounded,
                    color: AppColors.darkBlue,
                  ),
                  onPressed: () => setState(() => _currentTab = 1),
                ),
                Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    if (cart.itemCount == 0) return const SizedBox();
                    return Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.darkRed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                if (_currentTab == 0 || _currentTab == 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '¡Hola, $userName! 👋',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: _currentTab == 0
                      ? _buildProductsTab()
                      : _currentTab == 1
                      ? _buildCartTab()
                      : _currentTab == 2
                      ? _buildPetsAndAppointmentsTab()
                      : _currentTab == 3
                      ? _buildOrdersTab()
                      : _buildProfileTab(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        selectedItemColor: AppColors.darkBlue,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_rounded),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_rounded),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
