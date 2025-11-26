class CartManager {
  // Singleton instance
  static final CartManager _instance = CartManager._internal();
  static CartManager get instance => _instance;

  CartManager._internal();

  // Cart items list
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  bool addItem(Map<String, dynamic> item) {
    if (_items.length >= 10) {
      return false;
    }
    _items.add(item);
    return true;
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }

  void clear() {
    _items.clear();
  }
}
