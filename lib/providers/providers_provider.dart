import 'package:flutter/material.dart';
import '../models/proveedor_model.dart';
import '../services/firestore_service.dart';

class ProvidersProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Proveedor> _proveedores = [];
  bool _loading = false;

  List<Proveedor> get proveedores => _proveedores;
  bool get loading => _loading;

  Future<void> fetchProveedores() async {
    _loading = true;
    notifyListeners();
    try {
      _proveedores = await _firestoreService.getProveedores();
    } catch (e) {
      _proveedores = [];
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addProveedor(Proveedor proveedor) async {
    _loading = true;
    notifyListeners();
    try {
      final docRef = await _firestoreService.addDocument('proveedor', proveedor.toMap());
      _proveedores.add(proveedor.copyWith(id: docRef.id));
      _proveedores.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProveedor(Proveedor proveedor) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.updateDocument('proveedor', proveedor.id, proveedor.toMap());
      final index = _proveedores.indexWhere((p) => p.id == proveedor.id);
      if (index != -1) {
        _proveedores[index] = proveedor;
        _proveedores.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
      }
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProveedor(String id) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteDocument('proveedor', id);
      _proveedores.removeWhere((p) => p.id == id);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
