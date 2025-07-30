import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/warehouse_provider.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WarehouseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Orders',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => provider.refreshData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: provider.orders.isEmpty
                    ? const Center(
                        child: Text('No orders available'),
                      )
                    : ListView.builder(
                        itemCount: provider.orders.length,
                        itemBuilder: (context, index) {
                          final order = provider.orders[index];
                          final isPending = order.isPending;
                          final isCompleted = order.isCompleted;
                          final isProcessing = order.isProcessing;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isCompleted 
                                    ? Colors.green 
                                    : isPending 
                                        ? Colors.orange 
                                        : isProcessing
                                            ? Colors.blue
                                            : Colors.grey,
                                child: const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text('Order #${order.id}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Amount: \$${order.orderAmount.toStringAsFixed(2)}'),
                                  Text('Payment: ${order.paymentMethod.replaceAll('_', ' ')}'),
                                  Text('Type: ${order.orderType}'),
                                  Text('Date: ${order.date}'),
                                  if (order.deliveryDate != null)
                                    Text('Delivery: ${order.deliveryDate}'),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Chip(
                                    label: Text(
                                      order.orderStatus.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: _getStatusColor(order.orderStatus),
                                  ),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(
                                      order.paymentStatus.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                    backgroundColor: order.isPaid ? Colors.green.shade100 : Colors.red.shade100,
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'processing':
      case 'out_for_delivery':
        return Colors.blue;
      case 'placed':
      case 'confirmed':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
