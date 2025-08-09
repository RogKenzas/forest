class UserModel {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final bool isStaff;
  final bool isActive;
  final bool isSuperUser;
  final DateTime dateJoined;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.isStaff = false,
    this.isActive = true,
    this.isSuperUser = false,
    required this.dateJoined,
    this.lastLogin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      isStaff: map['isStaff'] ?? false,
      isActive: map['isActive'] ?? true,
      isSuperUser: map['isSuperUser'] ?? false,
      dateJoined:
          map['dateJoined'] != null
              ? DateTime.parse(map['dateJoined'])
              : DateTime.now(),
      lastLogin:
          map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'isStaff': isStaff,
      'isActive': isActive,
      'isSuperUser': isSuperUser,
      'dateJoined': dateJoined.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    bool? isStaff,
    bool? isActive,
    bool? isSuperUser,
    DateTime? dateJoined,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      isStaff: isStaff ?? this.isStaff,
      isActive: isActive ?? this.isActive,
      isSuperUser: isSuperUser ?? this.isSuperUser,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  String get fullName => '$firstName $lastName';
}
