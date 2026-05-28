import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/clients_provider.dart';
import '../models/cliente_model.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({Key? key}) : super(key: key);

  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clientsProvider = Provider.of<ClientsProvider>(
      context,
      listen: false,
    );
    final firestoreService = FirestoreService(); // Importar FirestoreService

    try {
      // 1. Create Auth User
      await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      // 2. Add to Clientes collection directly (sin usar addCliente)
      final uid = authProvider.user!.uid;
      final cliente = Cliente(
        id: uid,
        nombre: _nameController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _phoneController.text.trim(),
        direccion: _addressController.text.trim(),
      );

      // Guardar directamente en Firestore
      await firestoreService.setDocument('clientes', uid, cliente.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta de cliente registrada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/client/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.darkRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Registro de Clientes')),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.05,
            left: -65,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 480),
                    decoration: AppColors.glassDecoration(borderRadius: 24.0),
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 40.0,
                              color: AppColors.darkRed,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'Regístrate para comprar y agendar citas',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.0,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24.0),

                          CustomTextField(
                            controller: _nameController,
                            labelText: 'Nombre completo',
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.textSecondary,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Ingrese su nombre'
                                : null,
                          ),
                          const SizedBox(height: 16.0),

                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Correo electrónico',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.textSecondary,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Ingrese su correo';
                              final emailRegex = RegExp(
                                r'^[^@]+@[^@]+\.[^@]+$',
                              );
                              if (!emailRegex.hasMatch(value.trim()))
                                return 'Ingrese un correo válido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),

                          CustomTextField(
                            controller: _phoneController,
                            labelText: 'Teléfono',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(
                              Icons.phone_rounded,
                              color: AppColors.textSecondary,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Ingrese su teléfono'
                                : null,
                          ),
                          const SizedBox(height: 16.0),

                          CustomTextField(
                            controller: _addressController,
                            labelText: 'Dirección de envío',
                            maxLines: 2,
                            prefixIcon: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.textSecondary,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Ingrese su dirección'
                                : null,
                          ),
                          const SizedBox(height: 16.0),

                          CustomTextField(
                            controller: _passwordController,
                            labelText: 'Contraseña',
                            obscureText: true,
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.textSecondary,
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Ingrese una contraseña'
                                : (value.length < 6
                                      ? 'Mínimo 6 caracteres'
                                      : null),
                          ),
                          const SizedBox(height: 16.0),

                          CustomTextField(
                            controller: _confirmPasswordController,
                            labelText: 'Confirmar contraseña',
                            obscureText: true,
                            prefixIcon: const Icon(
                              Icons.lock_reset_rounded,
                              color: AppColors.textSecondary,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Confirme su contraseña';
                              if (value != _passwordController.text)
                                return 'Las contraseñas no coinciden';
                              return null;
                            },
                          ),
                          const SizedBox(height: 28.0),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authProvider.loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkRed,
                                foregroundColor: Colors.white,
                              ),
                              child: authProvider.loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Registrarse',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          TextButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: '¿Ya tienes cuenta? ',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14.0,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Inicia sesión',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextButton(
                            onPressed: () {
                              context.push('/admin/register');
                            },
                            child: const Text(
                              'Registrarse como administrador',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.darkRed,
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
