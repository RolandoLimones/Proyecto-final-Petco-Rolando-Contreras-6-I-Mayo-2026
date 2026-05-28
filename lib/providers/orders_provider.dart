import 'package:flutter/material.dart';
import '../models/pedido_model.dart';
import '../models/detalle_pedido_model.dart';
import '../services/firestore_service.dart';

class OrdersProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Pedido> _pedidos = [];
  Map<String, List<DetallePedido>> _detallesPorPedido = {};
  bool _loading = false;

  List<Pedido> get pedidos => _pedidos;
  bool get loading => _loading;

  Future<void> fetchPedidos() async {
    _loading = true;
    notifyListeners();
    try {
      _pedidos = await _firestoreService.getPedidos();
    } catch (e) {
      _pedidos = [];
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPedidosByUser(String uid) async {
    _loading = true;
    notifyListeners();
    try {
      _pedidos = await _firestoreService.getPedidosByUser(uid);
    } catch (e) {
      _pedidos = [];
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<DetallePedido>> fetchDetalles(String pedidoId) async {
    if (_detallesPorPedido.containsKey(pedidoId)) {
      return _detallesPorPedido[pedidoId]!;
    }
    try {
      final list = await _firestoreService.getDetallesByPedido(pedidoId);
      _detallesPorPedido[pedidoId] = list;
      notifyListeners();
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPedido(Pedido pedido, List<DetallePedido> detalles) async {
    _loading = true;
    notifyListeners();
    try {
      // 1. Save the main order
      final docRef = await _firestoreService.addDocument(
        'pedidos',
        pedido.toMap(),
      );
      final newPedido = pedido.copyWith(id: docRef.id);

      // 2. Save each line item
      for (var item in detalles) {
        final itemWithPedidoId = item.copyWith(pedidoId: docRef.id);
        await _firestoreService.addDocument(
          'detalle_pedido',
          itemWithPedidoId.toMap(),
        );
      }

      _pedidos.insert(0, newPedido);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updatePedidoStatus(String id, String status) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.updateDocument('pedidos', id, {'estado': status});
      final index = _pedidos.indexWhere((p) => p.id == id);
      if (index != -1) {
        _pedidos[index] = _pedidos[index].copyWith(estado: status);
      }
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deletePedido(String id) async {
    _loading = true;
    notifyListeners();
    try {
      // First delete associated details
      final details = await _firestoreService.getDetallesByPedido(id);
      for (var d in details) {
        await _firestoreService.deleteDocument('detalle_pedido', d.id);
      }
      // Delete the order itself
      await _firestoreService.deleteDocument('pedidos', id);
      _pedidos.removeWhere((p) => p.id == id);
      _detallesPorPedido.remove(id);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
