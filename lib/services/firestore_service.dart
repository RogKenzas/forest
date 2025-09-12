import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/data_collection_model.dart';
import '../models/backup_model.dart';
import '../models/notification_model.dart';
import '../models/history_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // Users
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getUserById: $e');
      return null;
    }
  }

  Stream<List<UserModel>> streamAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('dateJoined', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => UserModel.fromMap(d.data())).toList());
  }

  Future<void> updateUserFields({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updateUserFields: $e');
      rethrow;
    }
  }

  // ===== Counters & Admin assignments =====
  Future<int> _nextCounter(String key, {int startAt = 1000}) async {
    final ref = _firestore.collection('counters').doc(key);
    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      int current = startAt;
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        current = (data['value'] ?? startAt) as int;
      }
      final next = current + 1;
      tx.set(ref, {'value': next}, SetOptions(merge: true));
      return next;
    });
  }

  Future<Map<String, int>> assignUserProspectAndBloc(String userId) async {
    try {
      // Génère un bloc aléatoire 1..10
      final int bloc = 1 + (DateTime.now().millisecondsSinceEpoch % 10);

      // Génère un numéro/code prospect aléatoire >= 100 et unique sur users
      final int codeProspe = await _generateUniqueUserCode(
        field: 'assignedCodeProspe',
        min: 100,
        max: 999999,
      );

      // Génère un code d'accès unique (6 chiffres)
      final int accessCode = await _generateUniqueUserCode(
        field: 'assignedAccessCode',
        min: 100000,
        max: 999999,
      );

      await updateUserFields(
        userId: userId,
        data: {
          'assignedCodeProspe': codeProspe,
          'assignedBloc': bloc,
          'assignedAccessCode': accessCode,
          'assignedAt': DateTime.now().toIso8601String(),
        },
      );

      // Notifie l'utilisateur avec son code d'accès
      final user = await getUserById(userId);
      if (user != null) {
        await addTraceNotification(
          toUserId: user.id,
          email: user.email,
          title: 'Accès attribué',
          message:
              'Un accès vous a été attribué. Code d\'accès: $accessCode (Bloc $bloc).',
        );
      }

      return {'codeProspe': codeProspe, 'bloc': bloc, 'accessCode': accessCode};
    } catch (e) {
      print('Error assignUserProspectAndBloc: $e');
      rethrow;
    }
  }

  // Génère un entier aléatoire unique pour un champ user spécifique
  Future<int> _generateUniqueUserCode({
    required String field,
    required int min,
    required int max,
    int maxAttempts = 20,
  }) async {
    final rnd = DateTime.now().millisecondsSinceEpoch;
    int seed = rnd & 0x7fffffff;
    int attempt = 0;
    while (attempt < maxAttempts) {
      // simple LCG
      seed = (1103515245 * seed + 12345) & 0x7fffffff;
      final candidate = min + (seed % (max - min + 1));
      final exists =
          await _firestore
              .collection('users')
              .where(field, isEqualTo: candidate)
              .limit(1)
              .get();
      if (exists.docs.isEmpty) {
        return candidate;
      }
      attempt++;
    }
    // fallback sur un compteur si collision systématique
    return _nextCounter(field, startAt: min);
  }

  Future<Map<String, UserModel>> getUsersByIds(List<String> userIds) async {
    final Map<String, UserModel> res = {};
    try {
      if (userIds.isEmpty) return res;
      final snaps = await Future.wait(
        userIds.map((id) => _firestore.collection('users').doc(id).get()),
      );
      for (final d in snaps) {
        if (d.exists) {
          final data = d.data() as Map<String, dynamic>;
          final user = UserModel.fromMap(data);
          res[user.id] = user;
        }
      }
    } catch (e) {
      print('Error getUsersByIds: $e');
    }
    return res;
  }

  Future<List<DataCollectionModel>> getRecentDataCollections({
    int limit = 20,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection('data_collections')
              .orderBy('date', descending: true)
              .limit(limit)
              .get();
      return snapshot.docs
          .map((doc) => DataCollectionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getRecentDataCollections: $e');
      return [];
    }
  }

  // ================= Essences (global collection) =================
  static const List<String> defaultEssences = <String>[
    'Azobé (Lophira alata)',
    'Iroko (Milicia excelsa)',
  ];

  Future<void> seedDefaultEssences() async {
    try {
      final existing = await getEssences();
      final toAdd =
          defaultEssences.where((e) => !existing.contains(e)).toList();
      for (final name in toAdd) {
        await addEssence(name);
      }
    } catch (_) {
      // ignore seeding errors
    }
  }

  Future<void> addEssence(String name) async {
    try {
      final docRef = _firestore.collection('essences').doc();
      await docRef.set({
        'id': docRef.id,
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding essence: $e');
      rethrow;
    }
  }

  Future<List<String>> getEssences() async {
    try {
      final snapshot =
          await _firestore.collection('essences').orderBy('name').get();
      return snapshot.docs
          .map((d) => (d.data()['name'] ?? '').toString())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error getting essences: $e');
      return [];
    }
  }

  Stream<List<String>> streamEssences() {
    return _firestore
        .collection('essences')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((d) => (d.data()['name'] ?? '').toString())
                  .where((e) => e.isNotEmpty)
                  .toList(),
        );
  }

  // ================= Data Collections =================
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

  Future<void> updateDataCollection(DataCollectionModel data) async {
    try {
      await _firestore
          .collection('data_collections')
          .doc(data.id)
          .update(data.toMap());
    } catch (e) {
      print('Error updating data collection: $e');
      rethrow;
    }
  }

  Future<void> markChantierAlert({
    required String chantierId,
    required String level, // 'Faible' | 'Moyenne' | 'Élevée'
    required String reason,
  }) async {
    try {
      await _firestore.collection('data_collections').doc(chantierId).update({
        'isAlert': true,
        'alertLevel': level,
        'alertReason': reason,
        'alertCreatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error markChantierAlert: $e');
      rethrow;
    }
  }

  Future<void> clearChantierAlert(String chantierId) async {
    try {
      await _firestore.collection('data_collections').doc(chantierId).update({
        'isAlert': false,
        'alertLevel': '',
        'alertReason': '',
        'alertCreatedAt': null,
      });
    } catch (e) {
      print('Error clearChantierAlert: $e');
      rethrow;
    }
  }

  Future<int> countAlertsForUser(String userId) async {
    try {
      final q =
          await _firestore
              .collection('data_collections')
              .where('userId', isEqualTo: userId)
              .where('isAlert', isEqualTo: true)
              .get();
      return q.docs.length;
    } catch (e) {
      print('Error countAlertsForUser: $e');
      return 0;
    }
  }

  Stream<int> streamAlertsForUser(String userId) {
    return _firestore
        .collection('data_collections')
        .where('userId', isEqualTo: userId)
        .where('isAlert', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Future<void> deleteDataCollection(String chantierId) async {
    try {
      await _firestore.collection('data_collections').doc(chantierId).delete();
    } catch (e) {
      print('Error deleting data collection: $e');
      rethrow;
    }
  }

  Future<void> saveBackupRecord({
    required String userId,
    required String downloadUrl,
  }) async {
    try {
      final String id = _uuid.v4();
      final backup = BackupModel(
        id: id,
        userId: userId,
        fichier: downloadUrl,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('backups').doc(id).set(backup.toMap());
    } catch (e) {
      print('Error saving backup record: $e');
      rethrow;
    }
  }

  Future<void> addMaterielNecessaire({
    required String chantierId,
    required String name,
    required num qty,
    String unit = 'pcs',
  }) async {
    try {
      await _firestore.collection('data_collections').doc(chantierId).update({
        'materielsNecessaires': FieldValue.arrayUnion([
          {
            'name': name,
            'qty': qty,
            'unit': unit,
            'addedAt': DateTime.now().toIso8601String(),
          },
        ]),
      });
    } catch (e) {
      print('Error adding materiel necessaire: $e');
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

  Stream<List<DataCollectionModel>> streamDataCollectionsByUser(String userId) {
    return _firestore
        .collection('data_collections')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DataCollectionModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  Stream<DataCollectionModel?> streamDataCollectionById(String id) {
    return _firestore.collection('data_collections').doc(id).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return DataCollectionModel.fromMap(doc.data()!);
    });
  }

  // ================= Backups =================
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

  // ================= Notifications =================
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

  // ================= History =================
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

  // ================= Dashboard =================
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

  Future<void> addTraceNotification({
    required String toUserId,
    required String email,
    required String title,
    required String message,
  }) async {
    try {
      final id = _uuid.v4();
      await _firestore.collection('notifications').doc(id).set({
        'id': id,
        'userId': toUserId,
        'email': email,
        'title': title,
        'message': message,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error addTraceNotification: $e');
    }
  }

  Future<void> notifyAllUsers({
    required String title,
    required String message,
  }) async {
    try {
      final snaps = await _firestore.collection('users').get();
      final futures = <Future>[];
      for (final d in snaps.docs) {
        final data = d.data();
        final String toUserId = data['id'] ?? d.id;
        final String email = data['email'] ?? '';
        futures.add(
          addTraceNotification(
            toUserId: toUserId,
            email: email,
            title: title,
            message: message,
          ),
        );
      }
      await Future.wait(futures);
    } catch (e) {
      print('Error notifyAllUsers: $e');
    }
  }

  // Méthodes manquantes pour les nouveaux services
  Future<List<DataCollectionModel>> getAllDataCollections() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('data_collections')
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs
          .map(
            (doc) =>
                DataCollectionModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error getting all data collections: $e');
      return [];
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .orderBy('dateJoined', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }
}
