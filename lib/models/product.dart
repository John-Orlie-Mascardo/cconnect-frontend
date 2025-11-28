class Product {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? productId;
  final String? size; // Deprecated: kept for backward compatibility
  final List<int>? sizes; // New: array of available sizes
  final String? materials;
  final String? condition;
  final int quantity;
  final int stock;
  final String? image;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.productId,
    this.size,
    this.sizes,
    this.materials,
    this.condition,
    this.quantity = 0,
    this.stock = 0,
    this.image,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse sizes array from API
    List<int>? sizesList;
    if (json['sizes'] != null) {
      if (json['sizes'] is List) {
        sizesList = (json['sizes'] as List).map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).toList();
      }
    }

    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
      productId: json['productId'],
      size: json['size'], // Keep for backward compatibility
      sizes: sizesList,
      materials: json['materials'],
      condition: json['condition'],
      quantity: json['quantity'] ?? 0,
      stock: json['stock'] ?? 0,
      image: json['image'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'productId': productId,
      'sizes': sizes, // Send sizes array to backend
      'materials': materials,
      'condition': condition,
      'quantity': quantity,
      'stock': stock,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? productId,
    String? size,
    List<int>? sizes,
    String? materials,
    String? condition,
    int? quantity,
    int? stock,
    String? image,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      productId: productId ?? this.productId,
      size: size ?? this.size,
      sizes: sizes ?? this.sizes,
      materials: materials ?? this.materials,
      condition: condition ?? this.condition,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
