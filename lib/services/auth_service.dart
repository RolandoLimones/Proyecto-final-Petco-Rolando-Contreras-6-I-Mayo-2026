import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user getter
  User? get currentUser => _auth.currentUser;

  // Sign In with Email & Password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign Up with Email & Password
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Update Display Name
  Future<void> updateDisplayName(String name) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Buscar usuario por email (para actualizar contraseña)
  Future<User?> getUserByEmail(String email) async {
    try {
      // Nota: Firebase Auth no permite buscar usuarios por email directamente desde el cliente
      // Esta es una alternativa usando signInWithEmailAndPassword
      // Pero la mejor práctica es usar Firebase Admin SDK (solo backend)
      // Por ahora, este método intenta obtener el usuario actual si coincide el email
      final user = _auth.currentUser;
      if (user != null && user.email == email) {
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
