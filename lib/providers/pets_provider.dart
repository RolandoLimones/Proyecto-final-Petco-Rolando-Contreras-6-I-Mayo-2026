import 'package:flutter/material.dart';
import '../models/mascota_model.dart';
import '../services/firestore_service.dart';

class PetsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Mascota> _mascotas = [];
  bool _loading = false;

  List<Mascota> get mascotas => _mascotas;
  bool get loading => _loading;

  // Para clientes: solo sus mascotas
  Future<void> fetchMascotas(String uid) async {
    _loading = true;
    notifyListeners();
    try {
      _mascotas = await _firestoreService.getMascotasByUser(uid);
    } catch (e) {
      _mascotas = [];
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Para administradores: todas las mascotas
  Future<void> fetchAllMascotas() async {
    _loading = true;
    notifyListeners();
    try {
      _mascotas = await _firestoreService.getAllMascotas();
    } catch (e) {
      _mascotas = [];
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // El resto de métodos (addMascota, updateMascota, deleteMascota) se mantienen igual
  Future<void> addMascota(Mascota mascota) async {
    _loading = true;
    notifyListeners();
    try {
      final docRef = await _firestoreService.addDocument(
        'mascotas',
        mascota.toMap(),
      );
      final newMascota = mascota.copyWith(id: docRef.id);
      _mascotas.add(newMascota);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateMascota(Mascota mascota) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.updateDocument(
        'mascotas',
        mascota.id,
        mascota.toMap(),
      );
      final index = _mascotas.indexWhere((m) => m.id == mascota.id);
      if (index != -1) {
        _mascotas[index] = mascota;
      }
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMascota(String id) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteDocument('mascotas', id);
      _mascotas.removeWhere((m) => m.id == id);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
