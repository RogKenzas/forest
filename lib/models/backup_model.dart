class BackupModel {
  final String id;
  final String userId;
  final String fichier;
  final bool telechargement;
  final DateTime createdAt;
  final String status; // 'pending', 'completed', 'failed'
  final int fileSize; // en bytes
  final String backupType; // 'full', 'incremental', 'manual'
  final String? errorMessage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? filePath;
  final Map<String, dynamic> metadata;
  final String createdByUserId;
  final String createdByUserName;
  final String description;

  BackupModel({
    required this.id,
    required this.userId,
    required this.fichier,
    this.telechargement = false,
    required this.createdAt,
    this.status = 'pending',
    this.fileSize = 0,
    this.backupType = 'manual',
    this.errorMessage,
    this.startedAt,
    this.completedAt,
    this.failedAt,
    this.filePath,
    this.metadata = const {},
    this.createdByUserId = '',
    this.createdByUserName = '',
    this.description = '',
  });

  factory BackupModel.fromMap(Map<String, dynamic> map) {
    return BackupModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fichier: map['fichier'] ?? '',
      telechargement: map['telechargement'] ?? false,
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      status: map['status'] ?? 'pending',
      fileSize: map['fileSize'] ?? 0,
      backupType: map['backupType'] ?? 'manual',
      errorMessage: map['errorMessage'],
      startedAt:
          map['startedAt'] != null ? DateTime.parse(map['startedAt']) : null,
      completedAt:
          map['completedAt'] != null
              ? DateTime.parse(map['completedAt'])
              : null,
      failedAt:
          map['failedAt'] != null ? DateTime.parse(map['failedAt']) : null,
      filePath: map['filePath'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdByUserId: map['createdByUserId'] ?? '',
      createdByUserName: map['createdByUserName'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fichier': fichier,
      'telechargement': telechargement,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'fileSize': fileSize,
      'backupType': backupType,
      'errorMessage': errorMessage,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failedAt': failedAt?.toIso8601String(),
      'filePath': filePath,
      'metadata': metadata,
      'createdByUserId': createdByUserId,
      'createdByUserName': createdByUserName,
      'description': description,
    };
  }

  BackupModel copyWith({
    String? id,
    String? userId,
    String? fichier,
    bool? telechargement,
    DateTime? createdAt,
    String? status,
    int? fileSize,
    String? backupType,
    String? errorMessage,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? failedAt,
    String? filePath,
    Map<String, dynamic>? metadata,
    String? createdByUserId,
    String? createdByUserName,
    String? description,
  }) {
    return BackupModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fichier: fichier ?? this.fichier,
      telechargement: telechargement ?? this.telechargement,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      fileSize: fileSize ?? this.fileSize,
      backupType: backupType ?? this.backupType,
      errorMessage: errorMessage ?? this.errorMessage,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      failedAt: failedAt ?? this.failedAt,
      filePath: filePath ?? this.filePath,
      metadata: metadata ?? this.metadata,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdByUserName: createdByUserName ?? this.createdByUserName,
      description: description ?? this.description,
    );
  }

  // Méthodes utilitaires
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'completed':
        return 'Terminé';
      case 'failed':
        return 'Échoué';
      default:
        return 'Inconnu';
    }
  }

  String get fileSizeDisplay {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024)
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get backupTypeDisplayName {
    switch (backupType) {
      case 'full':
        return 'Complète';
      case 'incremental':
        return 'Incrémentale';
      case 'data_only':
        return 'Données uniquement';
      case 'users_only':
        return 'Utilisateurs uniquement';
      case 'manual':
        return 'Manuelle';
      default:
        return backupType;
    }
  }
}
