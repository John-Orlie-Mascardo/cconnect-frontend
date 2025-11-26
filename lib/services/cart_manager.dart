class CartManager {
  // Singleton instance
  static final CartManager _instance = CartManager._internal();
  static CartManager get instance => _instance;

  CartManager._internal();

  // Cart items list
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addItem(Map<String, dynamic> item) {
    _items.add(item);
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
