import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../components/custom_card.dart';
import '../components/custom_button.dart';
import '../components/custom_input.dart';
import '../components/custom_dropdown.dart';
import '../components/analysis_charts.dart';
import '../models/analysis_report_model.dart';
import '../models/user_model.dart';
import '../models/data_collection_model.dart';
import '../services/analysis_service.dart';
import '../services/firestore_service.dart';
import '../services/realtime_analysis_service.dart';
import '../services/professional_pdf_service.dart';

class AnalysisScreen extends StatefulWidget {
  final UserModel currentUser;

  const AnalysisScreen({super.key, required this.currentUser});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with TickerProviderStateMixin {
  final AnalysisService _analysisService = AnalysisService();
  final FirestoreService _firestoreService = FirestoreService();
  final RealtimeAnalysisService _realtimeService = RealtimeAnalysisService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  late TabController _tabController;
  List<AnalysisReportModel> _reports = [];
  List<DataCollectionModel> _dataCollections = [];
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _realtimeAnalysis = {};
  Map<String, dynamic> _chartData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
    _startRealtimeAnalysis();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Charger tous les rapports (pas seulement ceux de l'utilisateur)
      final allReports = await _analysisService.getAllAnalysisReports();
      final dataCollections = await _firestoreService.getAllDataCollections();
      final stats = await _analysisService.getReportStats();

      setState(() {
        _reports = allReports; // Utiliser tous les rapports
        _dataCollections = dataCollections;
        _stats = stats;
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

  void _startRealtimeAnalysis() {
    _realtimeService.getRealtimeAnalysis().listen((analysis) {
      if (mounted) {
        setState(() {
          _realtimeAnalysis = analysis;
          _chartData = _realtimeService.getChartData(analysis);
        });
      }
    });
  }

  Future<void> _exportToPdf(AnalysisReportModel report) async {
    try {
      final fileName =
          'rapport_${report.title.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

      await ProfessionalPdfService.exportAnalysisReport(
        report: report,
        analysisData: _realtimeAnalysis,
        chartData: _chartData,
        fileName: fileName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rapport exporté: $fileName'),
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
    }
  }

  void _showRealtimeAnalysisModal(AnalysisReportModel report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.primaryBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppConstants.textGrey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // En-tête avec titre du rapport
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analyse en temps réel',
                              style: GoogleFonts.poppins(
                                color: AppConstants.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              report.title,
                              style: GoogleFonts.poppins(
                                color: AppConstants.primaryGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          CupertinoIcons.xmark,
                          color: AppConstants.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Cartes de résumé
                  if (_chartData['summary'] != null)
                    AnalysisSummaryCards(summary: _chartData['summary']),
                  const SizedBox(height: 20),

                  // Graphiques
                  if (_chartData.isNotEmpty)
                    AnalysisCharts(
                      chartData: _chartData,
                      title: 'Données actuelles',
                    ),

                  const SizedBox(height: 20),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Exporter PDF',
                          onPressed: () {
                            Navigator.pop(context);
                            _exportToPdf(report);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Actualiser',
                          onPressed: () {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  void _showCreateReportDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.primaryBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: _CreateReportForm(
              currentUser: widget.currentUser,
              dataCollections: _dataCollections,
              onReportCreated: () {
                Navigator.pop(context);
                _loadData();
              },
            ),
          ),
    );
  }

  void _showReportDetails(AnalysisReportModel report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.primaryBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppConstants.textGrey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Titre
                  Text(
                    report.title,
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Statut et type
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            report.status,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _getStatusColor(report.status),
                          ),
                        ),
                        child: Text(
                          report.statusDisplayName,
                          style: GoogleFonts.poppins(
                            color: _getStatusColor(report.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryGreen.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppConstants.primaryGreen),
                        ),
                        child: Text(
                          report.reportTypeDisplayName,
                          style: GoogleFonts.poppins(
                            color: AppConstants.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    style: GoogleFonts.poppins(
                      color: AppConstants.textGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informations
                  _buildInfoRow('Créé par', report.createdByUserName),
                  _buildInfoRow(
                    'Créé le',
                    _dateFormat.format(report.createdAt),
                  ),
                  if (report.lastModified != null)
                    _buildInfoRow(
                      'Modifié le',
                      _dateFormat.format(report.lastModified!),
                    ),

                  // Résumé
                  if (report.summary.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Résumé',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.summary,
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Exporter PDF',
                          onPressed: () {
                            Navigator.pop(context);
                            _exportToPdf(report);
                          },
                          // backgroundColor: AppConstants.primaryGreen,
                        ),
                      ),
                      if (report.isDraft) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Modifier',
                            onPressed: () {
                              Navigator.pop(context);
                              // TODO: Implémenter la modification
                            },
                            // backgroundColor: AppConstants.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Publier',
                            onPressed: () {
                              Navigator.pop(context);
                              _publishReport(report);
                            },
                            // backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                color: AppConstants.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: AppConstants.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'published':
        return AppConstants.primaryGreen;
      default:
        return AppConstants.textGrey;
    }
  }

  Future<void> _publishReport(AnalysisReportModel report) async {
    try {
      await _analysisService.updateAnalysisReport(report.id, {
        'status': 'published',
      });

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Rapport publié avec succès'),
            backgroundColor: AppConstants.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlack,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryBlack,
        elevation: 0,
        title: Text(
          'Analyse des Données',
          style: GoogleFonts.poppins(
            color: AppConstants.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppConstants.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.refresh, color: AppConstants.white),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.primaryGreen,
          labelColor: AppConstants.primaryGreen,
          unselectedLabelColor: AppConstants.textGrey,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Analyse Temps Réel'),
            Tab(text: 'Tous'),
            Tab(text: 'Brouillons'),
            Tab(text: 'Publiés'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: AppConstants.primaryGreen,
                ),
              )
              : Column(
                children: [
                  // Statistiques
                  if (_stats.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppConstants.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Total', '${_stats['total'] ?? 0}'),
                          _buildStatItem(
                            'Brouillons',
                            '${_stats['draft'] ?? 0}',
                          ),
                          _buildStatItem(
                            'Publiés',
                            '${_stats['published'] ?? 0}',
                          ),
                        ],
                      ),
                    ),

                  // Contenu des onglets
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Onglet d'analyse temps réel
                        _buildRealtimeAnalysisTab(),
                        // Onglet tous les rapports
                        _buildReportsTab(_reports),
                        // Onglet brouillons
                        _buildReportsTab(
                          _reports.where((r) => r.isDraft).toList(),
                        ),
                        // Onglet publiés
                        _buildReportsTab(
                          _reports
                              .where((r) => r.status == 'published')
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateReportDialog,
        backgroundColor: AppConstants.primaryGreen,
        child: const Icon(CupertinoIcons.add, color: AppConstants.white),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
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

  Widget _buildRealtimeAnalysisTab() {
    if (_realtimeAnalysis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chart_bar,
              size: 64,
              color: AppConstants.textGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement de l\'analyse...',
              style: GoogleFonts.poppins(
                color: AppConstants.textGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cartes de résumé
          AnalysisSummaryCards(summary: _chartData['summary'] ?? {}),
          const SizedBox(height: 20),

          // Graphiques
          AnalysisCharts(chartData: _chartData, title: 'Analyse en temps réel'),
          const SizedBox(height: 20),

          // Informations de mise à jour
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.time,
                  color: AppConstants.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dernière mise à jour: ${_formatLastUpdate()}',
                  style: GoogleFonts.poppins(
                    color: AppConstants.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab(List<AnalysisReportModel> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.doc_chart,
              size: 64,
              color: AppConstants.textGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun rapport',
              style: GoogleFonts.poppins(
                color: AppConstants.textGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Instruction pour le long-press
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppConstants.primaryGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.info,
                color: AppConstants.primaryGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Maintenez appuyé sur un rapport pour voir l\'analyse en temps réel',
                  style: GoogleFonts.poppins(
                    color: AppConstants.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Liste des rapports
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildReportCard(report);
            },
          ),
        ),
      ],
    );
  }

  String _formatLastUpdate() {
    if (_realtimeAnalysis['timestamp'] != null) {
      final timestamp = DateTime.parse(_realtimeAnalysis['timestamp']);
      return DateFormat('HH:mm:ss').format(timestamp);
    }
    return '--:--:--';
  }

  Widget _buildReportCard(AnalysisReportModel report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showReportDetails(report),
        onLongPress: () => _showRealtimeAnalysisModal(report),
        child: CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.title,
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Indicateur de long-press
                  Icon(
                    CupertinoIcons.chart_bar,
                    color: AppConstants.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        report.status,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(report.status)),
                    ),
                    child: Text(
                      report.statusDisplayName,
                      style: GoogleFonts.poppins(
                        color: _getStatusColor(report.status),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: AppConstants.textGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.doc_chart,
                    color: AppConstants.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    report.reportTypeDisplayName,
                    style: GoogleFonts.poppins(
                      color: AppConstants.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    CupertinoIcons.time,
                    color: AppConstants.textGrey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _dateFormat.format(report.createdAt),
                    style: GoogleFonts.poppins(
                      color: AppConstants.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateReportForm extends StatefulWidget {
  final UserModel currentUser;
  final List<DataCollectionModel> dataCollections;
  final VoidCallback onReportCreated;

  const _CreateReportForm({
    required this.currentUser,
    required this.dataCollections,
    required this.onReportCreated,
  });

  @override
  State<_CreateReportForm> createState() => _CreateReportFormState();
}

class _CreateReportFormState extends State<_CreateReportForm> {
  final AnalysisService _analysisService = AnalysisService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _summaryController = TextEditingController();

  String _selectedReportType = 'inventory';
  List<String> _selectedDataSources = [];
  bool _isLoading = false;

  final List<String> _reportTypes = [
    'inventory',
    'data_collection',
    'performance',
    'trend',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _createReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _analysisService.createAnalysisReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdByUserId: widget.currentUser.id,
        createdByUserName: widget.currentUser.fullName,
        reportType: _selectedReportType,
        dataSourceIds: _selectedDataSources,
        summary: _summaryController.text.trim(),
      );

      widget.onReportCreated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppConstants.textGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Titre
            Text(
              'Nouveau Rapport',
              style: GoogleFonts.poppins(
                color: AppConstants.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Formulaire
            CustomInput(
              controller: _titleController,
              label: 'Titre du rapport',
              hint: 'Entrez le titre du rapport',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le titre est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomInput(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Décrivez le contenu du rapport',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La description est requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomDropdown(
              value: _selectedReportType,
              items: _reportTypes,
              onChanged: (value) {
                setState(() {
                  _selectedReportType = value!;
                });
              },
              label: 'Type de rapport',
            ),
            const SizedBox(height: 16),

            CustomInput(
              controller: _summaryController,
              label: 'Résumé (optionnel)',
              hint: 'Résumé du rapport',
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Annuler',
                    onPressed: () => Navigator.pop(context),
                    // backgroundColor: AppConstants.textGrey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: _isLoading ? 'Création...' : 'Créer',
                    onPressed: _isLoading ? null : _createReport,
                    // backgroundColor: AppConstants.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
