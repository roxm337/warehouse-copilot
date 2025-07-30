class Product {
  final String id;
  final String name;
  final String category;
  final int stockLevel;
  final int reorderPoint;
  final double unitPrice;
  final String location;
  final String supplier;
  final double? totalValue;
  final bool? needsReorder;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.stockLevel,
    required this.reorderPoint,
    required this.unitPrice,
    required this.location,
    required this.supplier,
    this.totalValue,
    this.needsReorder,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      stockLevel: json['stock_level'] ?? 0,
      reorderPoint: json['reorder_point'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0.0).toDouble(),
      location: json['location'] ?? '',
      supplier: json['supplier'] ?? '',
      totalValue: json['total_value']?.toDouble(),
      needsReorder: json['needs_reorder'],
    );
  }

  bool get isLowStock => stockLevel <= reorderPoint;
  bool get isOutOfStock => stockLevel == 0;
  
  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }
}

class Shipment {
  final String id;
  final String productId;
  final int quantity;
  final String status;
  final String origin;
  final String destination;
  final DateTime expectedDate;
  final DateTime? actualDate;

  Shipment({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.status,
    required this.origin,
    required this.destination,
    required this.expectedDate,
    this.actualDate,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      quantity: json['quantity'] ?? 0,
      status: json['status'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      expectedDate: DateTime.parse(json['expected_date']),
      actualDate: json['actual_date'] != null 
          ? DateTime.parse(json['actual_date'])
          : null,
    );
  }

  bool get isDelayed => status == 'delayed';
  bool get isDelivered => status == 'delivered';
  bool get isInTransit => status == 'in_transit';
  bool get isPending => status == 'pending';
}

class WarehouseStats {
  final int totalProducts;
  final int lowStockProducts;
  final double totalInventoryValue;
  final Map<String, int> categories;
  final Map<String, int> shipmentStatus;
  final double averageStockLevel;

  WarehouseStats({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.totalInventoryValue,
    required this.categories,
    required this.shipmentStatus,
    required this.averageStockLevel,
  });

  factory WarehouseStats.fromJson(Map<String, dynamic> json) {
    return WarehouseStats(
      totalProducts: json['total_products'] ?? 0,
      lowStockProducts: json['low_stock_products'] ?? 0,
      totalInventoryValue: (json['total_inventory_value'] ?? 0.0).toDouble(),
      categories: Map<String, int>.from(json['categories'] ?? {}),
      shipmentStatus: Map<String, int>.from(json['shipment_status'] ?? {}),
      averageStockLevel: (json['average_stock_level'] ?? 0.0).toDouble(),
    );
  }
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? queryAnalysis;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.queryAnalysis,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.ai(String content, {Map<String, dynamic>? analysis}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      queryAnalysis: analysis,
    );
  }
}

class ApiResponse {
  final String reply;
  final Map<String, dynamic>? queryAnalysis;
  final DateTime timestamp;

  ApiResponse({
    required this.reply,
    this.queryAnalysis,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      reply: json['reply'] ?? '',
      queryAnalysis: json['query_analysis'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
