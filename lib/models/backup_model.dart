class BackupModel {
  final String id;
  final String userId;
  final String fichier;
  final bool telechargement;
  final DateTime createdAt;

  BackupModel({
    required this.id,
    required this.userId,
    required this.fichier,
    this.telechargement = false,
    required this.createdAt,
  });

  factory BackupModel.fromMap(Map<String, dynamic> map) {
    return BackupModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fichier: map['fichier'] ?? '',
      telechargement: map['telechargement'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fichier': fichier,
      'telechargement': telechargement,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  BackupModel copyWith({
    String? id,
    String? userId,
    String? fichier,
    bool? telechargement,
    DateTime? createdAt,
  }) {
    return BackupModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fichier: fichier ?? this.fichier,
      telechargement: telechargement ?? this.telechargement,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 