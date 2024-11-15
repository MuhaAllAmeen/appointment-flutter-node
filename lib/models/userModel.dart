// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String fullName;
  final String phone;
  final String email;

  UserModel({
    required this.email,
    required this.fullName,
    required this.phone,
  });

  UserModel copyWith({
    String? fullName,
    String? phone,
  }) {
    return UserModel(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'fullName': fullName,
      'phone': phone,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      fullName: map['fullName'] as String,
      phone: map['phone'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UserModel(fullName: $fullName, phone: $phone , email: $email)';

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.email == email &&
      other.fullName == fullName &&
      other.phone == phone;

  }

  @override
  int get hashCode => fullName.hashCode ^ phone.hashCode ^ email.hashCode;
}
