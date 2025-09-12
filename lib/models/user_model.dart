enum UserRole {
  agent, // Agent de terrain
  analyst, // Analyste
  supervisor, // Superviseur
  admin, // Administrateur
}

class UserModel {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final bool isStaff;
  final bool isActive;
  final bool isSuperUser;
  final UserRole role;
  final DateTime dateJoined;
  final DateTime? lastLogin;
  final int? assignedCodeProspe;
  final int? assignedBloc;
  final int? assignedAccessCode;
  final DateTime? assignedAt;
  final List<String> assignedZones; // Zones forestières assignées
  final Map<String, dynamic> permissions; // Permissions spécifiques

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.isStaff = false,
    this.isActive = true,
    this.isSuperUser = false,
    this.role = UserRole.agent,
    required this.dateJoined,
    this.lastLogin,
    this.assignedCodeProspe,
    this.assignedBloc,
    this.assignedAccessCode,
    this.assignedAt,
    this.assignedZones = const [],
    this.permissions = const {},
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
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.agent,
      ),
      dateJoined:
          map['dateJoined'] != null
              ? DateTime.parse(map['dateJoined'])
              : DateTime.now(),
      lastLogin:
          map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
      assignedCodeProspe: map['assignedCodeProspe'],
      assignedBloc: map['assignedBloc'],
      assignedAccessCode: map['assignedAccessCode'],
      assignedAt:
          map['assignedAt'] != null ? DateTime.parse(map['assignedAt']) : null,
      assignedZones: List<String>.from(map['assignedZones'] ?? []),
      permissions: Map<String, dynamic>.from(map['permissions'] ?? {}),
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
      'role': role.name,
      'dateJoined': dateJoined.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'assignedCodeProspe': assignedCodeProspe,
      'assignedBloc': assignedBloc,
      'assignedAccessCode': assignedAccessCode,
      'assignedAt': assignedAt?.toIso8601String(),
      'assignedZones': assignedZones,
      'permissions': permissions,
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
    UserRole? role,
    DateTime? dateJoined,
    DateTime? lastLogin,
    int? assignedCodeProspe,
    int? assignedBloc,
    int? assignedAccessCode,
    DateTime? assignedAt,
    List<String>? assignedZones,
    Map<String, dynamic>? permissions,
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
      role: role ?? this.role,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      assignedCodeProspe: assignedCodeProspe ?? this.assignedCodeProspe,
      assignedBloc: assignedBloc ?? this.assignedBloc,
      assignedAccessCode: assignedAccessCode ?? this.assignedAccessCode,
      assignedAt: assignedAt ?? this.assignedAt,
      assignedZones: assignedZones ?? this.assignedZones,
      permissions: permissions ?? this.permissions,
    );
  }

  String get fullName => '$firstName $lastName';

  // Méthodes utilitaires pour les rôles
  String get roleDisplayName {
    switch (role) {
      case UserRole.agent:
        return 'Agent de terrain';
      case UserRole.analyst:
        return 'Analyste';
      case UserRole.supervisor:
        return 'Superviseur';
      case UserRole.admin:
        return 'Administrateur';
    }
  }

  bool get isAgent => role == UserRole.agent;
  bool get isAnalyst => role == UserRole.analyst;
  bool get isSupervisor => role == UserRole.supervisor;
  bool get isAdmin => role == UserRole.admin;

  // Vérification des permissions
  bool hasPermission(String permission) {
    return permissions[permission] == true || isAdmin;
  }

  // Permissions spécifiques par rôle
  bool get canManageInventory => isAgent || isSupervisor || isAdmin;
  bool get canCollectData => isAgent || isSupervisor || isAdmin;
  bool get canAnalyzeData => isAnalyst || isSupervisor || isAdmin;
  bool get canExportData => isAnalyst || isSupervisor || isAdmin;
  bool get canManageUsers => isAdmin;
  bool get canManageZones => isAdmin;
  bool get canViewReports => isSupervisor || isAdmin;
  bool get canManageBackups => isSupervisor || isAdmin;
  bool get canHandleErrors => isSupervisor || isAdmin;
}
