class WorkerProfileModel {
  final int id;
  final String name;
  final String email;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String phoneNumber;
  final String? otherPhone;
  final String? otherEmail;
  final List<String> roles;
  final String currentRole;
  String? photo;

  WorkerProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.phoneNumber,
    this.otherPhone,
    this.otherEmail,
    required this.roles,
    required this.currentRole,
    this.photo,
  });

  factory WorkerProfileModel.fromJson(Map<String, dynamic> json) {
    return WorkerProfileModel(
      id: json['id']??-1,
      name: json['name'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name']??'',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      otherPhone: json['other_phone']??'',
      email: json['email'] ?? '',
      otherEmail: json['other_email']??'',
      roles: List<String>.from(json['roles'] ?? []),
      currentRole: json['current_role'] ?? '',
      photo: json['photo']??'',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'other_phone': otherPhone,
      'email': email,
      'other_email': otherEmail,
      'roles': roles,
      'current_role': currentRole,
      'photo': photo,
    };
  }
}