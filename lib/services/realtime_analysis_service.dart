import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/data_collection_model.dart';
import '../models/analysis_report_model.dart';

class RealtimeAnalysisService {
  static const String _dataCollection = 'data_collections';
  static const String _analysisReports = 'analysis_reports';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Streams pour l'analyse en temps réel
  Stream<List<DataCollectionModel>> getDataCollectionsStream() {
    return _firestore
        .collection(_dataCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DataCollectionModel.fromMap(doc.data()))
            .toList());
  }
  
  Stream<List<AnalysisReportModel>> getAnalysisReportsStream() {
    return _firestore
        .collection(_analysisReports)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnalysisReportModel.fromMap(doc.data()))
            .toList());
  }
  
  // Analyse en temps réel des données
  Stream<Map<String, dynamic>> getRealtimeAnalysis() {
    return getDataCollectionsStream().map((dataCollections) {
      if (dataCollections.isEmpty) {
        return {
          'totalRecords': 0,
          'message': 'Aucune donnée disponible',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
      
      // Statistiques générales
      final totalRecords = dataCollections.length;
      final uniqueEssences = dataCollections.map((d) => d.essence).toSet().length;
      final uniqueZones = dataCollections.map((d) => d.chantier).toSet().length;
      
      // Analyse par essence
      final essenceAnalysis = <String, Map<String, dynamic>>{};
      for (final data in dataCollections) {
        if (!essenceAnalysis.containsKey(data.essence)) {
          essenceAnalysis[data.essence] = {
            'count': 0,
            'totalDiameter': 0,
            'avgDiameter': 0.0,
            'minDiameter': double.infinity,
            'maxDiameter': 0.0,
            'zones': <String>{},
            'alerts': 0,
          };
        }
        
        final analysis = essenceAnalysis[data.essence]!;
        analysis['count'] = (analysis['count'] as int) + 1;
        analysis['totalDiameter'] = (analysis['totalDiameter'] as int) + data.diametre;
        analysis['minDiameter'] = (analysis['minDiameter'] as double) < data.diametre
            ? analysis['minDiameter']
            : data.diametre.toDouble();
        analysis['maxDiameter'] = (analysis['maxDiameter'] as double) > data.diametre
            ? analysis['maxDiameter']
            : data.diametre.toDouble();
        (analysis['zones'] as Set<String>).add(data.chantier);
        if (data.isAlert) {
          analysis['alerts'] = (analysis['alerts'] as int) + 1;
        }
      }
      
      // Calcul des moyennes
      for (final essence in essenceAnalysis.keys) {
        final analysis = essenceAnalysis[essence]!;
        analysis['avgDiameter'] = (analysis['totalDiameter'] as int) / (analysis['count'] as int);
      }
      
      // Analyse par zone
      final zoneAnalysis = <String, Map<String, dynamic>>{};
      for (final data in dataCollections) {
        if (!zoneAnalysis.containsKey(data.chantier)) {
          zoneAnalysis[data.chantier] = {
            'count': 0,
            'essences': <String>{},
            'totalDiameter': 0,
            'alerts': 0,
          };
        }
        
        final analysis = zoneAnalysis[data.chantier]!;
        analysis['count'] = (analysis['count'] as int) + 1;
        (analysis['essences'] as Set<String>).add(data.essence);
        analysis['totalDiameter'] = (analysis['totalDiameter'] as int) + data.diametre;
        if (data.isAlert) {
          analysis['alerts'] = (analysis['alerts'] as int) + 1;
        }
      }
      
      // Analyse temporelle (derniers 30 jours)
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final recentData = dataCollections.where((d) => d.date.isAfter(thirtyDaysAgo)).toList();
      
      final dailyStats = <String, int>{};
      for (final data in recentData) {
        final dayKey = '${data.date.year}-${data.date.month.toString().padLeft(2, '0')}-${data.date.day.toString().padLeft(2, '0')}';
        dailyStats[dayKey] = (dailyStats[dayKey] ?? 0) + 1;
      }
      
      // Alertes
      final totalAlerts = dataCollections.where((d) => d.isAlert).length;
      final alertLevels = <String, int>{};
      for (final data in dataCollections) {
        if (data.isAlert && data.alertLevel.isNotEmpty) {
          alertLevels[data.alertLevel] = (alertLevels[data.alertLevel] ?? 0) + 1;
        }
      }
      
      return {
        'totalRecords': totalRecords,
        'uniqueEssences': uniqueEssences,
        'uniqueZones': uniqueZones,
        'essenceAnalysis': essenceAnalysis,
        'zoneAnalysis': zoneAnalysis,
        'dailyStats': dailyStats,
        'alerts': {
          'total': totalAlerts,
          'levels': alertLevels,
          'percentage': totalRecords > 0 ? (totalAlerts / totalRecords * 100).toStringAsFixed(1) : '0.0',
        },
        'timestamp': DateTime.now().toIso8601String(),
        'lastUpdate': DateTime.now().toIso8601String(),
      };
    });
  }
  
  // Analyse comparative (évolution dans le temps)
  Stream<Map<String, dynamic>> getComparativeAnalysis() {
    return getDataCollectionsStream().map((dataCollections) {
      if (dataCollections.length < 2) {
        return {
          'message': 'Données insuffisantes pour l\'analyse comparative',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
      
      // Grouper par mois
      final monthlyData = <String, List<DataCollectionModel>>{};
      for (final data in dataCollections) {
        final monthKey = '${data.date.year}-${data.date.month.toString().padLeft(2, '0')}';
        monthlyData[monthKey] = monthlyData[monthKey] ?? [];
        monthlyData[monthKey]!.add(data);
      }
      
      // Calculer les tendances
      final trends = <String, dynamic>{};
      for (final month in monthlyData.keys.toList()..sort()) {
        final monthData = monthlyData[month]!;
        final avgDiameter = monthData.map((d) => d.diametre).reduce((a, b) => a + b) / monthData.length;
        final alerts = monthData.where((d) => d.isAlert).length;
        
        trends[month] = {
          'count': monthData.length,
          'uniqueEssences': monthData.map((d) => d.essence).toSet().length,
          'avgDiameter': avgDiameter,
          'alerts': alerts,
          'alertPercentage': monthData.isNotEmpty ? (alerts / monthData.length * 100).toStringAsFixed(1) : '0.0',
        };
      }
      
      // Calculer les variations
      final months = trends.keys.toList()..sort();
      final variations = <String, dynamic>{};
      
      if (months.length >= 2) {
        final lastMonth = trends[months.last]!;
        final previousMonth = trends[months[months.length - 2]]!;
        
        variations['count'] = _calculateVariation(
          lastMonth['count'] as int,
          previousMonth['count'] as int,
        );
        variations['avgDiameter'] = _calculateVariation(
          lastMonth['avgDiameter'] as double,
          previousMonth['avgDiameter'] as double,
        );
        variations['alerts'] = _calculateVariation(
          lastMonth['alerts'] as int,
          previousMonth['alerts'] as int,
        );
      }
      
      return {
        'trends': trends,
        'variations': variations,
        'period': {
          'start': months.isNotEmpty ? months.first : null,
          'end': months.isNotEmpty ? months.last : null,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
    });
  }
  
  double _calculateVariation(dynamic current, dynamic previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous * 100);
  }
  
  // Obtenir les données pour les graphiques
  Map<String, dynamic> getChartData(Map<String, dynamic> analysis) {
    final essenceAnalysis = analysis['essenceAnalysis'] as Map<String, dynamic>? ?? {};
    final zoneAnalysis = analysis['zoneAnalysis'] as Map<String, dynamic>? ?? {};
    final dailyStats = analysis['dailyStats'] as Map<String, int>? ?? {};
    
    // Données pour graphique en barres (essences)
    final essenceChartData = essenceAnalysis.entries.map((entry) {
      final data = entry.value as Map<String, dynamic>;
      return {
        'name': entry.key,
        'count': data['count'] as int,
        'avgDiameter': data['avgDiameter'] as double,
        'alerts': data['alerts'] as int,
      };
    }).toList();
    
    // Données pour graphique en secteurs (zones)
    final zoneChartData = zoneAnalysis.entries.map((entry) {
      final data = entry.value as Map<String, dynamic>;
      return {
        'name': entry.key,
        'count': data['count'] as int,
        'essences': (data['essences'] as Set<String>).length,
      };
    }).toList();
    
    // Données pour graphique linéaire (évolution temporelle)
    final timelineData = dailyStats.entries.map((entry) {
      return {
        'date': entry.key,
        'count': entry.value,
      };
    }).toList();
    
    return {
      'essenceChart': essenceChartData,
      'zoneChart': zoneChartData,
      'timelineChart': timelineData,
      'summary': {
        'totalRecords': analysis['totalRecords'] ?? 0,
        'uniqueEssences': analysis['uniqueEssences'] ?? 0,
        'uniqueZones': analysis['uniqueZones'] ?? 0,
        'totalAlerts': analysis['alerts']?['total'] ?? 0,
        'alertPercentage': analysis['alerts']?['percentage'] ?? '0.0',
      },
    };
  }
}
