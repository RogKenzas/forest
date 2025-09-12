import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../components/custom_card.dart';
import '../models/user_model.dart';
import '../models/analysis_report_model.dart';
import '../models/data_collection_model.dart';
import '../services/auth_service.dart';
import '../services/analysis_service.dart';
import '../services/firestore_service.dart';
import '../services/navigation_helper.dart';
import 'analysis_screen.dart';
import 'export_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class AnalystHomeScreen extends StatefulWidget {
  const AnalystHomeScreen({super.key});

  @override
  State<AnalystHomeScreen> createState() => _AnalystHomeScreenState();
}

class _AnalystHomeScreenState extends State<AnalystHomeScreen> {
  final AuthService _authService = AuthService();
  final AnalysisService _analysisService = AnalysisService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  bool _isLoading = true;

  // Données dynamiques
  int _totalReports = 0;
  int _totalAnalyses = 0;
  int _totalExports = 0;
  List<AnalysisReportModel> _recentReports = [];
  List<DataCollectionModel> _recentDataCollections = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Charger l'utilisateur actuel
      final user = await _authService.getCurrentUser();

      // Charger les données dynamiques
      final reports = await _analysisService.getAllAnalysisReports();
      final dataCollections = await _firestoreService.getAllDataCollections();
      final stats = await _analysisService.getReportStats();

      setState(() {
        _currentUser = user;
        _totalReports = reports.length;
        _totalAnalyses = stats['published'] ?? 0;
        _totalExports =
            stats['total'] ?? 0; // Approximation basée sur les rapports
        _recentReports = reports.take(5).toList();
        _recentDataCollections = dataCollections.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Erreur lors du chargement des données: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_currentUser != null) {
                        HapticFeedback.selectionClick();
                        NavigationHelper.pushFade(
                          context,
                          const ProfileScreen(),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.lightGrey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppConstants.primaryGreen.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppConstants.primaryGreen
                                .withValues(alpha: 0.15),
                            child: Text(
                              _currentUser != null
                                  ? _getInitials(_currentUser!)
                                  : 'A',
                              style: GoogleFonts.poppins(
                                color: AppConstants.primaryGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Analyste',
                                style: GoogleFonts.poppins(
                                  color: AppConstants.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_currentUser != null)
                                Text(
                                  'Bonjour, ${_currentUser!.firstName}',
                                  style: GoogleFonts.poppins(
                                    color: AppConstants.textGrey,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.chevron_right,
                            color: AppConstants.primaryGreen,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppConstants.darkGrey,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: AppConstants.textGrey,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Fonctionnalités Analyste
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Mes Fonctionnalités',
                style: GoogleFonts.poppins(
                  color: AppConstants.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildAnalystFeatures(),
            ),
            const SizedBox(height: 20),

            // Statistiques
            Padding(
              padding: const EdgeInsets.all(16),
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      )
                      : Row(
                        children: [
                          Expanded(
                            child: CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppConstants.darkGrey,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(13.0),
                                      child: Icon(
                                        CupertinoIcons.doc_chart,
                                        color: Colors.blue,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_totalReports',
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Rapports',
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.textGrey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppConstants.darkGrey,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(13.0),
                                      child: Icon(
                                        CupertinoIcons.chart_bar_square,
                                        color: Colors.blue,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_totalAnalyses',
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Analyses',
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.textGrey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppConstants.darkGrey,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(13.0),
                                      child: Icon(
                                        CupertinoIcons.arrow_down_doc,
                                        color: Colors.blue,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_totalExports',
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Exports',
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.textGrey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
            ),

            // Activité récente
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activité Récente',
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Voir Tout',
                    style: GoogleFonts.poppins(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Liste d'activité
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        )
                        : ListView.separated(
                          itemCount: (_recentReports.length +
                                  _recentDataCollections.length)
                              .clamp(1, 5),
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildActivityCard(index);
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalystFeatures() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: CupertinoIcons.doc_chart,
          title: 'Analyse des Données',
          subtitle: 'Analyser et exporter les données',
          onTap: () {
            if (_currentUser != null) {
              NavigationHelper.pushFade(
                context,
                AnalysisScreen(currentUser: _currentUser!),
              );
            }
          },
        ),
        _buildFeatureCard(
          icon: CupertinoIcons.arrow_down_doc,
          title: 'Export de Données',
          subtitle: 'Exporter les données en différents formats',
          onTap: () {
            NavigationHelper.pushFade(context, const ExportScreen());
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: AppConstants.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppConstants.textGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(int index) {
    // Créer une liste d'activités basée sur les vraies données
    final activities = <Map<String, dynamic>>[];

    // Ajouter les rapports récents
    for (int i = 0; i < _recentReports.length && i < 3; i++) {
      final report = _recentReports[i];
      activities.add({
        'title': 'Rapport créé: ${report.title}',
        'subtitle': 'Par ${report.createdByUserName}',
        'time': _formatTimeAgo(report.createdAt),
        'icon': CupertinoIcons.doc_chart,
        'color': _getStatusColor(report.status),
      });
    }

    // Ajouter les collectes de données récentes
    for (int i = 0; i < _recentDataCollections.length && i < 2; i++) {
      final data = _recentDataCollections[i];
      activities.add({
        'title': 'Données collectées: ${data.essence}',
        'subtitle': 'Zone: ${data.chantier}',
        'time': _formatTimeAgo(data.date),
        'icon': CupertinoIcons.cube_box,
        'color': data.isAlert ? Colors.red : Colors.green,
      });
    }

    // Si pas assez d'activités, ajouter des activités par défaut
    if (activities.length < 5) {
      activities.addAll([
        {
          'title': 'Export PDF généré',
          'subtitle': 'Rapport de synthèse',
          'time': 'Il y a 1 jour',
          'icon': CupertinoIcons.doc_plaintext,
          'color': Colors.blue,
        },
        {
          'title': 'Analyse statistique',
          'subtitle': 'Tendances identifiées',
          'time': 'Il y a 2 jours',
          'icon': CupertinoIcons.chart_bar_square,
          'color': Colors.orange,
        },
      ]);
    }

    if (index >= activities.length) {
      return const SizedBox.shrink();
    }

    final activity = activities[index];

    return CustomCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: GoogleFonts.poppins(
                    color: AppConstants.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['subtitle'] as String,
                  style: GoogleFonts.poppins(
                    color: AppConstants.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'] as String,
            style: GoogleFonts.poppins(
              color: AppConstants.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Formater le temps écoulé depuis une date
  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  /// Obtenir la couleur selon le statut du rapport
  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'pending_review':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  /// Générer les initiales de l'utilisateur
  String _getInitials(UserModel user) {
    final String a = (user.firstName.isNotEmpty ? user.firstName[0] : '');
    final String b = (user.lastName.isNotEmpty ? user.lastName[0] : '');
    final String fallback = user.username.isNotEmpty ? user.username[0] : 'A';
    final String res = (a + b).trim();
    return res.isEmpty ? fallback.toUpperCase() : res.toUpperCase();
  }
}
