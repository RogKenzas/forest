import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analysis_report_model.dart';
import '../models/data_collection_model.dart';

class AnalysisService {
  static const String _collection = 'analysis_reports';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Créer un nouveau rapport d'analyse
  Future<AnalysisReportModel> createAnalysisReport({
    required String title,
    required String description,
    required String createdByUserId,
    required String createdByUserName,
    required String reportType,
    List<String> dataSourceIds = const [],
    Map<String, dynamic> analysisData = const {},
    List<String> charts = const [],
    String summary = '',
    Map<String, dynamic> recommendations = const {},
  }) async {
    final reportId = _firestore.collection(_collection).doc().id;

    final report = AnalysisReportModel(
      id: reportId,
      title: title,
      description: description,
      createdByUserId: createdByUserId,
      createdByUserName: createdByUserName,
      reportType: reportType,
      dataSourceIds: dataSourceIds,
      analysisData: analysisData,
      charts: charts,
      summary: summary,
      recommendations: recommendations,
      createdAt: DateTime.now(),
    );

    await _firestore.collection(_collection).doc(reportId).set(report.toMap());

    return report;
  }

  /// Récupérer un rapport d'analyse par ID
  Future<AnalysisReportModel?> getAnalysisReport(String reportId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(reportId).get();

      if (doc.exists) {
        return AnalysisReportModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error getting analysis report: $e');
    }
    return null;
  }

  /// Récupérer tous les rapports d'analyse
  Future<List<AnalysisReportModel>> getAllAnalysisReports() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => AnalysisReportModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all analysis reports: $e');
      return [];
    }
  }

  /// Récupérer les rapports d'analyse d'un utilisateur
  Future<List<AnalysisReportModel>> getUserAnalysisReports(
    String userId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('createdByUserId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => AnalysisReportModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user analysis reports: $e');
      return [];
    }
  }

  /// Récupérer les rapports par type
  Future<List<AnalysisReportModel>> getReportsByType(String reportType) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('reportType', isEqualTo: reportType)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => AnalysisReportModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting reports by type: $e');
      return [];
    }
  }

  /// Mettre à jour un rapport d'analyse
  Future<void> updateAnalysisReport(
    String reportId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      updateData['lastModified'] = DateTime.now().toIso8601String();

      await _firestore.collection(_collection).doc(reportId).update(updateData);
    } catch (e) {
      print('Error updating analysis report: $e');
      rethrow;
    }
  }

  /// Supprimer un rapport d'analyse
  Future<void> deleteAnalysisReport(String reportId) async {
    try {
      await _firestore.collection(_collection).doc(reportId).delete();
    } catch (e) {
      print('Error deleting analysis report: $e');
      rethrow;
    }
  }

  /// Analyser les données de collecte
  Future<Map<String, dynamic>> analyzeDataCollection(
    List<DataCollectionModel> dataCollections,
  ) async {
    try {
      if (dataCollections.isEmpty) {
        return {'totalRecords': 0, 'message': 'Aucune donnée à analyser'};
      }

      // Statistiques de base
      final totalRecords = dataCollections.length;
      final uniqueEssences =
          dataCollections.map((d) => d.essence).toSet().length;
      final uniqueZones = dataCollections.map((d) => d.chantier).toSet().length;

      // Calcul des diamètres moyens par essence
      final essenceStats = <String, Map<String, dynamic>>{};
      for (final data in dataCollections) {
        if (!essenceStats.containsKey(data.essence)) {
          essenceStats[data.essence] = {
            'count': 0,
            'totalDiameter': 0,
            'avgDiameter': 0.0,
            'minDiameter': double.infinity,
            'maxDiameter': 0.0,
          };
        }

        final stats = essenceStats[data.essence]!;
        stats['count'] = (stats['count'] as int) + 1;
        stats['totalDiameter'] =
            (stats['totalDiameter'] as int) + data.diametre;
        stats['minDiameter'] =
            (stats['minDiameter'] as double) < data.diametre
                ? stats['minDiameter']
                : data.diametre.toDouble();
        stats['maxDiameter'] =
            (stats['maxDiameter'] as double) > data.diametre
                ? stats['maxDiameter']
                : data.diametre.toDouble();
      }

      // Calcul des moyennes
      for (final essence in essenceStats.keys) {
        final stats = essenceStats[essence]!;
        stats['avgDiameter'] =
            (stats['totalDiameter'] as int) / (stats['count'] as int);
      }

      // Statistiques par zone
      final zoneStats = <String, int>{};
      for (final data in dataCollections) {
        zoneStats[data.chantier] = (zoneStats[data.chantier] ?? 0) + 1;
      }

      // Alertes
      final alerts = dataCollections.where((d) => d.isAlert).length;
      final alertLevels = <String, int>{};
      for (final data in dataCollections) {
        if (data.isAlert && data.alertLevel.isNotEmpty) {
          alertLevels[data.alertLevel] =
              (alertLevels[data.alertLevel] ?? 0) + 1;
        }
      }

      return {
        'totalRecords': totalRecords,
        'uniqueEssences': uniqueEssences,
        'uniqueZones': uniqueZones,
        'essenceStats': essenceStats,
        'zoneStats': zoneStats,
        'alerts': {'total': alerts, 'levels': alertLevels},
        'analysisDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error analyzing data collection: $e');
      return {'error': 'Erreur lors de l\'analyse: $e'};
    }
  }

  /// Générer un rapport de tendances
  Future<Map<String, dynamic>> generateTrendReport(
    List<DataCollectionModel> dataCollections,
  ) async {
    try {
      if (dataCollections.isEmpty) {
        return {
          'message': 'Aucune donnée pour générer le rapport de tendances',
        };
      }

      // Grouper par mois
      final monthlyData = <String, List<DataCollectionModel>>{};
      for (final data in dataCollections) {
        final monthKey =
            '${data.date.year}-${data.date.month.toString().padLeft(2, '0')}';
        monthlyData[monthKey] = monthlyData[monthKey] ?? [];
        monthlyData[monthKey]!.add(data);
      }

      // Calculer les tendances
      final trends = <String, dynamic>{};
      for (final month in monthlyData.keys.toList()..sort()) {
        final monthData = monthlyData[month]!;
        trends[month] = {
          'count': monthData.length,
          'uniqueEssences': monthData.map((d) => d.essence).toSet().length,
          'avgDiameter':
              monthData.map((d) => d.diametre).reduce((a, b) => a + b) /
              monthData.length,
          'alerts': monthData.where((d) => d.isAlert).length,
        };
      }

      return {
        'trends': trends,
        'period': {
          'start': monthlyData.keys.isNotEmpty ? monthlyData.keys.first : null,
          'end': monthlyData.keys.isNotEmpty ? monthlyData.keys.last : null,
        },
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error generating trend report: $e');
      return {
        'error': 'Erreur lors de la génération du rapport de tendances: $e',
      };
    }
  }

  /// Stream de tous les rapports d'analyse
  Stream<List<AnalysisReportModel>> streamAllAnalysisReports() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AnalysisReportModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  /// Stream des rapports d'un utilisateur
  Stream<List<AnalysisReportModel>> streamUserAnalysisReports(String userId) {
    return _firestore
        .collection(_collection)
        .where('createdByUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AnalysisReportModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  /// Obtenir les statistiques des rapports
  Future<Map<String, dynamic>> getReportStats() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();

      final reports =
          querySnapshot.docs
              .map((doc) => AnalysisReportModel.fromMap(doc.data()))
              .toList();

      return {
        'total': reports.length,
        'draft': reports.where((r) => r.isDraft).length,
        'published': reports.where((r) => r.isPublished).length,
        'byType': {
          'inventory': reports.where((r) => r.reportType == 'inventory').length,
          'data_collection':
              reports.where((r) => r.reportType == 'data_collection').length,
          'performance':
              reports.where((r) => r.reportType == 'performance').length,
          'trend': reports.where((r) => r.reportType == 'trend').length,
        },
      };
    } catch (e) {
      print('Error getting report stats: $e');
      return {};
    }
  }
}
