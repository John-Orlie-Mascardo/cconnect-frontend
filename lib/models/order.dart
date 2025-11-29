import 'address.dart';

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? image;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final String customerName;
  final String phoneNumber;
  final Address deliveryAddress;
  final String deliveryMethod;
  final String paymentMethod;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      customerName: json['customerName']?.toString() ??
          (json['user'] is Map ? json['user']['name']?.toString() : null) ??
          'Unknown',
      phoneNumber: json['phoneNumber']?.toString() ??
          (json['user'] is Map ? json['user']['phone']?.toString() : null) ??
          'N/A',
      deliveryAddress: Address.fromJson(json['deliveryAddress'] ?? {}),
      deliveryMethod: json['deliveryMethod'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? json['orderStatus'] ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'deliveryAddress': deliveryAddress.toJson(),
      'deliveryMethod': deliveryMethod,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
