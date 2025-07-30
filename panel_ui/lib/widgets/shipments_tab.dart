import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/warehouse_provider.dart';

class ShipmentsTab extends StatelessWidget {
  const ShipmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WarehouseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.shipments.isEmpty) {
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
                    'Shipments',
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
                child: provider.shipments.isEmpty
                    ? const Center(
                        child: Text('No shipments available'),
                      )
                    : ListView.builder(
                        itemCount: provider.shipments.length,
                        itemBuilder: (context, index) {
                          final shipment = provider.shipments[index];
                          final isDelayed = shipment.isDelayed;
                          final isPending = shipment.isPending;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isDelayed 
                                    ? Colors.red 
                                    : isPending 
                                        ? Colors.orange 
                                        : Colors.green,
                                child: Icon(
                                  Icons.local_shipping,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text('Shipment ${shipment.id}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Product: ${shipment.productId}'),
                                  Text('Quantity: ${shipment.quantity}'),
                                  Text('${shipment.origin} → ${shipment.destination}'),
                                  Text('Expected: ${_formatDate(shipment.expectedDate)}'),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(
                                  shipment.status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: _getStatusColor(shipment.status),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'in_transit':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'delayed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
