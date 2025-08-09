class HistoryModel {
  final String id;
  final DateTime date;
  final String typeOperation;
  final String details;
  final String userId;

  HistoryModel({
    required this.id,
    required this.date,
    required this.typeOperation,
    required this.details,
    required this.userId,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'] ?? '',
      date: map['date'] != null 
          ? DateTime.parse(map['date']) 
          : DateTime.now(),
      typeOperation: map['typeOperation'] ?? '',
      details: map['details'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'typeOperation': typeOperation,
      'details': details,
      'userId': userId,
    };
  }

  HistoryModel copyWith({
    String? id,
    DateTime? date,
    String? typeOperation,
    String? details,
    String? userId,
  }) {
    return HistoryModel(
      id: id ?? this.id,
      date: date ?? this.date,
      typeOperation: typeOperation ?? this.typeOperation,
      details: details ?? this.details,
      userId: userId ?? this.userId,
    );
  }
} 