import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/error_log_model.dart';

class ErrorService {
  static const String _collection = 'error_logs';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Créer un nouveau log d'erreur
  Future<ErrorLogModel> createErrorLog({
    required String title,
    required String description,
    required String errorType,
    required String severity,
    required String reportedByUserId,
    required String reportedByUserName,
    String stackTrace = '',
    Map<String, dynamic> context = const {},
    List<String> affectedUsers = const [],
    List<String> affectedData = const [],
  }) async {
    final errorId = _firestore.collection(_collection).doc().id;

    final errorLog = ErrorLogModel(
      id: errorId,
      title: title,
      description: description,
      errorType: errorType,
      severity: severity,
      reportedByUserId: reportedByUserId,
      reportedByUserName: reportedByUserName,
      stackTrace: stackTrace,
      context: context,
      affectedUsers: affectedUsers,
      affectedData: affectedData,
      createdAt: DateTime.now(),
    );

    await _firestore.collection(_collection).doc(errorId).set(errorLog.toMap());

    return errorLog;
  }

  /// Récupérer un log d'erreur par ID
  Future<ErrorLogModel?> getErrorLog(String errorId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(errorId).get();

      if (doc.exists) {
        return ErrorLogModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error getting error log: $e');
    }
    return null;
  }

  /// Récupérer tous les logs d'erreur
  Future<List<ErrorLogModel>> getAllErrorLogs() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ErrorLogModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all error logs: $e');
      return [];
    }
  }

  /// Récupérer les logs d'erreur ouverts
  Future<List<ErrorLogModel>> getOpenErrorLogs() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('status', whereIn: ['open', 'investigating'])
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ErrorLogModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting open error logs: $e');
      return [];
    }
  }

  /// Récupérer les logs d'erreur par type
  Future<List<ErrorLogModel>> getErrorLogsByType(String errorType) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('errorType', isEqualTo: errorType)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ErrorLogModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting error logs by type: $e');
      return [];
    }
  }

  /// Récupérer les logs d'erreur par gravité
  Future<List<ErrorLogModel>> getErrorLogsBySeverity(String severity) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('severity', isEqualTo: severity)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ErrorLogModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting error logs by severity: $e');
      return [];
    }
  }

  /// Récupérer les logs d'erreur assignés à un utilisateur
  Future<List<ErrorLogModel>> getErrorLogsByAssignee(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('assignedToUserId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ErrorLogModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting error logs by assignee: $e');
      return [];
    }
  }

  /// Récupérer les logs d'erreur critiques
  Future<List<ErrorLogModel>> getCriticalErrorLogs() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('severity', isEqualTo: 'critical')
              .where('status', whereIn: ['open', 'investigating'])
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ErrorLogModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting critical error logs: $e');
      return [];
    }
  }

  /// Mettre à jour un log d'erreur
  Future<void> updateErrorLog(
    String errorId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      await _firestore.collection(_collection).doc(errorId).update(updateData);
    } catch (e) {
      print('Error updating error log: $e');
      rethrow;
    }
  }

  /// Assigner un log d'erreur à un utilisateur
  Future<void> assignErrorLog(
    String errorId,
    String userId,
    String userName,
  ) async {
    try {
      await _firestore.collection(_collection).doc(errorId).update({
        'assignedToUserId': userId,
        'assignedToUserName': userName,
      });
    } catch (e) {
      print('Error assigning error log: $e');
      rethrow;
    }
  }

  /// Résoudre un log d'erreur
  Future<void> resolveErrorLog(String errorId, String resolution) async {
    try {
      await _firestore.collection(_collection).doc(errorId).update({
        'status': 'resolved',
        'resolution': resolution,
        'resolvedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error resolving error log: $e');
      rethrow;
    }
  }

  /// Fermer un log d'erreur
  Future<void> closeErrorLog(String errorId) async {
    try {
      await _firestore.collection(_collection).doc(errorId).update({
        'status': 'closed',
        'closedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error closing error log: $e');
      rethrow;
    }
  }

  /// Supprimer un log d'erreur
  Future<void> deleteErrorLog(String errorId) async {
    try {
      await _firestore.collection(_collection).doc(errorId).delete();
    } catch (e) {
      print('Error deleting error log: $e');
      rethrow;
    }
  }

  /// Rechercher des logs d'erreur
  Future<List<ErrorLogModel>> searchErrorLogs(String query) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .orderBy('createdAt', descending: true)
              .get();

      final allLogs =
          querySnapshot.docs
              .map((doc) => ErrorLogModel.fromMap(doc.data()))
              .toList();

      final lowerQuery = query.toLowerCase();
      return allLogs
          .where(
            (log) =>
                log.title.toLowerCase().contains(lowerQuery) ||
                log.description.toLowerCase().contains(lowerQuery) ||
                log.errorType.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      print('Error searching error logs: $e');
      return [];
    }
  }

  /// Stream de tous les logs d'erreur
  Stream<List<ErrorLogModel>> streamAllErrorLogs() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ErrorLogModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  /// Stream des logs d'erreur ouverts
  Stream<List<ErrorLogModel>> streamOpenErrorLogs() {
    return _firestore
        .collection(_collection)
        .where('status', whereIn: ['open', 'investigating'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ErrorLogModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  /// Stream des logs d'erreur critiques
  Stream<List<ErrorLogModel>> streamCriticalErrorLogs() {
    return _firestore
        .collection(_collection)
        .where('severity', isEqualTo: 'critical')
        .where('status', whereIn: ['open', 'investigating'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ErrorLogModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  /// Obtenir les statistiques des logs d'erreur
  Future<Map<String, dynamic>> getErrorStats() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();

      final logs =
          querySnapshot.docs
              .map((doc) => ErrorLogModel.fromMap(doc.data()))
              .toList();

      return {
        'total': logs.length,
        'open': logs.where((l) => l.isOpen).length,
        'investigating': logs.where((l) => l.isInvestigating).length,
        'resolved': logs.where((l) => l.isResolved).length,
        'closed': logs.where((l) => l.isClosed).length,
        'byType': {
          'system': logs.where((l) => l.errorType == 'system').length,
          'data': logs.where((l) => l.errorType == 'data').length,
          'user': logs.where((l) => l.errorType == 'user').length,
          'network': logs.where((l) => l.errorType == 'network').length,
          'sync': logs.where((l) => l.errorType == 'sync').length,
        },
        'bySeverity': {
          'low': logs.where((l) => l.severity == 'low').length,
          'medium': logs.where((l) => l.severity == 'medium').length,
          'high': logs.where((l) => l.severity == 'high').length,
          'critical': logs.where((l) => l.severity == 'critical').length,
        },
      };
    } catch (e) {
      print('Error getting error stats: $e');
      return {};
    }
  }

  /// Log automatique d'une erreur système
  Future<void> logSystemError({
    required String title,
    required String description,
    required String stackTrace,
    Map<String, dynamic> context = const {},
  }) async {
    try {
      await createErrorLog(
        title: title,
        description: description,
        errorType: 'system',
        severity: 'high',
        reportedByUserId: 'system',
        reportedByUserName: 'Système',
        stackTrace: stackTrace,
        context: context,
      );
    } catch (e) {
      print('Error logging system error: $e');
    }
  }

  /// Log automatique d'une erreur de synchronisation
  Future<void> logSyncError({
    required String description,
    required String reportedByUserId,
    required String reportedByUserName,
    Map<String, dynamic> context = const {},
  }) async {
    try {
      await createErrorLog(
        title: 'Erreur de synchronisation',
        description: description,
        errorType: 'sync',
        severity: 'medium',
        reportedByUserId: reportedByUserId,
        reportedByUserName: reportedByUserName,
        context: context,
      );
    } catch (e) {
      print('Error logging sync error: $e');
    }
  }
}
