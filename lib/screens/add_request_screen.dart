import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/employee.dart';
import '../models/request.dart';

class AddRequestScreen extends StatefulWidget {
  const AddRequestScreen({super.key});

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  final _empNameController = TextEditingController();
  final _paidController = TextEditingController();
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedDept;
  List<Map<String, dynamic>> _items = [];
  List<String> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  void _loadDepartments() async {
    final depts = await DatabaseHelper.instance.getDepartments();
    setState(() {
      _departments = depts.map((d) => d.name).toList();
    });
  }

  void _addItem() {
    final item = _itemController.text.trim();
    final priceStr = _priceController.text.trim();
    if (item.isEmpty || priceStr.isEmpty) {
      _showSnack('Item and Price required', Colors.red);
      return;
    }
    final price = double.tryParse(priceStr);
    if (price == null) {
      _showSnack('Price must be a number', Colors.red);
      return;
    }
    setState(() {
      _items.add({'item': item, 'price': price});
      _itemController.clear();
      _priceController.clear();
    });
  }

  void _saveRequest() async {
    final name = _empNameController.text.trim();
    final paidStr = _paidController.text.trim();
    final dept = _selectedDept;

    if (name.isEmpty || paidStr.isEmpty || dept == null) {
      _showSnack('Employee, Department, and Total Paid required', Colors.red);
      return;
    }

    final paid = double.tryParse(paidStr);
    if (paid == null) {
      _showSnack('Total Paid must be a number', Colors.red);
      return;
    }

    final empId = await DatabaseHelper.instance.addEmployee(
      Employee(name: name, department: dept, paid: paid),
    );

    for (var item in _items) {
      await DatabaseHelper.instance.addRequest(
        Request(employeeId: empId, item: item['item'], price: item['price']),
      );
    }

    _showSnack('Request added successfully', Colors.green);

    setState(() {
      _empNameController.clear();
      _paidController.clear();
      _itemController.clear();
      _priceController.clear();
      _items.clear();
      _loadDepartments();
      _selectedDept = null;
    });
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Request')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _empNameController,
              decoration: const InputDecoration(labelText: 'Employee Name'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedDept,
              items: _departments
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedDept = val),
              decoration: const InputDecoration(labelText: 'Department'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _paidController,
              decoration: const InputDecoration(labelText: 'Total Paid'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._items.map(
              (i) => ListTile(
                title: Text('${i['item']} (${i['price']})'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() => _items.remove(i));
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRequest,
              child: const Text('Save Request'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('⬅ Back'),
            ),
          ],
        ),
      ),
    );
  }
}
