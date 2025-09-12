import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mission_model.dart';

class MissionService {
  static const String _collection = 'missions';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Créer une nouvelle mission
  Future<MissionModel> createMission({
    required String title,
    required String description,
    required String assignedUserId,
    required String assignedUserName,
    required String zone,
    String priority = 'medium',
    DateTime? dueDate,
    List<String> requiredMaterials = const [],
    Map<String, dynamic> instructions = const {},
  }) async {
    final missionId = _firestore.collection(_collection).doc().id;

    final mission = MissionModel(
      id: missionId,
      title: title,
      description: description,
      assignedUserId: assignedUserId,
      assignedUserName: assignedUserName,
      zone: zone,
      priority: priority,
      dueDate: dueDate,
      requiredMaterials: requiredMaterials,
      instructions: instructions,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(_collection)
        .doc(missionId)
        .set(mission.toMap());

    return mission;
  }

  /// Récupérer une mission par ID
  Future<MissionModel?> getMission(String missionId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(missionId).get();

      if (doc.exists) {
        return MissionModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error getting mission: $e');
    }
    return null;
  }

  /// Récupérer toutes les missions d'un utilisateur
  Future<List<MissionModel>> getUserMissions(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('assignedUserId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => MissionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user missions: $e');
      return [];
    }
  }

  /// Récupérer les missions en cours d'un utilisateur
  Future<List<MissionModel>> getUserActiveMissions(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('assignedUserId', isEqualTo: userId)
              .where('status', whereIn: ['pending', 'in_progress'])
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => MissionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user active missions: $e');
      return [];
    }
  }

  /// Récupérer toutes les missions (pour superviseurs et admins)
  Future<List<MissionModel>> getAllMissions() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => MissionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all missions: $e');
      return [];
    }
  }

  /// Mettre à jour le statut d'une mission
  Future<void> updateMissionStatus(
    String missionId,
    String status, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final updateData = <String, dynamic>{'status': status};

      if (startDate != null) {
        updateData['startDate'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        updateData['endDate'] = endDate.toIso8601String();
      }

      await _firestore
          .collection(_collection)
          .doc(missionId)
          .update(updateData);
    } catch (e) {
      print('Error updating mission status: $e');
      rethrow;
    }
  }

  /// Assigner une mission à un utilisateur
  Future<void> assignMission(
    String missionId,
    String userId,
    String userName,
  ) async {
    try {
      await _firestore.collection(_collection).doc(missionId).update({
        'assignedUserId': userId,
        'assignedUserName': userName,
      });
    } catch (e) {
      print('Error assigning mission: $e');
      rethrow;
    }
  }

  /// Mettre à jour une mission
  Future<void> updateMission(
    String missionId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(missionId)
          .update(updateData);
    } catch (e) {
      print('Error updating mission: $e');
      rethrow;
    }
  }

  /// Supprimer une mission
  Future<void> deleteMission(String missionId) async {
    try {
      await _firestore.collection(_collection).doc(missionId).delete();
    } catch (e) {
      print('Error deleting mission: $e');
      rethrow;
    }
  }

  /// Récupérer les missions par zone
  Future<List<MissionModel>> getMissionsByZone(String zone) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('zone', isEqualTo: zone)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => MissionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting missions by zone: $e');
      return [];
    }
  }

  /// Récupérer les missions par priorité
  Future<List<MissionModel>> getMissionsByPriority(String priority) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('priority', isEqualTo: priority)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => MissionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting missions by priority: $e');
      return [];
    }
  }

  /// Récupérer les missions en retard
  Future<List<MissionModel>> getOverdueMissions() async {
    try {
      final now = DateTime.now();
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('dueDate', isLessThan: now.toIso8601String())
              .where('status', whereIn: ['pending', 'in_progress'])
              .orderBy('dueDate', descending: false)
              .get();

      return querySnapshot.docs
          .map((doc) => MissionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting overdue missions: $e');
      return [];
    }
  }

  /// Stream des missions d'un utilisateur
  Stream<List<MissionModel>> streamUserMissions(String userId) {
    return _firestore
        .collection(_collection)
        .where('assignedUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MissionModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  /// Stream de toutes les missions
  Stream<List<MissionModel>> streamAllMissions() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MissionModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  /// Obtenir les statistiques des missions
  Future<Map<String, int>> getMissionStats(String? userId) async {
    try {
      Query query = _firestore.collection(_collection);

      if (userId != null) {
        query = query.where('assignedUserId', isEqualTo: userId);
      }

      final querySnapshot = await query.get();
      final missions =
          querySnapshot.docs
              .map(
                (doc) =>
                    MissionModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

      return {
        'total': missions.length,
        'pending': missions.where((m) => m.isPending).length,
        'in_progress': missions.where((m) => m.isInProgress).length,
        'completed': missions.where((m) => m.isCompleted).length,
        'cancelled': missions.where((m) => m.isCancelled).length,
        'overdue': missions.where((m) => m.isOverdue).length,
      };
    } catch (e) {
      print('Error getting mission stats: $e');
      return {};
    }
  }
}
