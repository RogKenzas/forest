class ErrorLogModel {
  final String id;
  final String title;
  final String description;
  final String errorType; // 'system', 'data', 'user', 'network', 'sync'
  final String severity; // 'low', 'medium', 'high', 'critical'
  final String status; // 'open', 'investigating', 'resolved', 'closed'
  final String reportedByUserId;
  final String reportedByUserName;
  final String? assignedToUserId;
  final String? assignedToUserName;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final String stackTrace;
  final Map<String, dynamic> context; // Contexte de l'erreur
  final List<String> affectedUsers;
  final List<String> affectedData;
  final String resolution;
  final List<String> attachments;
  final Map<String, dynamic> metadata;

  ErrorLogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.errorType,
    required this.severity,
    this.status = 'open',
    required this.reportedByUserId,
    required this.reportedByUserName,
    this.assignedToUserId,
    this.assignedToUserName,
    required this.createdAt,
    this.resolvedAt,
    this.closedAt,
    this.stackTrace = '',
    this.context = const {},
    this.affectedUsers = const [],
    this.affectedData = const [],
    this.resolution = '',
    this.attachments = const [],
    this.metadata = const {},
  });

  factory ErrorLogModel.fromMap(Map<String, dynamic> map) {
    return ErrorLogModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      errorType: map['errorType'] ?? '',
      severity: map['severity'] ?? 'medium',
      status: map['status'] ?? 'open',
      reportedByUserId: map['reportedByUserId'] ?? '',
      reportedByUserName: map['reportedByUserName'] ?? '',
      assignedToUserId: map['assignedToUserId'],
      assignedToUserName: map['assignedToUserName'],
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      resolvedAt:
          map['resolvedAt'] != null ? DateTime.parse(map['resolvedAt']) : null,
      closedAt:
          map['closedAt'] != null ? DateTime.parse(map['closedAt']) : null,
      stackTrace: map['stackTrace'] ?? '',
      context: Map<String, dynamic>.from(map['context'] ?? {}),
      affectedUsers: List<String>.from(map['affectedUsers'] ?? []),
      affectedData: List<String>.from(map['affectedData'] ?? []),
      resolution: map['resolution'] ?? '',
      attachments: List<String>.from(map['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'errorType': errorType,
      'severity': severity,
      'status': status,
      'reportedByUserId': reportedByUserId,
      'reportedByUserName': reportedByUserName,
      'assignedToUserId': assignedToUserId,
      'assignedToUserName': assignedToUserName,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'stackTrace': stackTrace,
      'context': context,
      'affectedUsers': affectedUsers,
      'affectedData': affectedData,
      'resolution': resolution,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  ErrorLogModel copyWith({
    String? id,
    String? title,
    String? description,
    String? errorType,
    String? severity,
    String? status,
    String? reportedByUserId,
    String? reportedByUserName,
    String? assignedToUserId,
    String? assignedToUserName,
    DateTime? createdAt,
    DateTime? resolvedAt,
    DateTime? closedAt,
    String? stackTrace,
    Map<String, dynamic>? context,
    List<String>? affectedUsers,
    List<String>? affectedData,
    String? resolution,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return ErrorLogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      errorType: errorType ?? this.errorType,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      reportedByUserId: reportedByUserId ?? this.reportedByUserId,
      reportedByUserName: reportedByUserName ?? this.reportedByUserName,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      assignedToUserName: assignedToUserName ?? this.assignedToUserName,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      stackTrace: stackTrace ?? this.stackTrace,
      context: context ?? this.context,
      affectedUsers: affectedUsers ?? this.affectedUsers,
      affectedData: affectedData ?? this.affectedData,
      resolution: resolution ?? this.resolution,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }

  // Méthodes utilitaires
  bool get isOpen => status == 'open';
  bool get isInvestigating => status == 'investigating';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';

  String get statusDisplayName {
    switch (status) {
      case 'open':
        return 'Ouvert';
      case 'investigating':
        return 'En cours d\'investigation';
      case 'resolved':
        return 'Résolu';
      case 'closed':
        return 'Fermé';
      default:
        return 'Inconnu';
    }
  }

  String get severityDisplayName {
    switch (severity) {
      case 'low':
        return 'Faible';
      case 'medium':
        return 'Moyenne';
      case 'high':
        return 'Élevée';
      case 'critical':
        return 'Critique';
      default:
        return 'Moyenne';
    }
  }

  String get errorTypeDisplayName {
    switch (errorType) {
      case 'system':
        return 'Erreur système';
      case 'data':
        return 'Erreur de données';
      case 'user':
        return 'Erreur utilisateur';
      case 'network':
        return 'Erreur réseau';
      case 'sync':
        return 'Erreur de synchronisation';
      default:
        return 'Erreur';
    }
  }

  bool get isAssigned =>
      assignedToUserId != null && assignedToUserId!.isNotEmpty;
  bool get hasResolution => resolution.isNotEmpty;
  bool get hasAttachments => attachments.isNotEmpty;
  bool get hasAffectedUsers => affectedUsers.isNotEmpty;
  bool get hasAffectedData => affectedData.isNotEmpty;

  Duration? get resolutionTime {
    if (resolvedAt == null) return null;
    return resolvedAt!.difference(createdAt);
  }

  Duration? get totalTime {
    if (closedAt == null) return null;
    return closedAt!.difference(createdAt);
  }
}
