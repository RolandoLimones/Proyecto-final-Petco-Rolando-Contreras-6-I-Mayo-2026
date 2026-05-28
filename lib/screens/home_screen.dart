import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userName = user?.displayName ?? 'Usuario';

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
              centerTitle: false,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      size: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  const Text(
                    'PetcoShop',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.exit_to_app_rounded,
                    color: AppColors.darkRed,
                    size: 26.0,
                  ),
                  onPressed: () async {
                    await authProvider.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
                const SizedBox(width: 8.0),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background decoration circles
          Positioned(
            top: -30,
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  // Welcome Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: AppColors.glassDecoration(
                          borderRadius: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, $userName 👋',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            const Text(
                              '¿Qué te gustaría gestionar el día de hoy?',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.0,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Menu Grid
                  Expanded(
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size.width > 900
                            ? 4
                            : (size.width > 600 ? 3 : 2),
                        // 👇 Nuevos aspect ratios: más altura (valor más pequeño)
                        childAspectRatio: size.width > 900
                            ? 0.9
                            : (size.width > 600 ? 0.85 : 0.8),
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      children: [
                        _buildMenuCard(
                          context: context,
                          title: 'Productos',
                          subtitle: 'Catálogo de productos',
                          icon: Icons.storefront_rounded,
                          color: AppColors.primaryBlue,
                          route: '/productos',
                        ),
                        _buildMenuCard(
                          context: context,
                          title: 'Mascotas',
                          subtitle: 'Registro de mascotas',
                          icon: Icons.pets_rounded,
                          color: AppColors.primaryRed,
                          route: '/mascotas',
                        ),
                        _buildMenuCard(
                          context: context,
                          title: 'Clientes',
                          subtitle: 'Control de clientes',
                          icon: Icons.people_alt_rounded,
                          color: AppColors.primaryBlue,
                          route: '/clientes',
                        ),
                        _buildMenuCard(
                          context: context,
                          title: 'Citas',
                          subtitle: 'Citas programadas',
                          icon: Icons.calendar_month_rounded,
                          color: AppColors.primaryRed,
                          route: '/citas',
                        ),
                        _buildMenuCard(
                          context: context,
                          title: 'Pedidos',
                          subtitle: 'Historial de compras',
                          icon: Icons.receipt_long_rounded,
                          color: AppColors.primaryBlue,
                          route: '/pedidos',
                        ),
                        _buildMenuCard(
                          context: context,
                          title: 'Sucursales',
                          subtitle: 'Ubicaciones de tiendas',
                          icon: Icons.store_mall_directory_rounded,
                          color: AppColors.primaryRed,
                          route: '/sucursales',
                        ),
                        _buildMenuCard(
                          context: context,
                          title: 'Proveedores',
                          subtitle: 'Lista de proveedores',
                          icon: Icons.local_shipping_rounded,
                          color: AppColors.primaryBlue,
                          route: '/proveedores',
                        ),
                        _buildMenuCard(
                          context: context,
                          title: 'Carritos',
                          subtitle: 'Carritos de clientes',
                          icon: Icons.shopping_cart_rounded,
                          color: AppColors.primaryRed,
                          route: '/carritos',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              decoration: AppColors.glassDecoration(borderRadius: 16.0),
              padding: const EdgeInsets.all(16.0), // Antes 24
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Evita desborde
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0), // Antes 20
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40.0, // Antes 48
                      color: color == AppColors.primaryBlue
                          ? AppColors.darkBlue
                          : AppColors.darkRed,
                    ),
                  ),
                  const SizedBox(height: 12.0), // Antes 20
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20.0, // Antes 22
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6.0), // Antes 8
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.0, // Antes 13
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
