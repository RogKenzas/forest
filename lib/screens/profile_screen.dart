import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/analysis_service.dart';
import '../services/error_service.dart';
import '../services/backup_service.dart';
import '../services/navigation_helper.dart';
import 'home_screen.dart';
import 'inventory_screen.dart';
import 'analysis_screen.dart';
import 'settings_screen.dart';
import '../components/custom_card.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final AnalysisService _analysisService = AnalysisService();
  final ErrorService _errorService = ErrorService();
  final BackupService _backupService = BackupService();

  Future<(UserModel?, Map<String, dynamic>)> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return (
        null,
        {
          'totalDataCollections': 0,
          'totalReports': 0,
          'unreadNotifications': 0,
          'recentDataCollections': const [],
          'recentReports': const [],
          'recentNotifications': const [],
        },
      );
    }
    final profile = await _authService.getUserData(user.uid);

    // Charger les statistiques selon le rôle
    Map<String, dynamic> stats = {};
    if (profile != null) {
      switch (profile.role) {
        case UserRole.analyst:
          // Pour les analystes, charger les rapports
          final reports = await _analysisService.getUserAnalysisReports(
            user.uid,
          );
          final reportStats = await _analysisService.getReportStats();
          stats = {
            'totalReports': reports.length,
            'totalDataCollections': 0,
            'unreadNotifications': 0,
            'recentReports': reports.take(5).toList(),
            'recentDataCollections': const [],
            'recentNotifications': const [],
            'reportStats': reportStats,
          };
          break;
        case UserRole.supervisor:
          // Pour les superviseurs, charger les erreurs, sauvegardes et rapports
          final errors = await _errorService.getAllErrorLogs();
          final backups = await _backupService.getAllBackups();
          final reports = await _analysisService.getAllAnalysisReports();
          final errorStats = await _errorService.getErrorStats();
          stats = {
            'totalErrors': errors.length,
            'totalBackups': backups.length,
            'totalReports': reports.length,
            'totalDataCollections': 0,
            'unreadNotifications': 0,
            'recentErrors': errors.take(5).toList(),
            'recentBackups': backups.take(5).toList(),
            'recentReports': reports.take(5).toList(),
            'recentDataCollections': const [],
            'recentNotifications': const [],
            'errorStats': errorStats,
          };
          break;
        case UserRole.agent:
        default:
          // Pour les agents, charger les données de collecte
          stats = await _firestoreService.getDashboardStats(user.uid);
          break;
      }
    }

    return (profile, stats);
  }

  Future<void> _smartPop() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      NavigationHelper.pushReplacementFade(context, const HomeScreen());
    }
  }

  String _initialsFor(UserModel user) {
    final String a = (user.firstName.isNotEmpty ? user.firstName[0] : '');
    final String b = (user.lastName.isNotEmpty ? user.lastName[0] : '');
    final String fallback = user.username.isNotEmpty ? user.username[0] : '?';
    final String res = (a + b).trim();
    return res.isEmpty ? fallback.toUpperCase() : res.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlack,
      appBar: AppBar(
        title: Text(
          'Profil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: Container(
          decoration: BoxDecoration(
            color: AppConstants.lightGrey,
            borderRadius: BorderRadius.circular(50),
          ),
          child: IconButton(
            onPressed: _smartPop,
            icon: const Icon(
              CupertinoIcons.chevron_left,
              color: AppConstants.white,
              size: 24,
            ),
          ),
        ),
      ),
      body: FutureBuilder<(UserModel?, Map<String, dynamic>)>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppConstants.primaryGreen,
              ),
            );
          }
          final data = snapshot.data;
          final user = data?.$1;
          final stats = data?.$2 ?? const {};

          if (user == null) {
            return Center(
              child: Text(
                'Veuillez vous connecter',
                style: GoogleFonts.poppins(color: AppConstants.textGrey),
              ),
            );
          }

          // Extraire les statistiques selon le rôle
          int total, totalReports, unread;
          switch (user.role) {
            case UserRole.supervisor:
              total = (stats['totalErrors'] ?? 0) as int;
              totalReports = (stats['totalBackups'] ?? 0) as int;
              unread = (stats['totalReports'] ?? 0) as int;
              break;
            case UserRole.analyst:
              total = (stats['totalDataCollections'] ?? 0) as int;
              totalReports = (stats['totalReports'] ?? 0) as int;
              unread = (stats['unreadNotifications'] ?? 0) as int;
              break;
            case UserRole.agent:
            default:
              total = (stats['totalDataCollections'] ?? 0) as int;
              totalReports = (stats['totalReports'] ?? 0) as int;
              unread = (stats['unreadNotifications'] ?? 0) as int;
              break;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header (long-press to view profile details)
              GestureDetector(
                onLongPress: () => _openViewProfileSheet(user),
                child: CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: _getRoleColor(
                          user.role,
                        ).withValues(alpha: 0.15),
                        child: Text(
                          _initialsFor(user),
                          style: GoogleFonts.poppins(
                            color: _getRoleColor(user.role),
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName.trim().isEmpty
                                  ? '@${user.username}'
                                  : user.fullName,
                              style: GoogleFonts.poppins(
                                color: AppConstants.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: GoogleFonts.poppins(
                                color: AppConstants.textGrey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Affichage du type de compte
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor(
                                  user.role,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getRoleColor(user.role),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getRoleDisplayName(user.role),
                                style: GoogleFonts.poppins(
                                  color: _getRoleColor(user.role),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Stats personnalisées selon le rôle
              _buildRoleSpecificStats(user.role, total, totalReports, unread),

              const SizedBox(height: 8),

              // Actions personnalisées selon le rôle
              _buildRoleSpecificActions(user),

              const SizedBox(height: 12),

              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGreen,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextButton.icon(
                    onPressed: () async {
                      await AuthService().signOut();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    },
                    icon: const Icon(CupertinoIcons.square_arrow_left),
                    label: Text(
                      'Se déconnecter',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppConstants.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openViewProfileSheet(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConstants.primaryBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppConstants.primaryGreen.withValues(
                          alpha: 0.15,
                        ),
                        child: Text(
                          _initialsFor(user),
                          style: GoogleFonts.poppins(
                            color: AppConstants.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Profil utilisateur',
                        style: GoogleFonts.poppins(
                          color: AppConstants.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
              const SizedBox(height: 12),
              _readonlyField(
                icon: CupertinoIcons.person,
                label: 'Nom complet',
                value: user.fullName.trim().isEmpty ? '—' : user.fullName,
              ),
              _readonlyField(
                icon: CupertinoIcons.at,
                label: 'Nom d\'utilisateur',
                value: user.username.isEmpty ? '—' : '@${user.username}',
              ),
              _readonlyField(
                icon: CupertinoIcons.envelope,
                label: 'Email',
                value: user.email,
              ),
              _readonlyField(
                icon: CupertinoIcons.calendar,
                label: 'Inscription',
                value: user.dateJoined.toLocal().toString().substring(0, 16),
              ),
              if (user.lastLogin != null)
                _readonlyField(
                  icon: CupertinoIcons.time,
                  label: 'Dernière connexion',
                  value: user.lastLogin!.toLocal().toString().substring(0, 16),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _readonlyField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppConstants.lightGrey.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.darkGrey),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.textGrey, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppConstants.textGrey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: AppConstants.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openEditProfileSheet(UserModel user) {
    final firstController = TextEditingController(text: user.firstName);
    final lastController = TextEditingController(text: user.lastName);
    final usernameController = TextEditingController(text: user.username);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConstants.primaryBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Modifier le profil',
                          style: GoogleFonts.poppins(
                            color: AppConstants.white,
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
                    const SizedBox(height: 12),
                    _editableField(
                      controller: firstController,
                      label: 'Prénom',
                      icon: CupertinoIcons.person,
                    ),
                    const SizedBox(height: 10),
                    _editableField(
                      controller: lastController,
                      label: 'Nom',
                      icon: CupertinoIcons.person_2,
                    ),
                    const SizedBox(height: 10),
                    _editableField(
                      controller: usernameController,
                      label: 'Nom d\'utilisateur',
                      icon: CupertinoIcons.at,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final String newFirst = firstController.text.trim();
                          final String newLast = lastController.text.trim();
                          final String newUser = usernameController.text.trim();
                          try {
                            await _authService.updateUserProfile(
                              userId: user.id,
                              data: {
                                'firstName': newFirst,
                                'lastName': newLast,
                                'username': newUser,
                              },
                            );
                            if (!mounted) return;
                            Navigator.pop(context);
                            setState(() {});
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryGreen,
                          foregroundColor: AppConstants.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Enregistrer',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _editableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.darkGrey),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.poppins(color: AppConstants.white),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: GoogleFonts.poppins(color: AppConstants.textGrey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.agent:
        return AppConstants.primaryGreen;
      case UserRole.analyst:
        return Colors.blue;
      case UserRole.supervisor:
        return Colors.orange;
      case UserRole.admin:
        return Colors.purple;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.agent:
        return 'Agent de Terrain';
      case UserRole.analyst:
        return 'Analyste';
      case UserRole.supervisor:
        return 'Superviseur';
      case UserRole.admin:
        return 'Administrateur';
    }
  }

  /// Construire les statistiques spécifiques au rôle
  Widget _buildRoleSpecificStats(
    UserRole role,
    int totalData,
    int totalReports,
    int unread,
  ) {
    switch (role) {
      case UserRole.analyst:
        return Row(
          children: [
            Expanded(
              child: CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppConstants.darkGrey,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.doc_chart,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalReports',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Rapports',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppConstants.darkGrey,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.chart_bar_square,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(totalReports * 0.8).round()}',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Analyses',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case UserRole.supervisor:
        return Row(
          children: [
            Expanded(
              child: CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppConstants.darkGrey,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalData', // totalErrors
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Erreurs',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppConstants.darkGrey,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.cloud,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalReports', // totalBackups
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Sauvegardes',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case UserRole.admin:
        return Row(
          children: [
            Expanded(
              child: CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppConstants.darkGrey,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.cube_box,
                          color: Colors.purple,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalData', // totalDataCollections
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Collectes',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppConstants.darkGrey,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.doc_text,
                          color: Colors.purple,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalReports', // totalReports
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Rapports',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case UserRole.agent:
        return Row(
          children: [
            Expanded(
              child: CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppConstants.darkGrey,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.cube_box,
                          color: AppConstants.primaryGreen,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalData',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Chantiers',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppConstants.darkGrey,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.bell,
                          color: AppConstants.primaryGreen,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$unread',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Non lus',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }

  /// Construire les actions spécifiques au rôle
  Widget _buildRoleSpecificActions(UserModel user) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          _ActionTile(
            icon: CupertinoIcons.person,
            title: 'Modifier le profil',
            onTap: () => _openEditProfileSheet(user),
          ),
          const SizedBox(height: 8),
          // Actions spécifiques au rôle
          ..._getRoleSpecificActionTiles(user),
          const SizedBox(height: 8),
          _ActionTile(
            icon: CupertinoIcons.settings,
            title: 'Paramètres',
            onTap:
                () => NavigationHelper.pushReplacementFade(
                  context,
                  const SettingsScreen(),
                ),
          ),
          const SizedBox(height: 8),
          if (FirebaseAuth.instance.currentUser?.email == 'admin@gmail.com')
            _ActionTile(
              icon: CupertinoIcons.person_crop_square,
              title: 'Interface administrateur',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminScreen()),
                  ),
            ),
        ],
      ),
    );
  }

  /// Obtenir les actions spécifiques au rôle
  List<Widget> _getRoleSpecificActionTiles(UserModel user) {
    switch (user.role) {
      case UserRole.analyst:
        return [
          _ActionTile(
            icon: CupertinoIcons.doc_chart,
            title: 'Mes rapports',
            onTap:
                () => NavigationHelper.pushReplacementFade(
                  context,
                  AnalysisScreen(currentUser: user),
                ),
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: CupertinoIcons.chart_bar_square,
            title: 'Analyses',
            onTap:
                () => NavigationHelper.pushReplacementFade(
                  context,
                  AnalysisScreen(currentUser: user),
                ),
          ),
        ];
      case UserRole.supervisor:
        return [
          _ActionTile(
            icon: CupertinoIcons.exclamationmark_triangle,
            title: 'Gestion des erreurs',
            onTap: () {
              // TODO: Naviguer vers l'écran de gestion des erreurs
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gestion des erreurs - À implémenter'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: CupertinoIcons.cloud,
            title: 'Gestion des sauvegardes',
            onTap: () {
              // TODO: Naviguer vers l'écran de gestion des sauvegardes
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gestion des sauvegardes - À implémenter'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: CupertinoIcons.doc_text,
            title: 'Rapports de supervision',
            onTap: () {
              // TODO: Naviguer vers l'écran des rapports de supervision
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rapports de supervision - À implémenter'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ];
      case UserRole.admin:
        return [
          _ActionTile(
            icon: CupertinoIcons.person_2,
            title: 'Gestion des utilisateurs',
            onTap: () {
              // TODO: Naviguer vers l'écran de gestion des utilisateurs
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gestion des utilisateurs - À implémenter'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: CupertinoIcons.tree,
            title: 'Gestion des zones',
            onTap: () {
              // TODO: Naviguer vers l'écran de gestion des zones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gestion des zones - À implémenter'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: CupertinoIcons.gear,
            title: 'Configuration système',
            onTap: () {
              // TODO: Naviguer vers l'écran de configuration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuration système - À implémenter'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
          ),
        ];
      case UserRole.agent:
        return [
          _ActionTile(
            icon: CupertinoIcons.cube_box,
            title: 'Mes chantiers',
            onTap:
                () => NavigationHelper.pushReplacementFade(
                  context,
                  const InventoryScreen(),
                ),
          ),
        ];
    }
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppConstants.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppConstants.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: AppConstants.textGrey,
            ),
          ],
        ),
      ),
    );
  }
}
