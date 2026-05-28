// lib/providers/carritos_provider.dart
import 'package:flutter/material.dart';
import '../models/carrito_model.dart';
import '../services/firestore_service.dart';

class CarritosProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Carrito> _carritos = [];
  bool _loading = false;

  List<Carrito> get carritos => _carritos;
  bool get loading => _loading;

  Future<void> fetchCarritos() async {
    _loading = true;
    notifyListeners();
    try {
      final snapshot = await _firestoreService.getCollection('carrito');
      _carritos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Carrito.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      _carritos = [];
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addCarrito(Carrito carrito) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.addCarrito(carrito);
      await fetchCarritos(); // recargar lista
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateCarrito(String userId, Carrito carrito) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.updateCarrito(userId, carrito);
      await fetchCarritos(); // recargar lista
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCarrito(String userId) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteDocument('carrito', userId);
      await fetchCarritos();
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
