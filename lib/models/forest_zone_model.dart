class ForestZoneModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final double area; // en hectares
  final String status; // 'active', 'inactive', 'maintenance'
  final DateTime createdAt;
  final DateTime? lastInspection;
  final String assignedSupervisorId;
  final List<String> assignedAgentIds;
  final Map<String, dynamic> characteristics; // type de sol, végétation, etc.
  final List<String> accessPoints;
  final Map<String, dynamic> restrictions;
  final String imageUrl;
  final Map<String, dynamic> metadata;

  ForestZoneModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.area,
    this.status = 'active',
    required this.createdAt,
    this.lastInspection,
    this.assignedSupervisorId = '',
    this.assignedAgentIds = const [],
    this.characteristics = const {},
    this.accessPoints = const [],
    this.restrictions = const {},
    this.imageUrl = '',
    this.metadata = const {},
  });

  factory ForestZoneModel.fromMap(Map<String, dynamic> map) {
    return ForestZoneModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      area: (map['area'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'active',
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      lastInspection:
          map['lastInspection'] != null
              ? DateTime.parse(map['lastInspection'])
              : null,
      assignedSupervisorId: map['assignedSupervisorId'] ?? '',
      assignedAgentIds: List<String>.from(map['assignedAgentIds'] ?? []),
      characteristics: Map<String, dynamic>.from(map['characteristics'] ?? {}),
      accessPoints: List<String>.from(map['accessPoints'] ?? []),
      restrictions: Map<String, dynamic>.from(map['restrictions'] ?? {}),
      imageUrl: map['imageUrl'] ?? '',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'area': area,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'lastInspection': lastInspection?.toIso8601String(),
      'assignedSupervisorId': assignedSupervisorId,
      'assignedAgentIds': assignedAgentIds,
      'characteristics': characteristics,
      'accessPoints': accessPoints,
      'restrictions': restrictions,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  ForestZoneModel copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    double? area,
    String? status,
    DateTime? createdAt,
    DateTime? lastInspection,
    String? assignedSupervisorId,
    List<String>? assignedAgentIds,
    Map<String, dynamic>? characteristics,
    List<String>? accessPoints,
    Map<String, dynamic>? restrictions,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return ForestZoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      area: area ?? this.area,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastInspection: lastInspection ?? this.lastInspection,
      assignedSupervisorId: assignedSupervisorId ?? this.assignedSupervisorId,
      assignedAgentIds: assignedAgentIds ?? this.assignedAgentIds,
      characteristics: characteristics ?? this.characteristics,
      accessPoints: accessPoints ?? this.accessPoints,
      restrictions: restrictions ?? this.restrictions,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  // Méthodes utilitaires
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isUnderMaintenance => status == 'maintenance';

  String get statusDisplayName {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'maintenance':
        return 'En maintenance';
      default:
        return 'Inconnu';
    }
  }

  bool get hasAssignedSupervisor => assignedSupervisorId.isNotEmpty;
  bool get hasAssignedAgents => assignedAgentIds.isNotEmpty;

  String get areaDisplay => '${area.toStringAsFixed(1)} ha';

  bool isAgentAssigned(String agentId) {
    return assignedAgentIds.contains(agentId);
  }

  Duration? get timeSinceLastInspection {
    if (lastInspection == null) return null;
    return DateTime.now().difference(lastInspection!);
  }
}
