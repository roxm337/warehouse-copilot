import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/warehouse_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/dashboard_tab.dart';
import '../widgets/chat_tab.dart';
import '../widgets/products_tab.dart';
import '../widgets/shipments_tab.dart';
import '../widgets/analytics_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<Tab> _tabs = [
    const Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
    const Tab(icon: Icon(Icons.chat), text: 'AI Chat'),
    const Tab(icon: Icon(Icons.inventory), text: 'Products'),
    const Tab(icon: Icon(Icons.local_shipping), text: 'Shipments'),
    const Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });

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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Warehouse Management Panel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          isScrollable: false,
          indicatorWeight: 3,
        ),
        actions: [
          Consumer<WarehouseProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: provider.isConnected ? Colors.green : Colors.red,
                ),
                onPressed: () => provider.checkConnection(),
                tooltip: provider.isConnected ? 'Connected' : 'Disconnected',
              );
            },
          ),
          Consumer<WarehouseProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.isLoading ? null : () => provider.refreshData(),
                tooltip: 'Refresh Data',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer2<WarehouseProvider, ChatProvider>(
        builder: (context, warehouseProvider, chatProvider, child) {
          if (!warehouseProvider.isConnected && _currentIndex != 1) {
            return _buildConnectionError(warehouseProvider);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              DashboardTab(),
              ChatTab(),
              ProductsTab(),
              ShipmentsTab(),
              AnalyticsTab(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnectionError(WarehouseProvider provider) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Connection Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.error ?? 'Unable to connect to warehouse service',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: provider.isLoading ? null : () => provider.checkConnection(),
                icon: provider.isLoading 
                    ? const SizedBox(
                        width: 16, 
                        height: 16, 
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(provider.isLoading ? 'Connecting...' : 'Retry Connection'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Make sure the warehouse API is running on localhost:8000',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
