import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/warehouse_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/dashboard_tab.dart';
import '../widgets/chat_tab.dart';
import '../widgets/products_tab.dart';
import '../widgets/orders_tab.dart';
import '../widgets/analytics_tab.dart';

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      page: const DashboardTab(),
    ),
    NavigationItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'AI Assistant',
      page: const ChatTab(),
    ),
    NavigationItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      label: 'Products',
      page: const ProductsTab(),
    ),
    NavigationItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'Orders',
      page: const OrdersTab(),
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
      page: const AnalyticsTab(),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final warehouseProvider = Provider.of<WarehouseProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      warehouseProvider.initialize();
      chatProvider.initialize();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _navigationItems[_currentIndex].page;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Row(
        children: [
          // Modern Sidebar Navigation
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KasmiFood',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            'AI-Powered System',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      final isActive = index == _currentIndex;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isActive 
                                    ? const Color(0xFF6366F1).withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isActive 
                                    ? Border.all(
                                        color: const Color(0xFF6366F1).withOpacity(0.2),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isActive ? item.activeIcon : item.icon,
                                    color: isActive 
                                        ? const Color(0xFF6366F1)
                                        : const Color(0xFF6B7280),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isActive 
                                          ? FontWeight.w600 
                                          : FontWeight.w500,
                                      color: isActive 
                                          ? const Color(0xFF6366F1)
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Connection Status & Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Consumer<WarehouseProvider>(
                        builder: (context, provider, child) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: provider.isConnected 
                                  ? const Color(0xFF10B981).withOpacity(0.1)
                                  : const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: provider.isConnected 
                                    ? const Color(0xFF10B981).withOpacity(0.2)
                                    : const Color(0xFFEF4444).withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  provider.isConnected 
                                      ? Icons.cloud_done 
                                      : Icons.cloud_off,
                                  color: provider.isConnected 
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    provider.isConnected 
                                        ? 'System Online'
                                        : 'Connection Lost',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: provider.isConnected 
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, size: 16),
                                  onPressed: provider.isLoading 
                                      ? null 
                                      : () => provider.checkConnection(),
                                  color: const Color(0xFF6B7280),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _navigationItems[_currentIndex].label,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const Spacer(),
                      Consumer<WarehouseProvider>(
                        builder: (context, provider, child) {
                          return FilledButton.icon(
                            onPressed: provider.isLoading 
                                ? null 
                                : () => provider.refreshData(),
                            icon: provider.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.refresh, size: 18),
                            label: Text(provider.isLoading ? 'Loading...' : 'Refresh'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Page Content
                Expanded(
                  child: Consumer2<WarehouseProvider, ChatProvider>(
                    builder: (context, warehouseProvider, chatProvider, child) {
                      if (!warehouseProvider.isConnected && _currentIndex != 1) {
                        return _buildConnectionError(warehouseProvider);
                      }
                      
                      return Container(
                        padding: const EdgeInsets.all(24),
                        child: currentPage,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionError(WarehouseProvider provider) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.cloud_off,
                color: Color(0xFFEF4444),
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.error ?? 'Unable to connect to the food management service',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: provider.isLoading ? null : () => provider.checkConnection(),
                icon: provider.isLoading 
                    ? const SizedBox(
                        width: 16, 
                        height: 16, 
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: Text(provider.isLoading ? 'Connecting...' : 'Retry Connection'),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF6B7280),
                    size: 16,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Troubleshooting',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Make sure the API server is running on localhost:8000',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
