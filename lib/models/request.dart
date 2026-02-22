class Request {
  int? id;
  int employeeId;
  String item;
  double price;

  Request({
    this.id,
    required this.employeeId,
    required this.item,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'employee_id': employeeId, 'item': item, 'price': price};
  }

  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id'],
      employeeId: map['employee_id'],
      item: map['item'],
      price: map['price'],
    );
  }
}
