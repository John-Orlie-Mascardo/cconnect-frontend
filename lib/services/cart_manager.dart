import 'cart_service.dart';

class CartManager {
  // Singleton instance
  static final CartManager _instance = CartManager._internal();
  static CartManager get instance => _instance;

  CartManager._internal();

  // Cart items list
  final List<Map<String, dynamic>> _items = [];
  bool _isLoaded = false;

  List<Map<String, dynamic>> get items => _items;
  bool get isLoaded => _isLoaded;

  /// Load cart from backend
  Future<void> loadCart() async {
    final backendItems = await CartService.getCart();
    _items.clear();
    _items.addAll(backendItems);
    _isLoaded = true;
  }

  /// Add item to cart (syncs with backend)
  Future<bool> addItem(Map<String, dynamic> item) async {
    if (_items.length >= 10) {
      return false;
    }

    // Add to backend first
    final success = await CartService.addItem(item);
    if (success) {
      _items.add(item);
      return true;
    }
    return false;
  }

  /// Remove item from cart (syncs with backend)
  Future<void> removeItem(int index) async {
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      final productId = item['productId'] ?? item['_id'];

      if (productId != null) {
        await CartService.removeItem(productId.toString());
      }
      _items.removeAt(index);
    }
  }

  /// Remove item from cart by product ID (syncs with backend)
  Future<void> removeItemByProductId(String productId) async {
    final index = _items.indexWhere((item) => 
      (item['productId'] ?? item['_id']).toString() == productId
    );
    
    if (index != -1) {
      await removeItem(index);
    }
  }

  /// Clear cart (syncs with backend)
  Future<void> clear() async {
    await CartService.clearCart();
    _items.clear();
  }

  /// Update quantity (syncs with backend)
  Future<bool> updateQuantity(int index, int quantity) async {
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      final productId = item['productId'] ?? item['_id'];

      if (productId != null) {
        final success = await CartService.updateQuantity(
          productId.toString(),
          quantity,
        );
        if (success) {
          _items[index]['quantity'] = quantity;
          return true;
        }
      }
    }
    return false;
  }
}
