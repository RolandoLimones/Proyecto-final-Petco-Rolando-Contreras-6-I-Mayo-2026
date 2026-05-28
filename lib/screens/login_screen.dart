import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

      // Verify user is not a client
      final firestoreService = FirestoreService();
      final isClient =
          await firestoreService.getClienteById(authProvider.user!.uid) != null;
      if (isClient) {
        await authProvider.signOut();
        throw Exception(
          "Esta cuenta es de un cliente. Utilice la sección de Clientes para ingresar.",
        );
      }

      if (mounted) {
        context.go('/home');
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
      appBar: AppBar(title: const Text('Acceso Administrador')),
      body: Stack(
        children: [
          Positioned(
            top: size.height * 0.15,
            left: -50,
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
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 450),
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
                              Icons.admin_panel_settings_rounded,
                              size: 48.0,
                              color: AppColors.darkRed,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'Administrador',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Inicia sesión para gestionar la tienda',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.0,
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
                                return 'Por favor ingresa tu correo';
                              }
                              final emailRegex = RegExp(
                                r'^[^@]+@[^@]+\.[^@]+$',
                              );
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Ingresa un correo válido';
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
                                return 'Por favor ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32.0),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authProvider.loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkRed,
                                foregroundColor: Colors.white,
                                shadowColor: AppColors.primaryRed.withOpacity(
                                  0.4,
                                ),
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: authProvider.loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Ingresar como Admin',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          OutlinedButton(
                            onPressed: () {
                              context.push('/login');
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.darkBlue,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'Acceso Cliente',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),

                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                context.push('/admin/register');
                              },
                              style: TextButton.styleFrom(
                                alignment: Alignment.center,
                              ),
                              child: const Text.rich(
                                TextSpan(
                                  text: '¿No tienes cuenta de admin? ',
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
                                        color: AppColors.darkBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
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
