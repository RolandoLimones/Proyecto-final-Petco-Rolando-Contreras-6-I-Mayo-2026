import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../services/firestore_service.dart';

class ProductsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Producto> _productos = [];
  bool _loading = false;

  List<Producto> get productos => _productos;
  bool get loading => _loading;

  Future<void> fetchProductos() async {
    _loading = true;
    notifyListeners();
    try {
      _productos = await _firestoreService.getProductos();
    } catch (e) {
      _productos = [];
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addProducto(Producto producto) async {
    _loading = true;
    notifyListeners();
    try {
      // Add to Firestore
      final docRef = await _firestoreService.addDocument('productos', producto.toMap());
      final newProducto = producto.copyWith(id: docRef.id);
      
      // Update local list (only if active)
      if (newProducto.activo) {
        _productos.add(newProducto);
        // Sort alphabetically
        _productos.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
      }
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProducto(Producto producto) async {
    _loading = true;
    notifyListeners();
    try {
      // Update in Firestore
      await _firestoreService.updateDocument('productos', producto.id, producto.toMap());
      
      // Update locally
      final index = _productos.indexWhere((p) => p.id == producto.id);
      if (index != -1) {
        if (producto.activo) {
          _productos[index] = producto;
          _productos.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
        } else {
          // If deactivated, remove from active list
          _productos.removeAt(index);
        }
      } else if (producto.activo) {
        _productos.add(producto);
        _productos.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
      }
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProducto(String id) async {
    _loading = true;
    notifyListeners();
    try {
      // Delete in Firestore
      await _firestoreService.deleteDocument('productos', id);
      // Remove locally
      _productos.removeWhere((p) => p.id == id);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
