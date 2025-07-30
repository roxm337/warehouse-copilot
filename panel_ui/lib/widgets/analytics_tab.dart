import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/warehouse_provider.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WarehouseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.stats == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analytics',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildCategoryChart(provider),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildOrderStatusChart(provider),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildStatsSummary(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChart(WarehouseProvider provider) {
    final stats = provider.stats;
    if (stats == null || stats.categories.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No category data available'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Products by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _createCategorySections(stats.categories),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(stats.categories),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusChart(WarehouseProvider provider) {
    final stats = provider.stats;
    if (stats == null || stats.orderStatus.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No order data available'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipment Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: _createOrderBars(stats.orderStatus),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final statuses = stats.orderStatus.keys.toList();
                          if (value.toInt() < statuses.length) {
                            return Text(
                              statuses[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(WarehouseProvider provider) {
    final stats = provider.stats;
    if (stats == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              children: [
                _buildTableRow('Total Products', stats.totalProducts.toString()),
                _buildTableRow('Low Stock Items', stats.lowStockProducts.toString()),
                _buildTableRow('Total Inventory Value', '\$${stats.totalInventoryValue.toStringAsFixed(2)}'),
                _buildTableRow('Average Stock Level', '${stats.averageStockLevel.toStringAsFixed(1)}%'),
                _buildTableRow('Categories', stats.categories.length.toString()),
                _buildTableRow('Order Types', stats.orderStatus.length.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createCategorySections(Map<String, int> categories) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    int index = 0;
    return categories.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: entry.value.toString(),
        color: color,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _createOrderBars(Map<String, int> orderStatus) {
    int index = 0;
    return orderStatus.entries.map((entry) {
      return BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: _getOrderStatusColor(entry.key),
            width: 20,
          ),
        ],
      );
    }).toList();
  }

  Color _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLegend(Map<String, int> categories) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    int index = 0;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categories.entries.map((entry) {
        final color = colors[index % colors.length];
        index++;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key} (${entry.value})',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(value),
        ),
      ],
    );
  }
}
