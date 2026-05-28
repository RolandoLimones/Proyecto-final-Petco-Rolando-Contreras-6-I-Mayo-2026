import 'package:flutter/material.dart';
import '../models/cita_model.dart';
import '../services/firestore_service.dart';

class AppointmentsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Cita> _citas = [];
  bool _loading = false;

  List<Cita> get citas => _citas;
  bool get loading => _loading;

  Future<void> fetchCitas() async {
    _loading = true;
    notifyListeners();
    try {
      _citas = await _firestoreService.getCitas();
    } catch (e) {
      _citas = [];
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCitasByUser(String uid) async {
    _loading = true;
    notifyListeners();
    try {
      _citas = await _firestoreService.getCitasByUser(uid);
    } catch (e) {
      _citas = [];
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addCita(Cita cita) async {
    _loading = true;
    notifyListeners();
    try {
      final docRef = await _firestoreService.addDocument('citas', cita.toMap());
      _citas.add(cita.copyWith(id: docRef.id));
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateCita(Cita cita) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.updateDocument('citas', cita.id, cita.toMap());
      final index = _citas.indexWhere((c) => c.id == cita.id);
      if (index != -1) {
        _citas[index] = cita;
      }
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCita(String id) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteDocument('citas', id);
      _citas.removeWhere((c) => c.id == id);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
