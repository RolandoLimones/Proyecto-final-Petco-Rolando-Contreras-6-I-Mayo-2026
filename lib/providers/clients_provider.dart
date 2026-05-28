import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cliente_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class ClientsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  List<Cliente> _clientes = [];
  bool _loading = false;

  List<Cliente> get clientes => _clientes;
  bool get loading => _loading;

  Future<void> fetchClientes() async {
    _loading = true;
    notifyListeners();
    try {
      _clientes = await _firestoreService.getClientes();
    } catch (e) {
      _clientes = [];
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addCliente(Cliente cliente, String password) async {
    _loading = true;
    notifyListeners();
    try {
      UserCredential userCredential;
      try {
        userCredential = await _authService.signUp(cliente.email, password);
      } catch (e) {
        if (e.toString().contains('email-already-in-use')) {
          userCredential = await _authService.signIn(cliente.email, password);
        } else {
          rethrow;
        }
      }

      final uid = userCredential.user!.uid;
      await _authService.updateDisplayName(cliente.nombre);
      final clienteConId = cliente.copyWith(id: uid);
      await _firestoreService.setDocument(
        'clientes',
        uid,
        clienteConId.toMap(),
      );

      _clientes.add(clienteConId);
      _clientes.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Registro de cliente desde app cliente (sin crear Auth de nuevo)
  Future<void> addClienteFromRegister(Cliente cliente) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.setDocument(
        'clientes',
        cliente.id,
        cliente.toMap(),
      );
      _clientes.add(cliente);
      _clientes.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateCliente(Cliente cliente, {String? password}) async {
    _loading = true;
    notifyListeners();
    try {
      final docRef = FirebaseFirestore.instance
          .collection('clientes')
          .doc(cliente.id);
      final docSnap = await docRef.get();

      Map<String, dynamic> updates = {};

      if (docSnap.exists) {
        final oldData = docSnap.data()!;
        updates['nombre'] = cliente.nombre;
        updates['email'] = cliente.email;
        updates['telefono'] = cliente.telefono;
        updates['direccion'] = cliente.direccion;
        _handleCardField(
          updates,
          'tarjetaNumero',
          cliente.tarjetaNumero,
          oldData,
        );
        _handleCardField(
          updates,
          'tarjetaNombre',
          cliente.tarjetaNombre,
          oldData,
        );
        _handleCardField(
          updates,
          'tarjetaExpiry',
          cliente.tarjetaExpiry,
          oldData,
        );
        _handleCardField(updates, 'tarjetaCvc', cliente.tarjetaCvc, oldData);
      } else {
        updates = cliente.toMap();
        updates.updateAll((key, value) {
          if (value == null || (value is String && value.isEmpty)) {
            return FieldValue.delete();
          }
          return value;
        });
        await docRef.set(updates, SetOptions(merge: true));
      }

      if (updates.isNotEmpty) {
        await docRef.update(updates);
      }

      if (password != null && password.isNotEmpty) {
        try {
          final user = _authService.currentUser;
          if (user != null && user.email == cliente.email) {
            await user.updatePassword(password);
          }
        } catch (e) {
          print('Error al actualizar contraseña: $e');
        }
      }

      final index = _clientes.indexWhere((c) => c.id == cliente.id);
      if (index != -1) {
        _clientes[index] = cliente;
        _clientes.sort(
          (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ✅ ELIMINAR CLIENTE (solo Firestore)
  Future<void> deleteCliente(String id) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteDocument('clientes', id);
      _clientes.removeWhere((c) => c.id == id);

      // Nota: La cuenta de Firebase Auth no se elimina por seguridad.
      // El cliente ya no puede iniciar sesión porque no tiene rol asignado.
      // Si quieres eliminar también la cuenta Auth, necesitas una Cloud Function.
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _handleCardField(
    Map<String, dynamic> updates,
    String fieldName,
    String? newValue,
    Map<String, dynamic> oldData,
  ) {
    final oldValue = oldData[fieldName];
    final shouldDelete = newValue == null || newValue.trim().isEmpty;

    if (shouldDelete) {
      if (oldValue != null) {
        updates[fieldName] = FieldValue.delete();
      }
    } else {
      if (oldValue != newValue) {
        updates[fieldName] = newValue;
      }
    }
  }
}
