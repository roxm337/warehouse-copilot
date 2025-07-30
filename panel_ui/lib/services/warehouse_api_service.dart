import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/warehouse_models.dart';

class WarehouseApiService {
  static const String baseUrl = 'http://localhost:8000';
  
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Health check
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Chat with AI agent
  static Future<ApiResponse> chatWithAgent(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: _headers,
      body: json.encode({'message': message}),
    ).timeout(const Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      return ApiResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Chat request failed: ${response.statusCode}');
    }
  }

  // Advanced warehouse query
  static Future<ApiResponse> warehouseQuery(String query, {bool includeContext = true}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/warehouse/query'),
      headers: _headers,
      body: json.encode({
        'query': query,
        'include_context': includeContext,
      }),
    ).timeout(const Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      return ApiResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Warehouse query failed: ${response.statusCode}');
    }
  }

  // Get warehouse statistics
  static Future<WarehouseStats> getWarehouseStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/warehouse/stats'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      return WarehouseStats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get warehouse stats: ${response.statusCode}');
    }
  }

  // Get low stock products
  static Future<List<Product>> getLowStockProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/warehouse/low-stock'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final products = data['products'] as List;
      return products.map((p) => Product.fromJson(p)).toList();
    } else {
      throw Exception('Failed to get low stock products: ${response.statusCode}');
    }
  }

  // Get all products with optional filters
  static Future<List<Product>> getProducts({
    String? category,
    bool lowStockOnly = false,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (lowStockOnly) queryParams['low_stock_only'] = 'true';
    
    final uri = Uri.parse('$baseUrl/warehouse/products').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    
    final response = await http.get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final products = data['products'] as List;
      return products.map((p) => Product.fromJson(p)).toList();
    } else {
      throw Exception('Failed to get products: ${response.statusCode}');
    }
  }

  // Get shipments with optional status filter
  static Future<List<Shipment>> getShipments({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    
    final uri = Uri.parse('$baseUrl/warehouse/shipments').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    
    final response = await http.get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final shipments = data['shipments'] as List;
      return shipments.map((s) => Shipment.fromJson(s)).toList();
    } else {
      throw Exception('Failed to get shipments: ${response.statusCode}');
    }
  }

  // Get specific product details
  static Future<Product> getProductDetails(String productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/warehouse/product/$productId'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Product not found');
    } else {
      throw Exception('Failed to get product details: ${response.statusCode}');
    }
  }
}
