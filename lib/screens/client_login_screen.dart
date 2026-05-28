import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({Key? key}) : super(key: key);

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final firestoreService = FirestoreService();
      final isClient =
          await firestoreService.getClienteById(authProvider.user!.uid) != null;
      if (!isClient) {
        await authProvider.signOut();
        throw Exception(
          "Esta cuenta no está registrada como cliente. Use acceso administrador si corresponde.",
        );
      }

      if (mounted) {
        context.go('/client/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e
                  .toString()
                  .replaceAll(RegExp(r'\[.*?\]'), '')
                  .replaceAll('Exception:', '')
                  .trim(),
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: AppColors.darkRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
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
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Petco',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Tienda de mascotas',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.0,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            top: size.height * 0.1,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.1,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed,
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  // Imagen del banner
                  Image.network(
                    'https://raw.githubusercontent.com/RolandoLimones/misimagenesPetco/refs/heads/main/v2petco.png',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 32.0),

                  // Contenedor del formulario (glassmorphism)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 450),
                        decoration: AppColors.glassDecoration(
                          borderRadius: 24.0,
                        ),
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.people_rounded,
                                  size: 48.0,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Accede a tu cuenta de cliente',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.0,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 32.0),

                              CustomTextField(
                                controller: _emailController,
                                labelText: 'Correo electrónico',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingrese tu correo';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20.0),

                              CustomTextField(
                                controller: _passwordController,
                                labelText: 'Contraseña',
                                obscureText: true,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: AppColors.textSecondary,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese tu contraseña';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32.0),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: authProvider.loading
                                      ? null
                                      : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: authProvider.loading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Ingresar',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24.0),

                              TextButton(
                                onPressed: () {
                                  context.push('/register');
                                },
                                child: RichText(
                                  text: const TextSpan(
                                    text: '¿No tienes cuenta? ',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14.0,
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Regístrate aquí',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              OutlinedButton(
                                onPressed: () {
                                  context.push('/admin/login');
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.darkRed,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Text(
                                  'Acceso Administrador',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
