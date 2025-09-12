import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:csv/csv.dart'; // Temporairement commenté
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../constants/app_constants.dart';
import '../components/custom_card.dart';
import '../components/custom_button.dart';
import '../components/custom_dropdown.dart';
import '../models/data_collection_model.dart';
import '../models/analysis_report_model.dart';
import '../services/firestore_service.dart';
import '../services/analysis_service.dart';
import '../services/navigation_helper.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AnalysisService _analysisService = AnalysisService();

  bool _isLoading = true;
  bool _isExporting = false;

  // Données
  List<DataCollectionModel> _dataCollections = [];
  List<AnalysisReportModel> _reports = [];

  // Filtres
  String _selectedExportType = 'data_collection';
  String _selectedFormat = 'csv';
  String _selectedDateRange = 'all';
  String _selectedZone = 'all';
  String _selectedEssence = 'all';

  // Options
  final List<String> _exportTypes = [
    'data_collection',
    'analysis_reports',
    'both',
  ];

  final List<String> _formats = ['csv', 'json', 'excel'];

  final List<String> _dateRanges = [
    'all',
    'last_week',
    'last_month',
    'last_quarter',
    'custom',
  ];

  List<String> _zones = ['all'];
  List<String> _essences = ['all'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final dataCollections = await _firestoreService.getAllDataCollections();
      final reports = await _analysisService.getAllAnalysisReports();

      // Extraire les zones et essences uniques
      final uniqueZones =
          dataCollections.map((d) => d.chantier).toSet().toList();
      final uniqueEssences =
          dataCollections.map((d) => d.essence).toSet().toList();

      setState(() {
        _dataCollections = dataCollections;
        _reports = reports;
        _zones = ['all', ...uniqueZones];
        _essences = ['all', ...uniqueEssences];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<DataCollectionModel> _getFilteredDataCollections() {
    var filtered = _dataCollections;

    // Filtre par date
    if (_selectedDateRange != 'all') {
      final now = DateTime.now();
      DateTime startDate;

      switch (_selectedDateRange) {
        case 'last_week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'last_month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'last_quarter':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        default:
          startDate = DateTime(2000); // Très ancienne date
      }

      filtered = filtered.where((d) => d.date.isAfter(startDate)).toList();
    }

    // Filtre par zone
    if (_selectedZone != 'all') {
      filtered = filtered.where((d) => d.chantier == _selectedZone).toList();
    }

    // Filtre par essence
    if (_selectedEssence != 'all') {
      filtered = filtered.where((d) => d.essence == _selectedEssence).toList();
    }

    return filtered;
  }

  List<AnalysisReportModel> _getFilteredReports() {
    var filtered = _reports;

    // Filtre par date
    if (_selectedDateRange != 'all') {
      final now = DateTime.now();
      DateTime startDate;

      switch (_selectedDateRange) {
        case 'last_week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'last_month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'last_quarter':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        default:
          startDate = DateTime(2000);
      }

      filtered = filtered.where((r) => r.createdAt.isAfter(startDate)).toList();
    }

    return filtered;
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);

    try {
      final filteredData = _getFilteredDataCollections();
      final filteredReports = _getFilteredReports();

      if (filteredData.isEmpty && filteredReports.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune donnée à exporter'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      String fileName;

      switch (_selectedFormat) {
        case 'csv':
          fileName = await _exportToCsv(filteredData, filteredReports);
          break;
        case 'json':
          fileName = await _exportToJson(filteredData, filteredReports);
          break;
        case 'excel':
          fileName = await _exportToExcel(filteredData, filteredReports);
          break;
        default:
          throw Exception('Format non supporté');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export réussi: $fileName'),
            backgroundColor: AppConstants.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<String> _exportToCsv(
    List<DataCollectionModel> data,
    List<AnalysisReportModel> reports,
  ) async {
    final List<List<dynamic>> csvData = [];

    if (_selectedExportType == 'data_collection' ||
        _selectedExportType == 'both') {
      // En-têtes pour les données de collecte
      csvData.add([
        'ID',
        'Date',
        'Essence',
        'Diamètre',
        'Zone',
        'UFE',
        'ACC',
        'Bloc',
        'Numéro Prospection',
        'Code Prospection',
        'Qualité',
        'Observation',
        'Utilisateur',
        'Alerte',
        'Niveau Alerte',
        'Raison Alerte',
      ]);

      // Données de collecte
      for (final item in data) {
        csvData.add([
          item.id,
          item.date.toIso8601String(),
          item.essence,
          item.diametre,
          item.chantier,
          item.ufe,
          item.acc,
          item.bloc,
          item.numeroProspe,
          item.codeProspe,
          item.qualite,
          item.observation,
          item.userId,
          item.isAlert ? 'Oui' : 'Non',
          item.alertLevel,
          item.alertReason,
        ]);
      }
    }

    if (_selectedExportType == 'analysis_reports' ||
        _selectedExportType == 'both') {
      if (csvData.isNotEmpty) {
        csvData.add([]); // Ligne vide pour séparer
      }

      // En-têtes pour les rapports
      csvData.add([
        'ID Rapport',
        'Titre',
        'Description',
        'Type',
        'Statut',
        'Créé par',
        'Date création',
        'Résumé',
      ]);

      // Données des rapports
      for (final report in reports) {
        csvData.add([
          report.id,
          report.title,
          report.description,
          report.reportType,
          report.status,
          report.createdByUserName,
          report.createdAt.toIso8601String(),
          report.summary,
        ]);
      }
    }

    // Convertir en CSV manuellement (en attendant le package csv)
    final csvString = csvData
        .map(
          (row) => row
              .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
              .join(','),
        )
        .join('\n');
    final fileName =
        'export_${_selectedExportType}_${DateTime.now().millisecondsSinceEpoch}.csv';

    await _saveFile(fileName, csvString);
    return fileName;
  }

  Future<String> _exportToJson(
    List<DataCollectionModel> data,
    List<AnalysisReportModel> reports,
  ) async {
    final Map<String, dynamic> jsonData = {
      'export_info': {
        'export_date': DateTime.now().toIso8601String(),
        'export_type': _selectedExportType,
        'total_records': data.length + reports.length,
        'filters': {
          'date_range': _selectedDateRange,
          'zone': _selectedZone,
          'essence': _selectedEssence,
        },
      },
    };

    if (_selectedExportType == 'data_collection' ||
        _selectedExportType == 'both') {
      jsonData['data_collections'] = data.map((d) => d.toMap()).toList();
    }

    if (_selectedExportType == 'analysis_reports' ||
        _selectedExportType == 'both') {
      jsonData['analysis_reports'] = reports.map((r) => r.toMap()).toList();
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    final fileName =
        'export_${_selectedExportType}_${DateTime.now().millisecondsSinceEpoch}.json';

    await _saveFile(fileName, jsonString);
    return fileName;
  }

  Future<String> _exportToExcel(
    List<DataCollectionModel> data,
    List<AnalysisReportModel> reports,
  ) async {
    // Pour Excel, nous allons créer un CSV avec une extension .xlsx
    // Dans une vraie implémentation, vous utiliseriez un package comme 'excel'
    final csvFileName = await _exportToCsv(data, reports);
    final excelFileName = csvFileName.replaceAll('.csv', '.xlsx');

    // Renommer le fichier
    final directory = await getApplicationDocumentsDirectory();
    final csvFile = File('${directory.path}/$csvFileName');
    final excelFile = File('${directory.path}/$excelFileName');

    if (await csvFile.exists()) {
      await csvFile.rename(excelFile.path);
    }

    return excelFileName;
  }

  Future<void> _saveFile(String fileName, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);

    // Copier dans le presse-papiers
    await Clipboard.setData(ClipboardData(text: file.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlack,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryBlack,
        elevation: 0,
        title: Text(
          'Export de Données',
          style: GoogleFonts.poppins(
            color: AppConstants.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppConstants.white),
          onPressed: () => NavigationHelper.popFade(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: AppConstants.primaryGreen,
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistiques
                    _buildStatsCard(),
                    const SizedBox(height: 20),

                    // Configuration d'export
                    _buildExportConfigCard(),
                    const SizedBox(height: 20),

                    // Filtres
                    _buildFiltersCard(),
                    const SizedBox(height: 20),

                    // Bouton d'export
                    _buildExportButton(),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatsCard() {
    final filteredData = _getFilteredDataCollections();
    final filteredReports = _getFilteredReports();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques d\'Export',
            style: GoogleFonts.poppins(
              color: AppConstants.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Données',
                  '${filteredData.length}',
                  CupertinoIcons.cube_box,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Rapports',
                  '${filteredReports.length}',
                  CupertinoIcons.doc_chart,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Total',
                  '${filteredData.length + filteredReports.length}',
                  CupertinoIcons.chart_bar,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: AppConstants.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppConstants.textGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildExportConfigCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuration d\'Export',
            style: GoogleFonts.poppins(
              color: AppConstants.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          CustomDropdown(
            value: _selectedExportType,
            items: _exportTypes,
            onChanged: (value) {
              setState(() {
                _selectedExportType = value!;
              });
            },
            label: 'Type de données',
          ),
          const SizedBox(height: 16),

          CustomDropdown(
            value: _selectedFormat,
            items: _formats,
            onChanged: (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
            label: 'Format d\'export',
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtres',
            style: GoogleFonts.poppins(
              color: AppConstants.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          CustomDropdown(
            value: _selectedDateRange,
            items: _dateRanges,
            onChanged: (value) {
              setState(() {
                _selectedDateRange = value!;
              });
            },
            label: 'Période',
          ),
          const SizedBox(height: 16),

          CustomDropdown(
            value: _selectedZone,
            items: _zones,
            onChanged: (value) {
              setState(() {
                _selectedZone = value!;
              });
            },
            label: 'Zone',
          ),
          const SizedBox(height: 16),

          CustomDropdown(
            value: _selectedEssence,
            items: _essences,
            onChanged: (value) {
              setState(() {
                _selectedEssence = value!;
              });
            },
            label: 'Essence',
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return CustomButton(
      text: _isExporting ? 'Export en cours...' : 'Exporter les Données',
      onPressed: _isExporting ? null : _exportData,
    );
  }
}
