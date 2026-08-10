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
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      otherPhone: json['other_phone'],
      otherEmail: json['other_email'],
      roles: List<String>.from(json['roles'] ?? []),
      currentRole: json['current_role'] ?? '',
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'other_phone': otherPhone,
      'other_email': otherEmail,
      'id': id,
      'name': name,
      'email': email,
      'roles': roles,
      'currentRole': currentRole,
      'photo': photo,
    };
  }
}