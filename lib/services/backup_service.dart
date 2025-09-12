import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/backup_model.dart';

class BackupService {
  static const String _collection = 'backups';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Créer une nouvelle sauvegarde
  Future<BackupModel> createBackup({
    required String createdByUserId,
    required String createdByUserName,
    required String
    backupType, // 'full', 'incremental', 'data_only', 'users_only'
    String description = '',
    Map<String, dynamic> metadata = const {},
  }) async {
    final backupId = _firestore.collection(_collection).doc().id;

    final backup = BackupModel(
      id: backupId,
      userId: createdByUserId,
      fichier: '', // Sera mis à jour lors de la sauvegarde
      createdAt: DateTime.now(),
      status: 'pending',
      fileSize: 0,
      backupType: backupType,
      metadata: metadata,
      createdByUserId: createdByUserId,
      createdByUserName: createdByUserName,
      description: description,
    );

    await _firestore.collection(_collection).doc(backupId).set(backup.toMap());

    return backup;
  }

  /// Récupérer une sauvegarde par ID
  Future<BackupModel?> getBackup(String backupId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(backupId).get();

      if (doc.exists) {
        return BackupModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error getting backup: $e');
    }
    return null;
  }

  /// Récupérer toutes les sauvegardes
  Future<List<BackupModel>> getAllBackups() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => BackupModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all backups: $e');
      return [];
    }
  }

  /// Récupérer les sauvegardes par type
  Future<List<BackupModel>> getBackupsByType(String backupType) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('backupType', isEqualTo: backupType)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => BackupModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting backups by type: $e');
      return [];
    }
  }

  /// Récupérer les sauvegardes récentes
  Future<List<BackupModel>> getRecentBackups({int limit = 10}) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .get();

      return querySnapshot.docs
          .map((doc) => BackupModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting recent backups: $e');
      return [];
    }
  }

  /// Mettre à jour une sauvegarde
  Future<void> updateBackup(
    String backupId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      await _firestore.collection(_collection).doc(backupId).update(updateData);
    } catch (e) {
      print('Error updating backup: $e');
      rethrow;
    }
  }

  /// Marquer une sauvegarde comme terminée
  Future<void> markBackupCompleted(
    String backupId,
    String filePath,
    int fileSize,
  ) async {
    try {
      await _firestore.collection(_collection).doc(backupId).update({
        'status': 'completed',
        'filePath': filePath,
        'fileSize': fileSize,
        'completedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error marking backup as completed: $e');
      rethrow;
    }
  }

  /// Marquer une sauvegarde comme échouée
  Future<void> markBackupFailed(String backupId, String errorMessage) async {
    try {
      await _firestore.collection(_collection).doc(backupId).update({
        'status': 'failed',
        'errorMessage': errorMessage,
        'failedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error marking backup as failed: $e');
      rethrow;
    }
  }

  /// Supprimer une sauvegarde
  Future<void> deleteBackup(String backupId) async {
    try {
      await _firestore.collection(_collection).doc(backupId).delete();
    } catch (e) {
      print('Error deleting backup: $e');
      rethrow;
    }
  }

  /// Effectuer une sauvegarde complète
  Future<BackupModel> performFullBackup({
    required String createdByUserId,
    required String createdByUserName,
    String description = 'Sauvegarde complète automatique',
  }) async {
    try {
      // Créer l'enregistrement de sauvegarde
      final backup = await createBackup(
        createdByUserId: createdByUserId,
        createdByUserName: createdByUserName,
        backupType: 'full',
        description: description,
        metadata: {
          'autoBackup': true,
          'collections': [
            'users',
            'data_collections',
            'missions',
            'forest_zones',
            'analysis_reports',
            'error_logs',
          ],
        },
      );

      // Marquer comme en cours
      await updateBackup(backup.id, {
        'status': 'in_progress',
        'startedAt': DateTime.now().toIso8601String(),
      });

      // Ici, vous pourriez implémenter la logique de sauvegarde réelle
      // Pour l'instant, on simule une sauvegarde réussie
      await Future.delayed(const Duration(seconds: 2));

      // Marquer comme terminée
      await markBackupCompleted(
        backup.id,
        '/backups/full_backup_${backup.id}.json',
        1024000, // 1MB simulé
      );

      return backup;
    } catch (e) {
      print('Error performing full backup: $e');
      rethrow;
    }
  }

  /// Effectuer une sauvegarde incrémentale
  Future<BackupModel> performIncrementalBackup({
    required String createdByUserId,
    required String createdByUserName,
    String description = 'Sauvegarde incrémentale automatique',
  }) async {
    try {
      // Créer l'enregistrement de sauvegarde
      final backup = await createBackup(
        createdByUserId: createdByUserId,
        createdByUserName: createdByUserName,
        backupType: 'incremental',
        description: description,
        metadata: {
          'autoBackup': true,
          'lastBackupDate':
              DateTime.now()
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
        },
      );

      // Marquer comme en cours
      await updateBackup(backup.id, {
        'status': 'in_progress',
        'startedAt': DateTime.now().toIso8601String(),
      });

      // Ici, vous pourriez implémenter la logique de sauvegarde incrémentale
      await Future.delayed(const Duration(seconds: 1));

      // Marquer comme terminée
      await markBackupCompleted(
        backup.id,
        '/backups/incremental_backup_${backup.id}.json',
        512000, // 512KB simulé
      );

      return backup;
    } catch (e) {
      print('Error performing incremental backup: $e');
      rethrow;
    }
  }

  /// Restaurer une sauvegarde
  Future<void> restoreBackup(
    String backupId,
    String restoredByUserId,
    String restoredByUserName,
  ) async {
    try {
      final backup = await getBackup(backupId);
      if (backup == null) {
        throw Exception('Sauvegarde non trouvée');
      }

      if (backup.status != 'completed') {
        throw Exception('Impossible de restaurer une sauvegarde non terminée');
      }

      // Créer un enregistrement de restauration
      await _firestore.collection('restorations').add({
        'backupId': backupId,
        'restoredByUserId': restoredByUserId,
        'restoredByUserName': restoredByUserName,
        'restoredAt': DateTime.now().toIso8601String(),
        'status': 'in_progress',
      });

      // Ici, vous pourriez implémenter la logique de restauration réelle
      await Future.delayed(const Duration(seconds: 3));

      // Marquer la restauration comme terminée
      await _firestore.collection('restorations').add({
        'backupId': backupId,
        'restoredByUserId': restoredByUserId,
        'restoredByUserName': restoredByUserName,
        'restoredAt': DateTime.now().toIso8601String(),
        'status': 'completed',
      });
    } catch (e) {
      print('Error restoring backup: $e');
      rethrow;
    }
  }

  /// Stream de toutes les sauvegardes
  Stream<List<BackupModel>> streamAllBackups() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => BackupModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  /// Obtenir les statistiques des sauvegardes
  Future<Map<String, dynamic>> getBackupStats() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();

      final backups =
          querySnapshot.docs
              .map((doc) => BackupModel.fromMap(doc.data()))
              .toList();

      final totalSize = backups
          .where((b) => b.fileSize > 0)
          .fold<int>(0, (sum, b) => sum + b.fileSize);

      return {
        'total': backups.length,
        'completed': backups.where((b) => b.status == 'completed').length,
        'failed': backups.where((b) => b.status == 'failed').length,
        'inProgress': backups.where((b) => b.status == 'in_progress').length,
        'totalSize': totalSize,
        'averageSize': backups.isNotEmpty ? totalSize / backups.length : 0,
        'byType': {
          'full': backups.where((b) => b.backupType == 'full').length,
          'incremental':
              backups.where((b) => b.backupType == 'incremental').length,
          'data_only': backups.where((b) => b.backupType == 'data_only').length,
          'users_only':
              backups.where((b) => b.backupType == 'users_only').length,
        },
        'lastBackup':
            backups.isNotEmpty
                ? backups.first.createdAt.toIso8601String()
                : null,
      };
    } catch (e) {
      print('Error getting backup stats: $e');
      return {};
    }
  }

  /// Vérifier si une sauvegarde est nécessaire
  Future<bool> isBackupNeeded() async {
    try {
      final recentBackups = await getRecentBackups(limit: 1);

      if (recentBackups.isEmpty) return true;

      final lastBackup = recentBackups.first;
      final daysSinceLastBackup =
          DateTime.now().difference(lastBackup.createdAt).inDays;

      // Sauvegarde nécessaire si plus de 7 jours
      return daysSinceLastBackup >= 7;
    } catch (e) {
      print('Error checking if backup is needed: $e');
      return true; // En cas d'erreur, on considère qu'une sauvegarde est nécessaire
    }
  }
}
