// Файл lib/models/order.dart

class Order {
  final String id;
  final String userId;
  final String userName;
  final String status; // pending, processing, shipped, delivered, cancelled
  final double totalAmount;
  final DateTime orderDate;
  final List<OrderItem> items;
  final String address;
  final String phone;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    required this.items,
    required this.address,
    required this.phone,
  });
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String selectedSize;
  final String selectedColor;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.selectedSize,
    required this.selectedColor,
  });
}