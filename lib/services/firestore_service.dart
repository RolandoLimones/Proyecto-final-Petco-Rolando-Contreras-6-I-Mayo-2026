import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto_model.dart';
import '../models/mascota_model.dart';
import '../models/cliente_model.dart';
import '../models/cita_model.dart';
import '../models/pedido_model.dart';
import '../models/detalle_pedido_model.dart';
import '../models/sucursal_model.dart';
import '../models/proveedor_model.dart';
import '../models/cart_item_model.dart';
import '../models/carrito_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generic: Get collection snapshot (optional)
  Future<QuerySnapshot> getCollection(String collection) {
    return _db.collection(collection).get();
  }

  // Generic: Add document
  Future<DocumentReference> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _db.collection(collection).add(data);
    } catch (e) {
      rethrow;
    }
  }

  // Generic: Set document (with custom ID)
  Future<void> setDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection(collection).doc(id).set(data);
    } catch (e) {
      rethrow;
    }
  }

  // Generic: Update document
  Future<void> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection(collection).doc(id).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Generic: Delete document
  Future<void> deleteDocument(String collection, String id) async {
    try {
      await _db.collection(collection).doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Specific: Get all active products ordered by name
  Future<List<Producto>> getProductos() async {
    try {
      final querySnapshot = await _db.collection('productos').get();

      final list = querySnapshot.docs
          .map((doc) => Producto.fromMap(doc.data(), doc.id))
          .where((p) => p.activo)
          .toList();

      list.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );
      return list;
    } catch (e) {
      rethrow;
    }
  }

  // Specific: Get products created by user
  Future<List<Producto>> getProductosByUser(String uid) async {
    try {
      final querySnapshot = await _db
          .collection('productos')
          .where('creadorId', isEqualTo: uid)
          .get();

      return querySnapshot.docs
          .map((doc) => Producto.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Specific: Get pets belonging to client (uid)
  Future<List<Mascota>> getMascotasByUser(String uid) async {
    try {
      final querySnapshot = await _db
          .collection('mascotas')
          .where('clienteId', isEqualTo: uid)
          .get();

      return querySnapshot.docs
          .map((doc) => Mascota.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // NEW: Get all mascotas (for admin)
  Future<List<Mascota>> getAllMascotas() async {
    try {
      final querySnapshot = await _db.collection('mascotas').get();
      return querySnapshot.docs
          .map((doc) => Mascota.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Clientes
  Future<List<Cliente>> getClientes() async {
    try {
      final querySnapshot = await _db.collection('clientes').get();
      return querySnapshot.docs
          .map((doc) => Cliente.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Cliente?> getClienteById(String id) async {
    try {
      final doc = await _db.collection('clientes').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Cliente.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Citas
  Future<List<Cita>> getCitas() async {
    try {
      final querySnapshot = await _db.collection('citas').get();
      return querySnapshot.docs
          .map((doc) => Cita.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Cita>> getCitasByUser(String uid) async {
    try {
      final querySnapshot = await _db
          .collection('citas')
          .where('clienteId', isEqualTo: uid)
          .get();
      return querySnapshot.docs
          .map((doc) => Cita.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Pedidos
  Future<List<Pedido>> getPedidos() async {
    try {
      final querySnapshot = await _db
          .collection('pedidos')
          .orderBy('fecha', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => Pedido.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Pedido>> getPedidosByUser(String uid) async {
    try {
      final querySnapshot = await _db
          .collection('pedidos')
          .where('clienteId', isEqualTo: uid)
          .get();
      final list = querySnapshot.docs
          .map((doc) => Pedido.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.fecha.compareTo(a.fecha)); // descending sort
      return list;
    } catch (e) {
      rethrow;
    }
  }

  // Detalle Pedido
  Future<List<DetallePedido>> getDetallesByPedido(String pedidoId) async {
    try {
      final querySnapshot = await _db
          .collection('detalle_pedido')
          .where('pedidoId', isEqualTo: pedidoId)
          .get();
      return querySnapshot.docs
          .map((doc) => DetallePedido.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Sucursales
  Future<List<Sucursal>> getSucursales() async {
    try {
      final querySnapshot = await _db.collection('sucursal').get();
      return querySnapshot.docs
          .map((doc) => Sucursal.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Proveedores
  Future<List<Proveedor>> getProveedores() async {
    try {
      final querySnapshot = await _db.collection('proveedor').get();
      return querySnapshot.docs
          .map((doc) => Proveedor.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener un proveedor por su ID
  Future<Proveedor?> getProveedorById(String proveedorId) async {
    try {
      final doc = await _db.collection('proveedor').doc(proveedorId).get();
      if (doc.exists && doc.data() != null) {
        return Proveedor.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Obtener una sucursal por su ID
  Future<Sucursal?> getSucursalById(String sucursalId) async {
    try {
      final doc = await _db.collection('sucursal').doc(sucursalId).get();
      if (doc.exists && doc.data() != null) {
        return Sucursal.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CartItem>> getCart(String userId) async {
    try {
      final doc = await _db
          .collection('carrito')
          .doc(userId)
          .get(); // ← cambiado
      if (doc.exists && doc.data() != null) {
        final List<dynamic> items = doc.data()!['items'] ?? [];
        return items
            .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Guardar carrito completo (reemplaza el array)
  Future<void> setCart(String userId, List<CartItem> items) async {
    try {
      final itemsMap = items.map((item) => item.toMap()).toList();
      await _db.collection('carrito').doc(userId).set({
        'items': itemsMap,
      }); // ← cambiado
    } catch (e) {
      rethrow;
    }
  }

  // Vaciar carrito
  Future<void> clearCart(String userId) async {
    try {
      await _db.collection('carrito').doc(userId).delete(); // ← cambiado
    } catch (e) {
      rethrow;
    }
  }
  // lib/services/firestore_service.dart (añadir dentro de la clase)

  // Obtener todos los carritos (para admin)
  Future<List<Carrito>> getAllCarritos() async {
    try {
      final querySnapshot = await _db.collection('carrito').get();
      return querySnapshot.docs.map((doc) {
        return Carrito.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener un carrito por userId (ya existe getCart, pero para consistencia)
  Future<Carrito?> getCarritoById(String userId) async {
    try {
      final doc = await _db.collection('carrito').doc(userId).get();
      if (doc.exists) {
        return Carrito.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Crear o actualizar carrito (usar userId como ID del documento)
  Future<void> setCarrito(String userId, Carrito carrito) async {
    try {
      await _db.collection('carrito').doc(userId).set(carrito.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar carrito por userId
  Future<void> deleteCarrito(String userId) async {
    try {
      await _db.collection('carrito').doc(userId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String id,
  ) async {
    final doc = await _db.collection(collection).doc(id).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> addCarrito(Carrito carrito) async {
    try {
      await _db.collection('carrito').doc(carrito.userId).set(carrito.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar un carrito existente
  Future<void> updateCarrito(String userId, Carrito carrito) async {
    try {
      await _db.collection('carrito').doc(userId).update(carrito.toMap());
    } catch (e) {
      rethrow;
    }
  }
}
