class AnalysisReportModel {
  final String id;
  final String title;
  final String description;
  final String createdByUserId;
  final String createdByUserName;
  final String
  reportType; // 'inventory', 'data_collection', 'performance', 'trend'
  final DateTime createdAt;
  final DateTime? lastModified;
  final String status; // 'draft', 'published'
  final List<String> dataSourceIds; // IDs des collections de données utilisées
  final Map<String, dynamic> analysisData; // Résultats de l'analyse
  final List<String> charts; // URLs ou données des graphiques
  final List<String> attachments;
  final String summary;
  final Map<String, dynamic> recommendations;
  final Map<String, dynamic> metadata;

  AnalysisReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdByUserId,
    required this.createdByUserName,
    required this.reportType,
    required this.createdAt,
    this.lastModified,
    this.status = 'draft',
    this.dataSourceIds = const [],
    this.analysisData = const {},
    this.charts = const [],
    this.attachments = const [],
    this.summary = '',
    this.recommendations = const {},
    this.metadata = const {},
  });

  factory AnalysisReportModel.fromMap(Map<String, dynamic> map) {
    return AnalysisReportModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdByUserId: map['createdByUserId'] ?? '',
      createdByUserName: map['createdByUserName'] ?? '',
      reportType: map['reportType'] ?? '',
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      lastModified:
          map['lastModified'] != null
              ? DateTime.parse(map['lastModified'])
              : null,
      status: map['status'] ?? 'draft',
      dataSourceIds: List<String>.from(map['dataSourceIds'] ?? []),
      analysisData: Map<String, dynamic>.from(map['analysisData'] ?? {}),
      charts: List<String>.from(map['charts'] ?? []),
      attachments: List<String>.from(map['attachments'] ?? []),
      summary: map['summary'] ?? '',
      recommendations: Map<String, dynamic>.from(map['recommendations'] ?? {}),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdByUserId': createdByUserId,
      'createdByUserName': createdByUserName,
      'reportType': reportType,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
      'status': status,
      'dataSourceIds': dataSourceIds,
      'analysisData': analysisData,
      'charts': charts,
      'attachments': attachments,
      'summary': summary,
      'recommendations': recommendations,
      'metadata': metadata,
    };
  }

  AnalysisReportModel copyWith({
    String? id,
    String? title,
    String? description,
    String? createdByUserId,
    String? createdByUserName,
    String? reportType,
    DateTime? createdAt,
    DateTime? lastModified,
    String? status,
    List<String>? dataSourceIds,
    Map<String, dynamic>? analysisData,
    List<String>? charts,
    List<String>? attachments,
    String? summary,
    Map<String, dynamic>? recommendations,
    Map<String, dynamic>? metadata,
  }) {
    return AnalysisReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdByUserName: createdByUserName ?? this.createdByUserName,
      reportType: reportType ?? this.reportType,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      status: status ?? this.status,
      dataSourceIds: dataSourceIds ?? this.dataSourceIds,
      analysisData: analysisData ?? this.analysisData,
      charts: charts ?? this.charts,
      attachments: attachments ?? this.attachments,
      summary: summary ?? this.summary,
      recommendations: recommendations ?? this.recommendations,
      metadata: metadata ?? this.metadata,
    );
  }

  // Méthodes utilitaires
  bool get isDraft => status == 'draft';
  bool get isPublished => status == 'published';

  String get statusDisplayName {
    switch (status) {
      case 'draft':
        return 'Brouillon';
      case 'published':
        return 'Publié';
      default:
        return 'Inconnu';
    }
  }

  String get reportTypeDisplayName {
    switch (reportType) {
      case 'inventory':
        return 'Rapport d\'inventaire';
      case 'data_collection':
        return 'Rapport de collecte';
      case 'performance':
        return 'Rapport de performance';
      case 'trend':
        return 'Rapport de tendances';
      default:
        return 'Rapport';
    }
  }

  bool get hasBeenModified => lastModified != null;
  bool get hasRecommendations => recommendations.isNotEmpty;
  bool get hasCharts => charts.isNotEmpty;
  bool get hasAttachments => attachments.isNotEmpty;
}
