import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../components/custom_card.dart';
import '../models/user_model.dart';
import '../models/analysis_report_model.dart';
import '../models/data_collection_model.dart';
import '../models/error_log_model.dart';
import '../models/backup_model.dart';
import '../services/auth_service.dart';
import '../services/analysis_service.dart';
import '../services/firestore_service.dart';
import '../services/error_service.dart';
import '../services/backup_service.dart';
import '../services/navigation_helper.dart';
import 'error_management_screen.dart';
import 'backup_management_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class SupervisorHomeScreen extends StatefulWidget {
  const SupervisorHomeScreen({super.key});

  @override
  State<SupervisorHomeScreen> createState() => _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
  final AuthService _authService = AuthService();
  final AnalysisService _analysisService = AnalysisService();
  final FirestoreService _firestoreService = FirestoreService();
  final ErrorService _errorService = ErrorService();
  final BackupService _backupService = BackupService();

  UserModel? _currentUser;
  bool _isLoading = true;

  // Statistiques
  int _totalErrors = 0;
  int _totalBackups = 0;
  int _totalReports = 0;

  // Données récentes
  List<ErrorLogModel> _recentErrors = [];
  List<BackupModel> _recentBackups = [];
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

      // Charger les données en parallèle
      final futures = await Future.wait([
        _errorService.getAllErrorLogs(),
        _backupService.getAllBackups(),
        _analysisService.getAllAnalysisReports(),
        _firestoreService.getAllDataCollections(),
      ]);

      final errors = futures[0] as List<ErrorLogModel>;
      final backups = futures[1] as List<BackupModel>;
      final reports = futures[2] as List<AnalysisReportModel>;
      final dataCollections = futures[3] as List<DataCollectionModel>;

      setState(() {
        _currentUser = user;
        _totalErrors = errors.length;
        _totalBackups = backups.length;
        _totalReports = reports.length;
        _recentErrors = errors.take(3).toList();
        _recentBackups = backups.take(3).toList();
        _recentReports = reports.take(3).toList();
        _recentDataCollections = dataCollections.take(3).toList();
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
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.orange.withValues(
                              alpha: 0.15,
                            ),
                            child: Text(
                              _currentUser != null
                                  ? _getInitials(_currentUser!)
                                  : 'S',
                              style: GoogleFonts.poppins(
                                color: Colors.orange,
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
                                'Superviseur',
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
                            color: Colors.orange,
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

            // Fonctionnalités Superviseur
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Mes Fonctionnalités',
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSupervisorFeatures(),
            ),
            // Statistiques
            Padding(
              padding: const EdgeInsets.all(16),
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
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
                                        CupertinoIcons.exclamationmark_triangle,
                                        color: Colors.orange,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_totalErrors',
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Erreurs',
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
                                        CupertinoIcons.cloud,
                                        color: Colors.orange,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_totalBackups',
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Sauvegarde',
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
                                        CupertinoIcons.doc_text,
                                        color: Colors.orange,
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
                      color: Colors.orange,
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
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        )
                        : ListView.separated(
                          itemCount: _getActivityItems().length.clamp(1, 5),
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

  Widget _buildSupervisorFeatures() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: CupertinoIcons.exclamationmark_triangle,
          title: 'Gestion des Erreurs',
          subtitle: 'Gérer et résoudre les erreurs',
          onTap: () {
            if (_currentUser != null) {
              NavigationHelper.pushFade(
                context,
                ErrorManagementScreen(currentUser: _currentUser!),
              );
            }
          },
        ),
        _buildFeatureCard(
          icon: CupertinoIcons.cloud,
          title: 'Gestion des Sauvegardes',
          subtitle: 'Créer et gérer les sauvegardes',
          onTap: () {
            if (_currentUser != null) {
              NavigationHelper.pushFade(
                context,
                BackupManagementScreen(currentUser: _currentUser!),
              );
            }
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
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.orange, size: 24),
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

  List<Map<String, dynamic>> _getActivityItems() {
    final List<Map<String, dynamic>> activities = [];

    // Ajouter les erreurs récentes
    for (final error in _recentErrors) {
      activities.add({
        'title': 'Erreur signalée',
        'subtitle': error.title,
        'time': _formatTimeAgo(error.createdAt),
        'icon': CupertinoIcons.exclamationmark_triangle,
        'color': Colors.red,
      });
    }

    // Ajouter les sauvegardes récentes
    for (final backup in _recentBackups) {
      activities.add({
        'title': 'Sauvegarde créée',
        'subtitle': backup.description,
        'time': _formatTimeAgo(backup.createdAt),
        'icon': CupertinoIcons.cloud,
        'color': Colors.blue,
      });
    }

    // Ajouter les rapports récents
    for (final report in _recentReports) {
      activities.add({
        'title': 'Rapport ${report.status == 'published' ? 'publié' : 'créé'}',
        'subtitle': report.title,
        'time': _formatTimeAgo(report.createdAt),
        'icon': CupertinoIcons.doc_text,
        'color': report.status == 'published' ? Colors.green : Colors.purple,
      });
    }

    // Ajouter les collectes de données récentes
    for (final data in _recentDataCollections) {
      activities.add({
        'title': 'Données collectées',
        'subtitle': '${data.essence} - ${data.chantier}',
        'time': _formatTimeAgo(data.date),
        'icon': CupertinoIcons.cube_box,
        'color': Colors.orange,
      });
    }

    // Trier par date (plus récent en premier)
    activities.sort((a, b) {
      // Pour simplifier, on utilise l'ordre d'ajout
      return 0;
    });

    return activities;
  }

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

  String _getInitials(UserModel user) {
    final firstName = user.firstName.isNotEmpty ? user.firstName[0] : '';
    final lastName = user.lastName.isNotEmpty ? user.lastName[0] : '';
    return '$firstName$lastName'.toUpperCase();
  }

  Widget _buildActivityCard(int index) {
    final activities = _getActivityItems();

    if (activities.isEmpty) {
      // Activités par défaut si aucune donnée
      final defaultActivities = [
        {
          'title': 'Aucune activité récente',
          'subtitle': 'Les activités apparaîtront ici',
          'time': '',
          'icon': CupertinoIcons.info,
          'color': AppConstants.textGrey,
        },
      ];
      final activity = defaultActivities[0];

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
          ],
        ),
      );
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
}
