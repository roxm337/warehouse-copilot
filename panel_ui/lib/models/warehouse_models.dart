class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double tax;
  final bool status;
  final bool isDeleted;
  final bool isFeatured;
  final String? categoryIds;
  final String? attributes;
  final double discount;
  final String discountType;
  final int lowStockLimit;
  final int minimumOrderQuantity;
  final int maximumOrderQuantory;
  final String? image;
  final String? nutritionFactImage;
  final String? nutritionFact;
  final String unit;
  final double weight;
  final int viewCount;
  final int popularityCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tax,
    required this.status,
    required this.isDeleted,
    required this.isFeatured,
    this.categoryIds,
    this.attributes,
    required this.discount,
    required this.discountType,
    required this.lowStockLimit,
    required this.minimumOrderQuantity,
    required this.maximumOrderQuantory,
    this.image,
    this.nutritionFactImage,
    this.nutritionFact,
    required this.unit,
    required this.weight,
    required this.viewCount,
    required this.popularityCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      status: json['status'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      categoryIds: json['category_ids'],
      attributes: json['attributes'],
      discount: (json['discount'] ?? 0.0).toDouble(),
      discountType: json['discount_type'] ?? 'percent',
      lowStockLimit: json['low_stock_limit'] ?? 0,
      minimumOrderQuantity: json['minimum_order_quantity'] ?? 1,
      maximumOrderQuantory: json['maximum_order_quantity'] ?? 1000,
      image: json['image'],
      nutritionFactImage: json['nutrition_fact_image'],
      nutritionFact: json['nutrition_fact'],
      unit: json['unit'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      viewCount: json['view_count'] ?? 0,
      popularityCount: json['popularity_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isLowStock => lowStockLimit > 0; // We don't have current stock from this endpoint
  bool get isOutOfStock => !status;
  
  String get stockStatus {
    if (!status) return 'Inactive';
    if (isDeleted) return 'Deleted';
    return 'Active';
  }

  double get finalPrice => price - (discountType == 'percent' ? price * discount / 100 : discount);
}

class Order {
  final int id;
  final int userId;
  final double orderAmount;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String orderType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String date;
  final String? deliveryDate;
  final double deliveryCharge;
  final double totalTaxAmount;
  final bool isGuest;
  final bool checked;
  final String? orderNote;
  final String? deliveryAddress;

  Order({
    required this.id,
    required this.userId,
    required this.orderAmount,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.orderType,
    required this.createdAt,
    required this.updatedAt,
    required this.date,
    this.deliveryDate,
    required this.deliveryCharge,
    required this.totalTaxAmount,
    required this.isGuest,
    required this.checked,
    this.orderNote,
    this.deliveryAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      orderAmount: (json['order_amount'] ?? 0.0).toDouble(),
      orderStatus: json['order_status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      orderType: json['order_type'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      date: json['date'] ?? '',
      deliveryDate: json['delivery_date'],
      deliveryCharge: (json['delivery_charge'] ?? 0.0).toDouble(),
      totalTaxAmount: (json['total_tax_amount'] ?? 0.0).toDouble(),
      isGuest: json['is_guest'] ?? false,
      checked: json['checked'] ?? false,
      orderNote: json['order_note'],
      deliveryAddress: json['delivery_address'],
    );
  }

  bool get isCompleted => orderStatus == 'delivered';
  bool get isPending => orderStatus == 'placed' || orderStatus == 'confirmed';
  bool get isProcessing => orderStatus == 'processing' || orderStatus == 'out_for_delivery';
  bool get isCancelled => orderStatus == 'cancelled';
  bool get isPaid => paymentStatus == 'paid';
}

class WarehouseStats {
  final int totalProducts;
  final int lowStockProducts;
  final double totalInventoryValue;
  final Map<String, int> categories;
  final Map<String, int> orderStatus;
  final double averageStockLevel;

  WarehouseStats({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.totalInventoryValue,
    required this.categories,
    required this.orderStatus,
    required this.averageStockLevel,
  });

  factory WarehouseStats.fromJson(Map<String, dynamic> json) {
    return WarehouseStats(
      totalProducts: json['total_products'] ?? 0,
      lowStockProducts: json['low_stock_products'] ?? 0,
      totalInventoryValue: (json['total_inventory_value'] ?? 0.0).toDouble(),
      categories: Map<String, int>.from(json['categories'] ?? {}),
      orderStatus: Map<String, int>.from(json['order_status'] ?? {}),
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
