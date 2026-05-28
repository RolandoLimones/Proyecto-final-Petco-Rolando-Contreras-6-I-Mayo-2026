import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityCodeController = TextEditingController(); // NUEVO

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityCodeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar código de seguridad localmente
    if (_securityCodeController.text.trim() != "0812petco") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código de seguridad incorrecto'),
          backgroundColor: AppColors.darkRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim(),
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
      appBar: AppBar(title: const Text('Registro Administrador')),
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
                              color: AppColors.primaryBlue.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              size: 40.0,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'Registro Administrador',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          const Text(
                            'Crea una cuenta de administrador',
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa tu nombre';
                              }
                              return null;
                            },
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
                          const SizedBox(height: 16.0),

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
                              if (value == null || value.isEmpty) {
                                return 'Por favor confirma tu contraseña';
                              }
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),

                          // NUEVO: Campo para código de seguridad
                          CustomTextField(
                            controller: _securityCodeController,
                            labelText: 'Código de seguridad',
                            obscureText: true,
                            prefixIcon: const Icon(
                              Icons.security_rounded,
                              color: AppColors.textSecondary,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa el código de seguridad';
                              }
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
                                backgroundColor: AppColors.darkBlue,
                                foregroundColor: Colors.white,
                                shadowColor: AppColors.primaryBlue.withOpacity(
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
                                      'Crear cuenta admin',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              style: TextButton.styleFrom(
                                alignment: Alignment.center,
                              ),
                              child: const Text.rich(
                                TextSpan(
                                  text: '¿Ya tienes cuenta de admin? ',
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
                                        color: AppColors.darkRed,
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
