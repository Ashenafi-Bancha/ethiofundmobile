class UserModel {
  const UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.status,
  });

  final int userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String role;
  final String status;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: (json['user_id'] ?? json['userId'] ?? 0) as int,
      fullName: (json['full_name'] ?? json['fullName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phoneNumber: json['phone_number']?.toString() ?? json['phoneNumber']?.toString(),
      role: (json['role'] ?? 'guest') as String,
      status: (json['status'] ?? 'active') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'role': role,
        'status': status,
      };

  UserModel copyWith({
    int? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? role,
    String? status,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}