import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/department.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  final _nameController = TextEditingController();
  List<Department> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  void _loadDepartments() async {
    final depts = await DatabaseHelper.instance.getDepartments();
    setState(() => _departments = depts);
  }

  void _addDepartment() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnack('Enter department name', Colors.red);
      return;
    }
    await DatabaseHelper.instance.addDepartment(name);
    _showSnack('Department added', Colors.green);
    _nameController.clear();
    _loadDepartments();
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Departments')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'New Department Name',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addDepartment,
              child: const Text('Add Department'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _departments
                    .map((d) => ListTile(title: Text(d.name)))
                    .toList(),
              ),
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
