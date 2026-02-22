class Employee {
  int? id;
  String name;
  String department;
  double paid;

  Employee({
    this.id,
    required this.name,
    required this.department,
    required this.paid,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'department': department, 'paid': paid};
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      department: map['department'],
      paid: map['paid'],
    );
  }
}
