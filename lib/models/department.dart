class Department {
  int? id;
  String name;

  Department({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(id: map['id'], name: map['name']);
  }
}
