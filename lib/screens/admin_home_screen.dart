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
import '../models/forest_zone_model.dart';
import '../services/auth_service.dart';
import '../services/analysis_service.dart';
import '../services/firestore_service.dart';
import '../services/error_service.dart';
import '../services/backup_service.dart';
import '../services/forest_zone_service.dart';
import '../services/navigation_helper.dart';
import 'admin_screen.dart';
import 'forest_zones_management_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AuthService _authService = AuthService();
  final AnalysisService _analysisService = AnalysisService();
  final FirestoreService _firestoreService = FirestoreService();
  final ErrorService _errorService = ErrorService();
  final BackupService _backupService = BackupService();
  final ForestZoneService _forestZoneService = ForestZoneService();

  UserModel? _currentUser;
  bool _isLoading = true;

  // Statistiques
  int _totalUsers = 0;
  int _totalZones = 0;
  int _totalReports = 0;

  // Données récentes
  List<UserModel> _recentUsers = [];
  List<ForestZoneModel> _recentZones = [];
  List<AnalysisReportModel> _recentReports = [];
  List<ErrorLogModel> _recentErrors = [];
  List<BackupModel> _recentBackups = [];
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
        _authService.getAllUsers(),
        _forestZoneService.getAllForestZones(),
        _analysisService.getAllAnalysisReports(),
        _errorService.getAllErrorLogs(),
        _backupService.getAllBackups(),
        _firestoreService.getAllDataCollections(),
      ]);

      final users = futures[0] as List<UserModel>;
      final zones = futures[1] as List<ForestZoneModel>;
      final reports = futures[2] as List<AnalysisReportModel>;
      final errors = futures[3] as List<ErrorLogModel>;
      final backups = futures[4] as List<BackupModel>;
      final dataCollections = futures[5] as List<DataCollectionModel>;

      setState(() {
        _currentUser = user;
        _totalUsers = users.length;
        _totalZones = zones.length;
        _totalReports = reports.length;
        _recentUsers = users.take(3).toList();
        _recentZones = zones.take(3).toList();
        _recentReports = reports.take(3).toList();
        _recentErrors = errors.take(3).toList();
        _recentBackups = backups.take(3).toList();
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
                          color: Colors.purple.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.purple.withValues(
                              alpha: 0.15,
                            ),
                            child: Text(
                              _currentUser != null
                                  ? _getInitials(_currentUser!)
                                  : 'A',
                              style: GoogleFonts.poppins(
                                color: Colors.purple,
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
                                'Administrateur',
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
                            color: Colors.purple,
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

            // Fonctionnalités Admin
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
              child: _buildAdminFeatures(),
            ),

            // Statistiques
            Padding(
              padding: const EdgeInsets.all(16),
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.purple),
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
                                        CupertinoIcons.person_2,
                                        color: Colors.purple,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_totalUsers',
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Utilisateurs',
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
                                        CupertinoIcons.tree,
                                        color: Colors.purple,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_totalZones',
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Zones',
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
                                        color: Colors.purple,
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
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _showAllActivitiesModal();
                    },
                    child: Text(
                      'Voir Tout',
                      style: GoogleFonts.poppins(
                        color: Colors.purple,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
                            color: Colors.purple,
                          ),
                        )
                        : ListView.separated(
                          itemCount: _getAllActivities().length.clamp(1, 5),
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

  Widget _buildAdminFeatures() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: CupertinoIcons.person_2,
          title: 'Gestion des Utilisateurs',
          subtitle: 'Gérer les comptes utilisateurs',
          onTap: () {
            NavigationHelper.pushFade(context, const AdminScreen());
          },
        ),
        _buildFeatureCard(
          icon: CupertinoIcons.tree,
          title: 'Zones Forestières',
          subtitle: 'Gérer les zones forestières',
          onTap: () {
            if (_currentUser != null) {
              NavigationHelper.pushFade(
                context,
                ForestZonesManagementScreen(currentUser: _currentUser!),
              );
            }
          },
        ),
        _buildFeatureCard(
          icon: CupertinoIcons.gear,
          title: 'Configuration',
          subtitle: 'Configurer la plateforme',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fonctionnalité de configuration à venir'),
                backgroundColor: Colors.purple,
              ),
            );
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
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.purple, size: 24),
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
    final activities = _getAllActivities();

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

  void _showAllActivitiesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConstants.primaryBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppConstants.primaryBlack,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppConstants.textGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Toutes les Activités',
                          style: GoogleFonts.poppins(
                            color: AppConstants.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
                  ),

                  // Content
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.purple,
                              ),
                            )
                            : _getAllActivities().isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.info,
                                    color: AppConstants.textGrey,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune activité récente',
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.textGrey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Les activités apparaîtront ici',
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.textGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _getAllActivities().length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildActivityCard(index);
                              },
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getAllActivities() {
    final List<Map<String, dynamic>> activities = [];

    // Ajouter tous les utilisateurs
    for (final user in _recentUsers) {
      activities.add({
        'title': 'Utilisateur créé',
        'subtitle': '${user.fullName} (${user.role.name})',
        'time': _formatTimeAgo(user.dateJoined),
        'icon': CupertinoIcons.person_add,
        'color': Colors.green,
      });
    }

    // Ajouter toutes les zones
    for (final zone in _recentZones) {
      activities.add({
        'title': 'Zone forestière',
        'subtitle': zone.name,
        'time': _formatTimeAgo(zone.createdAt),
        'icon': CupertinoIcons.tree,
        'color': Colors.blue,
      });
    }

    // Ajouter tous les rapports
    for (final report in _recentReports) {
      activities.add({
        'title': 'Rapport ${report.status == 'published' ? 'publié' : 'créé'}',
        'subtitle': report.title,
        'time': _formatTimeAgo(report.createdAt),
        'icon': CupertinoIcons.doc_text,
        'color': report.status == 'published' ? Colors.green : Colors.purple,
      });
    }

    // Ajouter toutes les erreurs
    for (final error in _recentErrors) {
      activities.add({
        'title': 'Erreur signalée',
        'subtitle': error.title,
        'time': _formatTimeAgo(error.createdAt),
        'icon': CupertinoIcons.exclamationmark_triangle,
        'color': Colors.red,
      });
    }

    // Ajouter toutes les sauvegardes
    for (final backup in _recentBackups) {
      activities.add({
        'title': 'Sauvegarde créée',
        'subtitle': backup.description,
        'time': _formatTimeAgo(backup.createdAt),
        'icon': CupertinoIcons.cloud,
        'color': Colors.orange,
      });
    }

    // Ajouter toutes les collectes de données
    for (final data in _recentDataCollections) {
      activities.add({
        'title': 'Données collectées',
        'subtitle': '${data.essence} - ${data.chantier}',
        'time': _formatTimeAgo(data.date),
        'icon': CupertinoIcons.cube_box,
        'color': Colors.cyan,
      });
    }

    // Trier par date (plus récent en premier)
    activities.sort((a, b) {
      // Pour simplifier, on utilise l'ordre d'ajout
      return 0;
    });

    return activities;
  }
}
