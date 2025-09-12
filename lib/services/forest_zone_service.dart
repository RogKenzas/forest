import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forest_zone_model.dart';

class ForestZoneService {
  static const String _collection = 'forest_zones';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Créer une nouvelle zone forestière
  Future<ForestZoneModel> createForestZone({
    required String name,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required double area,
    String status = 'active',
    String assignedSupervisorId = '',
    List<String> assignedAgentIds = const [],
    Map<String, dynamic> characteristics = const {},
    List<String> accessPoints = const [],
    Map<String, dynamic> restrictions = const {},
    String imageUrl = '',
  }) async {
    final zoneId = _firestore.collection(_collection).doc().id;

    final zone = ForestZoneModel(
      id: zoneId,
      name: name,
      description: description,
      location: location,
      latitude: latitude,
      longitude: longitude,
      area: area,
      status: status,
      assignedSupervisorId: assignedSupervisorId,
      assignedAgentIds: assignedAgentIds,
      characteristics: characteristics,
      accessPoints: accessPoints,
      restrictions: restrictions,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    await _firestore.collection(_collection).doc(zoneId).set(zone.toMap());

    return zone;
  }

  /// Récupérer une zone forestière par ID
  Future<ForestZoneModel?> getForestZone(String zoneId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(zoneId).get();

      if (doc.exists) {
        return ForestZoneModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error getting forest zone: $e');
    }
    return null;
  }

  /// Récupérer toutes les zones forestières
  Future<List<ForestZoneModel>> getAllForestZones() async {
    try {
      final querySnapshot =
          await _firestore.collection(_collection).orderBy('name').get();

      return querySnapshot.docs
          .map((doc) => ForestZoneModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all forest zones: $e');
      return [];
    }
  }

  /// Récupérer les zones forestières actives
  Future<List<ForestZoneModel>> getActiveForestZones() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('status', isEqualTo: 'active')
              .orderBy('name')
              .get();

      return querySnapshot.docs
          .map((doc) => ForestZoneModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting active forest zones: $e');
      return [];
    }
  }

  /// Récupérer les zones assignées à un superviseur
  Future<List<ForestZoneModel>> getZonesBySupervisor(
    String supervisorId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('assignedSupervisorId', isEqualTo: supervisorId)
              .orderBy('name')
              .get();

      return querySnapshot.docs
          .map((doc) => ForestZoneModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting zones by supervisor: $e');
      return [];
    }
  }

  /// Récupérer les zones assignées à un agent
  Future<List<ForestZoneModel>> getZonesByAgent(String agentId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('assignedAgentIds', arrayContains: agentId)
              .orderBy('name')
              .get();

      return querySnapshot.docs
          .map((doc) => ForestZoneModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting zones by agent: $e');
      return [];
    }
  }

  /// Mettre à jour une zone forestière
  Future<void> updateForestZone(
    String zoneId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      await _firestore.collection(_collection).doc(zoneId).update(updateData);
    } catch (e) {
      print('Error updating forest zone: $e');
      rethrow;
    }
  }

  /// Assigner un superviseur à une zone
  Future<void> assignSupervisorToZone(
    String zoneId,
    String supervisorId,
  ) async {
    try {
      await _firestore.collection(_collection).doc(zoneId).update({
        'assignedSupervisorId': supervisorId,
      });
    } catch (e) {
      print('Error assigning supervisor to zone: $e');
      rethrow;
    }
  }

  /// Assigner des agents à une zone
  Future<void> assignAgentsToZone(String zoneId, List<String> agentIds) async {
    try {
      await _firestore.collection(_collection).doc(zoneId).update({
        'assignedAgentIds': agentIds,
      });
    } catch (e) {
      print('Error assigning agents to zone: $e');
      rethrow;
    }
  }

  /// Ajouter un agent à une zone
  Future<void> addAgentToZone(String zoneId, String agentId) async {
    try {
      await _firestore.collection(_collection).doc(zoneId).update({
        'assignedAgentIds': FieldValue.arrayUnion([agentId]),
      });
    } catch (e) {
      print('Error adding agent to zone: $e');
      rethrow;
    }
  }

  /// Retirer un agent d'une zone
  Future<void> removeAgentFromZone(String zoneId, String agentId) async {
    try {
      await _firestore.collection(_collection).doc(zoneId).update({
        'assignedAgentIds': FieldValue.arrayRemove([agentId]),
      });
    } catch (e) {
      print('Error removing agent from zone: $e');
      rethrow;
    }
  }

  /// Mettre à jour le statut d'une zone
  Future<void> updateZoneStatus(String zoneId, String status) async {
    try {
      await _firestore.collection(_collection).doc(zoneId).update({
        'status': status,
      });
    } catch (e) {
      print('Error updating zone status: $e');
      rethrow;
    }
  }

  /// Mettre à jour la dernière inspection d'une zone
  Future<void> updateLastInspection(
    String zoneId,
    DateTime inspectionDate,
  ) async {
    try {
      await _firestore.collection(_collection).doc(zoneId).update({
        'lastInspection': inspectionDate.toIso8601String(),
      });
    } catch (e) {
      print('Error updating last inspection: $e');
      rethrow;
    }
  }

  /// Supprimer une zone forestière
  Future<void> deleteForestZone(String zoneId) async {
    try {
      await _firestore.collection(_collection).doc(zoneId).delete();
    } catch (e) {
      print('Error deleting forest zone: $e');
      rethrow;
    }
  }

  /// Rechercher des zones par nom ou localisation
  Future<List<ForestZoneModel>> searchZones(String query) async {
    try {
      final querySnapshot =
          await _firestore.collection(_collection).orderBy('name').get();

      final allZones =
          querySnapshot.docs
              .map((doc) => ForestZoneModel.fromMap(doc.data()))
              .toList();

      final lowerQuery = query.toLowerCase();
      return allZones
          .where(
            (zone) =>
                zone.name.toLowerCase().contains(lowerQuery) ||
                zone.location.toLowerCase().contains(lowerQuery) ||
                zone.description.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      print('Error searching zones: $e');
      return [];
    }
  }

  /// Stream de toutes les zones forestières
  Stream<List<ForestZoneModel>> streamAllForestZones() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ForestZoneModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  /// Stream des zones actives
  Stream<List<ForestZoneModel>> streamActiveForestZones() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'active')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ForestZoneModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  /// Obtenir les statistiques des zones forestières
  Future<Map<String, dynamic>> getZoneStats() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();

      final zones =
          querySnapshot.docs
              .map((doc) => ForestZoneModel.fromMap(doc.data()))
              .toList();

      final totalArea = zones.fold<double>(0, (sum, zone) => sum + zone.area);
      final activeZones = zones.where((z) => z.isActive).length;
      final zonesWithSupervisor =
          zones.where((z) => z.hasAssignedSupervisor).length;
      final zonesWithAgents = zones.where((z) => z.hasAssignedAgents).length;

      return {
        'totalZones': zones.length,
        'activeZones': activeZones,
        'inactiveZones': zones.length - activeZones,
        'totalArea': totalArea,
        'zonesWithSupervisor': zonesWithSupervisor,
        'zonesWithAgents': zonesWithAgents,
        'averageArea': zones.isNotEmpty ? totalArea / zones.length : 0.0,
      };
    } catch (e) {
      print('Error getting zone stats: $e');
      return {};
    }
  }
}
