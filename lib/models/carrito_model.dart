// lib/models/carrito_model.dart
import 'cart_item_model.dart';

class Carrito {
  final String userId;
  final String userName;
  final List<CartItem> items;

  Carrito({required this.userId, required this.userName, required this.items});

  factory Carrito.fromMap(Map<String, dynamic> map, String id) {
    final itemsList = (map['items'] as List<dynamic>? ?? [])
        .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
        .toList();
    return Carrito(
      userId: id, // el documento ID es el userId
      userName: map['userName'] ?? '',
      items: itemsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}
