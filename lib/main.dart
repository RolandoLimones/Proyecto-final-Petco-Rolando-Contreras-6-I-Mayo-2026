import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'utils/app_colors.dart';
import 'services/firestore_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/products_provider.dart';
import 'providers/pets_provider.dart';
import 'providers/clients_provider.dart';
import 'providers/appointments_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/branches_provider.dart';
import 'providers/providers_provider.dart';
import 'providers/cart_provider.dart';

// Models
import 'models/producto_model.dart';
import 'models/mascota_model.dart';
import 'models/cliente_model.dart';
import 'models/cita_model.dart';
import 'models/sucursal_model.dart';
import 'models/proveedor_model.dart';
import 'providers/carritos_provider.dart';
import 'models/carrito_model.dart';
// Screens
// Cliente screens (now main)
import 'screens/client_login_screen.dart';
import 'screens/client_register_screen.dart';
import 'screens/client_home_screen.dart';

// Admin screens (secondary)
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/productos_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/mascotas_screen.dart';
import 'screens/add_producto_screen.dart';
import 'screens/edit_producto_screen.dart';
import 'screens/add_mascota_screen.dart';
import 'screens/edit_mascota_screen.dart';
import 'screens/clientes_screen.dart';
import 'screens/add_edit_cliente_screen.dart';
import 'screens/citas_screen.dart';
import 'screens/add_edit_cita_screen.dart';
import 'screens/pedidos_screen.dart';
import 'screens/sucursales_screen.dart';
import 'screens/add_edit_sucursal_screen.dart';
import 'screens/proveedores_screen.dart';
import 'screens/add_edit_proveedor_screen.dart';
import 'screens/carritos_screen.dart';
import 'screens/add_edit_carrito_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ProductsProvider>(
          create: (_) => ProductsProvider(),
        ),
        ChangeNotifierProvider<PetsProvider>(create: (_) => PetsProvider()),
        ChangeNotifierProvider<ClientsProvider>(
          create: (_) => ClientsProvider(),
        ),
        ChangeNotifierProvider<AppointmentsProvider>(
          create: (_) => AppointmentsProvider(),
        ),
        ChangeNotifierProvider<OrdersProvider>(create: (_) => OrdersProvider()),
        ChangeNotifierProvider<BranchesProvider>(
          create: (_) => BranchesProvider(),
        ),
        ChangeNotifierProvider<ProvidersProvider>(
          create: (_) => ProvidersProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              CartProvider(Provider.of<AuthProvider>(context, listen: false)),
        ),
        ChangeNotifierProvider<CarritosProvider>(
          create: (_) => CarritosProvider(),
        ),
      ],
      child: const PetcoAppRouter(),
    );
  }
}

class PetcoAppRouter extends StatefulWidget {
  const PetcoAppRouter({Key? key}) : super(key: key);

  @override
  State<PetcoAppRouter> createState() => _PetcoAppRouterState();
}

class _PetcoAppRouterState extends State<PetcoAppRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        // Root route serves as Splash
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const SplashWidget(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        // Cliente routes (principal)
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const ClientLoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const ClientRegisterScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/client/home',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const ClientHomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        // Admin routes (secundario)
        GoRoute(
          path: '/admin/login',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/admin/register',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const RegisterScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/productos',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const ProductosScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
          routes: [
            GoRoute(
              path: 'add',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const AddProductoScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              ),
            ),
            GoRoute(
              path: 'edit/:id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                final product = state.extra as Producto?;
                return CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: EditProductoScreen(id: id, producto: product),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/mascotas',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const MascotasScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
          routes: [
            GoRoute(
              path: 'add',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const AddMascotaScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              ),
            ),
            GoRoute(
              path: 'edit/:id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                final mascota = state.extra as Mascota?;
                return CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: EditMascotaScreen(id: id, mascota: mascota),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/product-detail',
          pageBuilder: (context, state) {
            final product = state.extra as Producto;
            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: ProductDetailScreen(product: product),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            );
          },
        ),
        // Admin CRUD screens
        GoRoute(
          path: '/clientes',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const ClientesScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
          routes: [
            GoRoute(
              path: 'add',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const AddEditClienteScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              ),
            ),
            GoRoute(
              path: 'edit/:id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                final client = state.extra as Cliente?;
                return CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: AddEditClienteScreen(id: id, cliente: client),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/citas',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const CitasScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
          routes: [
            GoRoute(
              path: 'add',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const AddEditCitaScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              ),
            ),
            GoRoute(
              path: 'edit/:id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                final cita = state.extra as Cita?;
                return CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: AddEditCitaScreen(id: id, cita: cita),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/pedidos',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const PedidosScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/sucursales',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const SucursalesScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
          routes: [
            GoRoute(
              path: 'add',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const AddEditSucursalScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              ),
            ),
            GoRoute(
              path: 'edit/:id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                final sucursal = state.extra as Sucursal?;
                return CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: AddEditSucursalScreen(id: id, sucursal: sucursal),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/proveedores',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const ProveedoresScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
          routes: [
            GoRoute(
              path: 'add',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const AddEditProveedorScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              ),
            ),
            GoRoute(
              path: 'edit/:id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                final proveedor = state.extra as Proveedor?;
                return CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: AddEditProveedorScreen(id: id, proveedor: proveedor),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/carritos',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const CarritosScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
          routes: [
            GoRoute(
              path: 'add',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const AddEditCarritoScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              ),
            ),
            GoRoute(
              path: 'edit/:userId',
              pageBuilder: (context, state) {
                final userId = state.pathParameters['userId']!;
                final carrito = state.extra as Carrito?;
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: AddEditCarritoScreen(userId: userId, carrito: carrito),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                );
              },
            ),
          ],
        ),
      ],
      // Redirect unauthenticated users
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final loc = state.matchedLocation;
        final loggingIn =
            loc == '/login' ||
            loc == '/register' ||
            loc == '/admin/login' ||
            loc == '/admin/register';

        if (authProvider.loading) return null;

        if (!authProvider.isAuthenticated) {
          return loggingIn ? null : '/login';
        }

        if (loggingIn) {
          return '/';
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PetcoShop',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.primaryRed,
          background: AppColors.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
    );
  }
}

class SplashWidget extends StatefulWidget {
  const SplashWidget({Key? key}) : super(key: key);

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  @override
  void initState() {
    super.initState();
    _checkRedirect();
  }

  void _checkRedirect() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.loading) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) _checkRedirect();
      return;
    }

    if (!auth.isAuthenticated) {
      if (mounted) context.go('/login');
      return;
    }

    // Authenticated, check role
    try {
      final firestoreService = FirestoreService();
      final isClient =
          await firestoreService.getClienteById(auth.user!.uid) != null;
      if (mounted) {
        if (isClient) {
          context.go('/client/home');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pets_rounded,
                size: 64.0,
                color: AppColors.darkRed,
              ),
            ),
            const SizedBox(height: 24.0),
            const CircularProgressIndicator(color: AppColors.darkBlue),
          ],
        ),
      ),
    );
  }
}
