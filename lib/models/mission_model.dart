class MissionModel {
  final String id;
  final String title;
  final String description;
  final String assignedUserId;
  final String assignedUserName;
  final String zone;
  final String status; // 'pending', 'in_progress', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? dueDate;
  final List<String> requiredMaterials;
  final Map<String, dynamic> instructions;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final List<String> attachments;
  final Map<String, dynamic> metadata;

  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedUserId,
    required this.assignedUserName,
    required this.zone,
    this.status = 'pending',
    required this.createdAt,
    this.startDate,
    this.endDate,
    this.dueDate,
    this.requiredMaterials = const [],
    this.instructions = const {},
    this.priority = 'medium',
    this.attachments = const [],
    this.metadata = const {},
  });

  factory MissionModel.fromMap(Map<String, dynamic> map) {
    return MissionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      assignedUserId: map['assignedUserId'] ?? '',
      assignedUserName: map['assignedUserName'] ?? '',
      zone: map['zone'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      startDate:
          map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      requiredMaterials: List<String>.from(map['requiredMaterials'] ?? []),
      instructions: Map<String, dynamic>.from(map['instructions'] ?? {}),
      priority: map['priority'] ?? 'medium',
      attachments: List<String>.from(map['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedUserId': assignedUserId,
      'assignedUserName': assignedUserName,
      'zone': zone,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'requiredMaterials': requiredMaterials,
      'instructions': instructions,
      'priority': priority,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  MissionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedUserId,
    String? assignedUserName,
    String? zone,
    String? status,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueDate,
    List<String>? requiredMaterials,
    Map<String, dynamic>? instructions,
    String? priority,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return MissionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      assignedUserName: assignedUserName ?? this.assignedUserName,
      zone: zone ?? this.zone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dueDate: dueDate ?? this.dueDate,
      requiredMaterials: requiredMaterials ?? this.requiredMaterials,
      instructions: instructions ?? this.instructions,
      priority: priority ?? this.priority,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }

  // Méthodes utilitaires
  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminée';
      case 'cancelled':
        return 'Annulée';
      default:
        return 'Inconnu';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case 'low':
        return 'Faible';
      case 'medium':
        return 'Moyenne';
      case 'high':
        return 'Élevée';
      case 'urgent':
        return 'Urgente';
      default:
        return 'Moyenne';
    }
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted || isCancelled) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  Duration? get remainingTime {
    if (dueDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(dueDate!)) return Duration.zero;
    return dueDate!.difference(now);
  }
}
