import 'package:flutter/foundation.dart';
import '../models/warehouse_models.dart';
import '../services/warehouse_api_service.dart';

class WarehouseProvider with ChangeNotifier {
  // State variables
  WarehouseStats? _stats;
  List<Product> _products = [];
  List<Product> _lowStockProducts = [];
  List<Order> _orders = [];
  
  bool _isLoading = false;
  String? _error;
  bool _isConnected = false;
  
  // Getters
  WarehouseStats? get stats => _stats;
  List<Product> get products => _products;
  List<Product> get lowStockProducts => _lowStockProducts;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;

  // Computed getters
  double get totalInventoryValue => _stats?.totalInventoryValue ?? 0.0;
  int get totalProducts => _stats?.totalProducts ?? 0;
  int get lowStockCount => _stats?.lowStockProducts ?? 0;
  double get averageStockLevel => _stats?.averageStockLevel ?? 0.0;

  List<Product> get inactiveProducts => 
      _products.where((p) => !p.status).toList();

  List<Product> get featuredProducts => 
      _products.where((p) => p.isFeatured).toList();

  List<Order> get pendingOrders => 
      _orders.where((o) => o.isPending).toList();

  List<Order> get completedOrders => 
      _orders.where((o) => o.isCompleted).toList();

  Map<String, int> get productsByCategory {
    return _stats?.categories ?? {};
  }

  Map<String, int> get ordersByStatus {
    return _stats?.orderStatus ?? {};
  }

  // Actions
  Future<void> initialize() async {
    await checkConnection();
    if (_isConnected) {
      await loadWarehouseData();
    }
  }

  Future<void> checkConnection() async {
    try {
      _isConnected = await WarehouseApiService.healthCheck();
      if (_isConnected) {
        _clearError();
      } else {
        _setError('Unable to connect to warehouse service');
      }
    } catch (e) {
      _isConnected = false;
      _setError('Connection failed: ${e.toString()}');
    }
    notifyListeners();
  }

  Future<void> loadWarehouseData() async {
    if (!_isConnected) {
      await checkConnection();
      if (!_isConnected) return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Load all data in parallel
      final futures = await Future.wait([
        WarehouseApiService.getWarehouseStats(),
        WarehouseApiService.getProducts(),
        WarehouseApiService.getLowStockProducts(),
        WarehouseApiService.getOrders(),
      ]);

      _stats = futures[0] as WarehouseStats;
      _products = futures[1] as List<Product>;
      _lowStockProducts = futures[2] as List<Product>;
      _orders = futures[3] as List<Order>;

    } catch (e) {
      _setError('Failed to load warehouse data: ${e.toString()}');
      _isConnected = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshData() async {
    await loadWarehouseData();
  }

  Future<void> loadProducts({String? category, bool lowStockOnly = false}) async {
    if (!_isConnected) return;

    _setLoading(true);
    _clearError();

    try {
      _products = await WarehouseApiService.getProducts(
        category: category,
        lowStockOnly: lowStockOnly,
      );
    } catch (e) {
      _setError('Failed to load products: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOrders({String? status}) async {
    if (!_isConnected) return;

    _setLoading(true);
    _clearError();

    try {
      _orders = await WarehouseApiService.getOrders(status: status);
    } catch (e) {
      _setError('Failed to load orders: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<Product?> getProductDetails(String productId) async {
    if (!_isConnected) return null;

    try {
      return await WarehouseApiService.getProductDetails(productId);
    } catch (e) {
      _setError('Failed to get product details: ${e.toString()}');
      return null;
    }
  }

  // Filter methods
  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.categoryIds?.contains(category) ?? false).toList();
  }

  List<Order> getOrdersByStatus(String status) {
    return _orders.where((o) => o.orderStatus == status).toList();
  }

  List<Product> searchProducts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _products.where((p) => 
      p.name.toLowerCase().contains(lowercaseQuery) ||
      p.id.toString().contains(lowercaseQuery) ||
      (p.description.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _stats = null;
    _products.clear();
    _lowStockProducts.clear();
    _orders.clear();
    _error = null;
    _isLoading = false;
    _isConnected = false;
    notifyListeners();
  }
}
