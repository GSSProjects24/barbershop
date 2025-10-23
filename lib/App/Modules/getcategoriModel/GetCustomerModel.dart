class Customer {
  final int id;
  final String customerCode;
  final String phone;
  final String name;
  final String? email;

  Customer({
    required this.id,
    required this.customerCode,
    required this.phone,
    required this.name,
    this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customerCode: json['customer_code'],
      phone: json['phone'],
      name: json['name'],
      email: json['email'],
    );
  }
}