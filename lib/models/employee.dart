class Employee {
  final String id;
  final String name;
  final String position;
  final double salary;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.salary,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'], // تأكد من أن `_id` هو الحقل الصحيح في الـ API
      name: json['name'],
      position: json['position'],
      salary: json['salary'],
    );
  }
}
