class DataCollectionModel {
  final String id;
  final DateTime date;
  final String chantier;
  final int ufe;
  final int acc;
  final int bloc;
  final int numeroProspe;
  final int codeProspe;
  final String essence;
  final int diametre;
  final String qualite;
  final String observation;
  final String userId;
  final List<Map<String, dynamic>> materielsNecessaires;
  final bool isAlert;
  final String alertLevel; // 'Faible' | 'Moyenne' | 'Élevée' | ''
  final String alertReason;
  final DateTime? alertCreatedAt;

  DataCollectionModel({
    required this.id,
    required this.date,
    required this.chantier,
    required this.ufe,
    required this.acc,
    required this.bloc,
    required this.numeroProspe,
    required this.codeProspe,
    required this.essence,
    required this.diametre,
    required this.qualite,
    required this.observation,
    required this.userId,
    List<Map<String, dynamic>>? materielsNecessaires,
    this.isAlert = false,
    this.alertLevel = '',
    this.alertReason = '',
    this.alertCreatedAt,
  }) : materielsNecessaires = materielsNecessaires ?? const [];

  factory DataCollectionModel.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> parseMateriels(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<dynamic>()
            .map(
              (e) =>
                  e is Map<String, dynamic>
                      ? e
                      : e is Map
                      ? Map<String, dynamic>.from(e)
                      : <String, dynamic>{},
            )
            .toList();
      }
      return <Map<String, dynamic>>[];
    }

    return DataCollectionModel(
      id: map['id'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      chantier: map['chantier'] ?? '',
      ufe: map['ufe'] ?? 0,
      acc: map['acc'] ?? 0,
      bloc: map['bloc'] ?? 0,
      numeroProspe: map['numeroProspe'] ?? 0,
      codeProspe: map['codeProspe'] ?? 0,
      essence: map['essence'] ?? '',
      diametre: map['diametre'] ?? 0,
      qualite: map['qualite'] ?? '',
      observation: map['observation'] ?? '',
      userId: map['userId'] ?? '',
      materielsNecessaires: parseMateriels(map['materielsNecessaires']),
      isAlert: map['isAlert'] ?? false,
      alertLevel: map['alertLevel'] ?? '',
      alertReason: map['alertReason'] ?? '',
      alertCreatedAt:
          map['alertCreatedAt'] != null
              ? DateTime.parse(map['alertCreatedAt'])
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'chantier': chantier,
      'ufe': ufe,
      'acc': acc,
      'bloc': bloc,
      'numeroProspe': numeroProspe,
      'codeProspe': codeProspe,
      'essence': essence,
      'diametre': diametre,
      'qualite': qualite,
      'observation': observation,
      'userId': userId,
      'materielsNecessaires': materielsNecessaires,
      'isAlert': isAlert,
      'alertLevel': alertLevel,
      'alertReason': alertReason,
      'alertCreatedAt': alertCreatedAt?.toIso8601String(),
    };
  }

  DataCollectionModel copyWith({
    String? id,
    DateTime? date,
    String? chantier,
    int? ufe,
    int? acc,
    int? bloc,
    int? numeroProspe,
    int? codeProspe,
    String? essence,
    int? diametre,
    String? qualite,
    String? observation,
    String? userId,
    List<Map<String, dynamic>>? materielsNecessaires,
    bool? isAlert,
    String? alertLevel,
    String? alertReason,
    DateTime? alertCreatedAt,
  }) {
    return DataCollectionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      chantier: chantier ?? this.chantier,
      ufe: ufe ?? this.ufe,
      acc: acc ?? this.acc,
      bloc: bloc ?? this.bloc,
      numeroProspe: numeroProspe ?? this.numeroProspe,
      codeProspe: codeProspe ?? this.codeProspe,
      essence: essence ?? this.essence,
      diametre: diametre ?? this.diametre,
      qualite: qualite ?? this.qualite,
      observation: observation ?? this.observation,
      userId: userId ?? this.userId,
      materielsNecessaires: materielsNecessaires ?? this.materielsNecessaires,
      isAlert: isAlert ?? this.isAlert,
      alertLevel: alertLevel ?? this.alertLevel,
      alertReason: alertReason ?? this.alertReason,
      alertCreatedAt: alertCreatedAt ?? this.alertCreatedAt,
    );
  }
}
