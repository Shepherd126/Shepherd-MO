class User {
  String id;
  String name;
  String phone;
  String email;
  String role;
  DateTime createDate;
  DateTime? updateDate;
  bool isDeleted;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.createDate,
    this.updateDate,
    required this.isDeleted,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      createDate: DateTime.parse(json['createDate']),
      updateDate: json['updateDate'] != null
          ? DateTime.parse(json['updateDate'])
          : null,
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'createDate': createDate.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}
