import 'package:flutter/material.dart';
import '../models/sucursal_model.dart';
import '../services/firestore_service.dart';

class BranchesProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Sucursal> _sucursales = [];
  bool _loading = false;

  List<Sucursal> get sucursales => _sucursales;
  bool get loading => _loading;

  Future<void> fetchSucursales() async {
    _loading = true;
    notifyListeners();
    try {
      _sucursales = await _firestoreService.getSucursales();
    } catch (e) {
      _sucursales = [];
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addSucursal(Sucursal sucursal) async {
    _loading = true;
    notifyListeners();
    try {
      final docRef = await _firestoreService.addDocument('sucursal', sucursal.toMap());
      _sucursales.add(sucursal.copyWith(id: docRef.id));
      _sucursales.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateSucursal(Sucursal sucursal) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.updateDocument('sucursal', sucursal.id, sucursal.toMap());
      final index = _sucursales.indexWhere((s) => s.id == sucursal.id);
      if (index != -1) {
        _sucursales[index] = sucursal;
        _sucursales.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
      }
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSucursal(String id) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteDocument('sucursal', id);
      _sucursales.removeWhere((s) => s.id == id);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
