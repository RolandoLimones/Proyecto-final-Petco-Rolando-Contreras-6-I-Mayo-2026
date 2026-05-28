// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../models/cart_item_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

class CartProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthProvider _authProvider;

  // Mapa de id del producto -> CartItem
  Map<String, CartItem> _items = {};
  bool _loading = true;
  String? _currentUserId;

  CartProvider(this._authProvider) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authProvider.addListener(() {
      final user = _authProvider.user;
      if (user != null && user.uid != _currentUserId) {
        _currentUserId = user.uid;
        _loadCartFromFirestore();
      } else if (user == null && _currentUserId != null) {
        // Usuario cerró sesión: limpiar carrito local
        _items.clear();
        _currentUserId = null;
        _loading = false;
        notifyListeners();
      }
    });
    // Si ya hay usuario al crear el provider, cargar
    if (_authProvider.user != null) {
      _currentUserId = _authProvider.user!.uid;
      _loadCartFromFirestore();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadCartFromFirestore() async {
    if (_currentUserId == null) return;
    _loading = true;
    notifyListeners();
    try {
      final cartItems = await _firestoreService.getCart(_currentUserId!);
      _items = {for (var item in cartItems) item.id: item};
    } catch (e) {
      // Si falla, mantenemos carrito vacío
      _items = {};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _syncToFirestore() async {
    if (_currentUserId == null) return;
    try {
      await _firestoreService.setCart(_currentUserId!, _items.values.toList());
    } catch (e) {
      // Podríamos mostrar error pero no interrumpimos la experiencia
      debugPrint('Error syncing cart: $e');
    }
  }

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.length;
  bool get loading => _loading;

  double get totalAmount {
    double total = 0;
    for (var item in _items.values) {
      total += item.precio * item.cantidad;
    }
    return total;
  }

  void addProducto(Producto producto) {
    if (_items.containsKey(producto.id)) {
      // Incrementar cantidad
      final existing = _items[producto.id]!;
      existing.cantidad++;
      _items[producto.id] = existing;
    } else {
      _items[producto.id] = CartItem(
        id: producto.id,
        nombre: producto.nombre,
        precio: producto.precio,
        cantidad: 1,
        imagenUrl: producto.imagenUrl,
      );
    }
    _syncToFirestore();
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (!_items.containsKey(productId)) return;
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }
    final item = _items[productId]!;
    item.cantidad = newQuantity;
    _items[productId] = item;
    _syncToFirestore();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _syncToFirestore();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    if (_currentUserId != null) {
      _firestoreService.clearCart(_currentUserId!);
    }
    notifyListeners();
  }
}
