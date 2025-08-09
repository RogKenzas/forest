import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/data_collection_model.dart';
import '../models/backup_model.dart';
import '../models/notification_model.dart';
import '../models/history_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // Data Collection Methods
  Future<String> addDataCollection(DataCollectionModel data) async {
    try {
      final String id = _uuid.v4();
      final DataCollectionModel newData = data.copyWith(id: id);

      await _firestore
          .collection('data_collections')
          .doc(id)
          .set(newData.toMap());

      return id;
    } catch (e) {
      print('Error adding data collection: $e');
      rethrow;
    }
  }

  Future<List<DataCollectionModel>> getDataCollectionsByUser(
    String userId,
  ) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('data_collections')
              .where('userId', isEqualTo: userId)
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs
          .map(
            (doc) =>
                DataCollectionModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error getting data collections: $e');
      return [];
    }
  }

  // Backup Methods
  Future<String> addBackup(BackupModel backup) async {
    try {
      final String id = _uuid.v4();
      final BackupModel newBackup = backup.copyWith(id: id);

      await _firestore.collection('backups').doc(id).set(newBackup.toMap());

      return id;
    } catch (e) {
      print('Error adding backup: $e');
      rethrow;
    }
  }

  Future<List<BackupModel>> getBackupsByUser(String userId) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('backups')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => BackupModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting backups: $e');
      return [];
    }
  }

  Future<void> deleteBackup(String backupId) async {
    try {
      await _firestore.collection('backups').doc(backupId).delete();
    } catch (e) {
      print('Error deleting backup: $e');
      rethrow;
    }
  }

  // Notification Methods
  Future<String> addNotification(NotificationModel notification) async {
    try {
      final String id = _uuid.v4();
      final NotificationModel newNotification = notification.copyWith(id: id);

      await _firestore
          .collection('notifications')
          .doc(id)
          .set(newNotification.toMap());

      return id;
    } catch (e) {
      print('Error adding notification: $e');
      rethrow;
    }
  }

  Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map(
            (doc) =>
                NotificationModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // History Methods
  Future<String> addHistory(HistoryModel history) async {
    try {
      final String id = _uuid.v4();
      final HistoryModel newHistory = history.copyWith(id: id);

      await _firestore.collection('history').doc(id).set(newHistory.toMap());

      return id;
    } catch (e) {
      print('Error adding history: $e');
      rethrow;
    }
  }

  Future<List<HistoryModel>> getHistoryByUser(String userId) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('history')
              .where('userId', isEqualTo: userId)
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs
          .map(
            (doc) => HistoryModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error getting history: $e');
      return [];
    }
  }

  // Dashboard Statistics
  Future<Map<String, dynamic>> getDashboardStats(String userId) async {
    try {
      final dataCollections = await getDataCollectionsByUser(userId);
      final notifications = await getNotificationsByUser(userId);
      final unreadNotifications = notifications.where((n) => !n.isRead).length;

      return {
        'totalDataCollections': dataCollections.length,
        'unreadNotifications': unreadNotifications,
        'recentDataCollections': dataCollections.take(5).toList(),
        'recentNotifications': notifications.take(5).toList(),
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'totalDataCollections': 0,
        'unreadNotifications': 0,
        'recentDataCollections': [],
        'recentNotifications': [],
      };
    }
  }
}
