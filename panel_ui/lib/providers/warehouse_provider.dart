import 'package:flutter/foundation.dart';
import '../models/warehouse_models.dart';
import '../services/warehouse_api_service.dart';

class WarehouseProvider with ChangeNotifier {
  // State variables
  WarehouseStats? _stats;
  List<Product> _products = [];
  List<Product> _lowStockProducts = [];
  List<Shipment> _shipments = [];
  
  bool _isLoading = false;
  String? _error;
  bool _isConnected = false;
  
  // Getters
  WarehouseStats? get stats => _stats;
  List<Product> get products => _products;
  List<Product> get lowStockProducts => _lowStockProducts;
  List<Shipment> get shipments => _shipments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;

  // Computed getters
  double get totalInventoryValue => _stats?.totalInventoryValue ?? 0.0;
  int get totalProducts => _stats?.totalProducts ?? 0;
  int get lowStockCount => _stats?.lowStockProducts ?? 0;
  double get averageStockLevel => _stats?.averageStockLevel ?? 0.0;

  List<Product> get criticalStockProducts => 
      _products.where((p) => p.stockLevel == 0).toList();

  List<Shipment> get delayedShipments => 
      _shipments.where((s) => s.isDelayed).toList();

  List<Shipment> get pendingShipments => 
      _shipments.where((s) => s.isPending).toList();

  Map<String, int> get productsByCategory {
    final Map<String, int> result = {};
    for (final product in _products) {
      result[product.category] = (result[product.category] ?? 0) + 1;
    }
    return result;
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
        WarehouseApiService.getShipments(),
      ]);

      _stats = futures[0] as WarehouseStats;
      _products = futures[1] as List<Product>;
      _lowStockProducts = futures[2] as List<Product>;
      _shipments = futures[3] as List<Shipment>;

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

  Future<void> loadShipments({String? status}) async {
    if (!_isConnected) return;

    _setLoading(true);
    _clearError();

    try {
      _shipments = await WarehouseApiService.getShipments(status: status);
    } catch (e) {
      _setError('Failed to load shipments: ${e.toString()}');
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
    return _products.where((p) => p.category == category).toList();
  }

  List<Shipment> getShipmentsByStatus(String status) {
    return _shipments.where((s) => s.status == status).toList();
  }

  List<Product> searchProducts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _products.where((p) => 
      p.name.toLowerCase().contains(lowercaseQuery) ||
      p.id.toLowerCase().contains(lowercaseQuery) ||
      p.category.toLowerCase().contains(lowercaseQuery)
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
    _shipments.clear();
    _error = null;
    _isLoading = false;
    _isConnected = false;
    notifyListeners();
  }
}
