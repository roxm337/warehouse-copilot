import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/warehouse_provider.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WarehouseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.stats == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null && provider.stats == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refreshData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildModernStatCard(
                    'Total Products',
                    provider.stats?.totalProducts.toString() ?? '0',
                    Icons.inventory_2_outlined,
                    const Color(0xFF6366F1),
                    '+12%',
                    true,
                  ),
                  _buildModernStatCard(
                    'Active Orders',
                    provider.orders.length.toString(),
                    Icons.shopping_cart_outlined,
                    const Color(0xFF10B981),
                    '+8%',
                    true,
                  ),
                  _buildModernStatCard(
                    'Low Stock Items',
                    provider.stats?.lowStockProducts.toString() ?? '0',
                    Icons.warning_outlined,
                    const Color(0xFFF59E0B),
                    '-3%',
                    false,
                  ),
                  _buildModernStatCard(
                    'Revenue Today',
                    '\$${(provider.stats?.totalInventoryValue ?? 0).toStringAsFixed(0)}',
                    Icons.attach_money_outlined,
                    const Color(0xFF8B5CF6),
                    '+15%',
                    true,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Dashboard content rows
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  Expanded(
                    flex: 1,
                    child: _buildModernQuickActions(provider),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Recent Orders
                  Expanded(
                    flex: 2,
                    child: _buildModernRecentOrders(provider),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Low Stock Alert
              if (provider.lowStockProducts.isNotEmpty)
                _buildModernLowStockAlert(provider),
              const SizedBox(height: 24),
              _buildStatsGrid(provider),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildLowStockSection(provider),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildQuickActions(context, provider),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(WarehouseProvider provider) {
    final stats = provider.stats;
    if (stats == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No statistics available'),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Products',
          stats.totalProducts.toString(),
          Icons.inventory,
          Colors.blue,
        ),
        _buildStatCard(
          'Low Stock Items',
          stats.lowStockProducts.toString(),
          Icons.warning,
          Colors.orange,
        ),
        _buildStatCard(
          'Inventory Value',
          '\$${stats.totalInventoryValue.toStringAsFixed(0)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'Avg Stock Level',
          '${stats.averageStockLevel.toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockSection(WarehouseProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Low Stock Alert',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => provider.loadProducts(lowStockOnly: true),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: provider.lowStockProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'No low stock items',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.lowStockProducts.take(5).length,
                      itemBuilder: (context, index) {
                        final product = provider.lowStockProducts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: product.lowStockLimit == 0 
                                ? Colors.red 
                                : Colors.orange,
                            child: Text(
                              product.lowStockLimit.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(product.name),
                          subtitle: Text('Unit: ${product.unit}'),
                          trailing: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WarehouseProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => provider.refreshData(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => provider.loadProducts(lowStockOnly: true),
                icon: const Icon(Icons.warning),
                label: const Text('View Low Stock'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => provider.loadOrders(status: 'pending'),
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Pending Orders'),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'System Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  provider.isConnected ? Icons.check_circle : Icons.error,
                  color: provider.isConnected ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  provider.isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: provider.isConnected ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
    bool trendUp,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: trendUp 
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: trendUp 
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: trendUp 
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernQuickActions(WarehouseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            icon: Icons.add_circle_outline,
            label: 'Add Product',
            color: const Color(0xFF6366F1),
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.inventory_outlined,
            label: 'Check Inventory',
            color: const Color(0xFF10B981),
            onPressed: () => provider.loadProducts(),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.warning_outlined,
            label: 'View Low Stock',
            color: const Color(0xFFF59E0B),
            onPressed: () => provider.loadProducts(lowStockOnly: true),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.shopping_cart_outlined,
            label: 'Pending Orders',
            color: const Color(0xFF8B5CF6),
            onPressed: () => provider.loadOrders(status: 'pending'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildModernRecentOrders(WarehouseProvider provider) {
    final recentOrders = provider.orders.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentOrders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No recent orders',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            )
          else
            ...recentOrders.map((order) => _buildOrderRow(order)),
        ],
      ),
    );
  }

  Widget _buildOrderRow(dynamic order) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getOrderStatusColor(order.orderStatus ?? 'pending'),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  order.orderType ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${order.orderAmount?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'processing':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildModernLowStockAlert(WarehouseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: const Color(0xFFEF4444),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Low Stock Alert',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${provider.lowStockProducts.length} products are running low on stock',
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.lowStockProducts.take(3).length,
              itemBuilder: (context, index) {
                final product = provider.lowStockProducts[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stock: ${product.lowStockLimit}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
