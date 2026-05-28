import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _loading = true;
  StreamSubscription<User?>? _authSubscription;

  User? get user => _user;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Check initial state
    _user = _authService.currentUser;
    _loading = false;
    
    // Listen to changes
    _authSubscription = _authService.authStateChanges.listen((User? user) {
      _user = user;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await _authService.signIn(email, password);
    } catch (e) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String nombre) async {
    _loading = true;
    notifyListeners();
    try {
      await _authService.signUp(email, password);
      await _authService.updateDisplayName(nombre);
    } catch (e) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    _loading = true;
    notifyListeners();
    try {
      await _authService.signOut();
    } catch (e) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
