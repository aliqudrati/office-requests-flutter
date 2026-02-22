import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/request.dart';

class ListRequestsScreen extends StatefulWidget {
  const ListRequestsScreen({super.key});

  @override
  State<ListRequestsScreen> createState() => _ListRequestsScreenState();
}

class _ListRequestsScreenState extends State<ListRequestsScreen> {
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final rows = await DatabaseHelper.instance.getFullData();
    setState(() => _data = rows);
  }

  void _deleteRequest(int id) async {
    await DatabaseHelper.instance.deleteRequest(id);
    _showSnack('Request deleted', Colors.green);
    _loadData();
  }

  void _deleteEmployee(int id) async {
    await DatabaseHelper.instance.deleteEmployee(id);
    _showSnack('Employee deleted', Colors.green);
    _loadData();
  }

  void _editRequest(int id, String oldItem, double oldPrice) {
    final _itemController = TextEditingController(text: oldItem);
    final _priceController = TextEditingController(text: oldPrice.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _itemController,
              decoration: const InputDecoration(labelText: 'Item'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final price = double.tryParse(_priceController.text);
              if (price == null) {
                _showSnack('Invalid price', Colors.red);
                return;
              }
              await DatabaseHelper.instance.updateRequest(
                Request(
                  id: id,
                  employeeId: 0,
                  item: _itemController.text,
                  price: price,
                ),
              );
              Navigator.pop(context);
              _showSnack('Request updated', Colors.green);
              _loadData();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    // Group by employee
    Map<int, Map<String, dynamic>> employees = {};
    for (var row in _data) {
      int eid = row['id'];
      if (!employees.containsKey(eid)) {
        employees[eid] = {
          'name': row['name'],
          'paid': row['paid'],
          'items': [],
        };
      }
      if (row['rid'] != null) {
        employees[eid]!['items'].add({
          'id': row['rid'],
          'item': row['item'],
          'price': row['price'],
        });
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Requests Overview')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...employees.entries.map((e) {
            final emp = e.value;
            double totalSpent = emp['items'].fold(
              0.0,
              (sum, i) => sum + i['price'],
            );
            double balance = emp['paid'] - totalSpent;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Paid: ${emp['paid']} | Spent: $totalSpent | Balance: $balance',
                    ),
                    const SizedBox(height: 6),
                    ...emp['items'].map<Widget>(
                      (item) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item['item']} (${item['price']})'),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _editRequest(
                                  item['id'],
                                  item['item'],
                                  item['price'],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteRequest(item['id']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Delete Employee',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () => _deleteEmployee(e.key),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('⬅ Back'),
          ),
        ],
      ),
    );
  }
}
