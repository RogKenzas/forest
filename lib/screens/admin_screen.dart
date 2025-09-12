import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forest/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../components/custom_card.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchCtrl = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  bool _match(UserModel u) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      final match =
          (u.username.toLowerCase().contains(q) ||
              ('${u.firstName} ${u.lastName}').toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q));
      if (!match) return false;
    }
    return true;
  }

  void _openUserSheet(UserModel u) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppConstants.darkGrey, AppConstants.primaryBlack],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                      color: AppConstants.textGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header with user info
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppConstants.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryGreen.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.transparent,
                        child: Text(
                          _initialsFor(u),
                          style: GoogleFonts.poppins(
                            color: AppConstants.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.fullName.trim().isEmpty
                                ? '@${u.username}'
                                : u.fullName,
                            style: GoogleFonts.poppins(
                              color: AppConstants.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient:
                                  (u.isSuperUser || u.isStaff)
                                      ? AppConstants.primaryGradient
                                      : const LinearGradient(
                                        colors: [
                                          AppConstants.lightGrey,
                                          AppConstants.darkGrey,
                                        ],
                                      ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              (u.isSuperUser || u.isStaff)
                                  ? 'Admin'
                                  : 'Utilisateur',
                              style: GoogleFonts.poppins(
                                color: AppConstants.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppConstants.lightGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          CupertinoIcons.xmark,
                          color: AppConstants.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats cards
                FutureBuilder<Map<String, dynamic>>(
                  future: _firestoreService.getDashboardStats(u.id),
                  builder: (context, snap) {
                    final stats =
                        snap.data ??
                        const {
                          'totalDataCollections': 0,
                          'unreadNotifications': 0,
                        };
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: CupertinoIcons.cube_box_fill,
                            value: '${stats['totalDataCollections']}',
                            label: 'Chantiers',
                            color: AppConstants.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: CupertinoIcons.bell_fill,
                            value: '${stats['unreadNotifications']}',
                            label: 'Notifications',
                            color: AppConstants.textGrey,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // User details
                _buildDetailRow(CupertinoIcons.at, '@${u.username}'),
                _buildDetailRow(CupertinoIcons.envelope, u.email),
                _buildDetailRow(
                  CupertinoIcons.circle_fill,
                  u.isActive ? 'Compte actif' : 'Compte inactif',
                  color:
                      u.isActive
                          ? AppConstants.primaryGreen
                          : AppConstants.textGrey,
                ),
                if (u.assignedCodeProspe != null || u.assignedBloc != null)
                  _buildDetailRow(
                    CupertinoIcons.number_square_fill,
                    'Code: ${u.assignedCodeProspe ?? '-'} • Bloc: ${u.assignedBloc ?? '-'}',
                    color: AppConstants.primaryGreen,
                  ),
                if (u.assignedAccessCode != null)
                  _buildDetailRow(
                    CupertinoIcons.padlock_solid,
                    'Code d\'accès: ${u.assignedAccessCode}',
                    color: AppConstants.primaryGreen,
                  ),
                const SizedBox(height: 20),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final res = await _firestoreService
                            .assignUserProspectAndBloc(u.id);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppConstants.primaryGreen,
                            content: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.check_mark_circled,
                                  color: AppConstants.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Assigné: code ${res['codeProspe']} • bloc ${res['bloc']}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppConstants.darkGrey,
                            content: Text('Erreur: $e'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                      foregroundColor: AppConstants.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(CupertinoIcons.number_square_fill),
                    label: Text(
                      'Assigner code & bloc',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _firestoreService.updateUserFields(
                            userId: u.id,
                            data: {'isActive': !u.isActive},
                          );
                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                u.isActive
                                    ? AppConstants.textGrey
                                    : AppConstants.primaryGreen,
                            width: 2,
                          ),
                          foregroundColor:
                              u.isActive
                                  ? AppConstants.textGrey
                                  : AppConstants.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: Icon(
                          u.isActive
                              ? CupertinoIcons.power
                              : CupertinoIcons.power,
                        ),
                        label: Text(
                          u.isActive ? 'Désactiver' : 'Activer',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _firestoreService.updateUserFields(
                            userId: u.id,
                            data: {'isStaff': !(u.isStaff || u.isSuperUser)},
                          );
                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppConstants.primaryGreen,
                            width: 2,
                          ),
                          foregroundColor: AppConstants.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(
                          CupertinoIcons.person_crop_square_fill,
                        ),
                        label: Text(
                          (u.isSuperUser || u.isStaff)
                              ? 'Retirer admin'
                              : 'Attribuer admin',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppConstants.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
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
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppConstants.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? AppConstants.textGrey).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? AppConstants.textGrey, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: AppConstants.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Chips de catégories supprimés (design simplifié)

  String _initialsFor(UserModel user) {
    final String a = (user.firstName.isNotEmpty ? user.firstName[0] : '');
    final String b = (user.lastName.isNotEmpty ? user.lastName[0] : '');
    final String fallback = user.username.isNotEmpty ? user.username[0] : '?';
    final String res = (a + b).trim();
    return res.isEmpty ? fallback.toUpperCase() : res.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final current = FirebaseAuth.instance.currentUser;
    final bool allowed = current?.email == 'admin@gmail.com';

    return Scaffold(
      backgroundColor: AppConstants.primaryBlack,
      body:
          allowed
              ? FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SafeArea(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(children: [_buildHeaderRow()]),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 84,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppConstants.lightGrey,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.search,
                                            color: AppConstants.textGrey,
                                            size: 25,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Rechercher...',
                                            style: GoogleFonts.poppins(
                                              color: AppConstants.textGrey,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: AppConstants.lightGrey,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.tune,
                                      color: AppConstants.white,
                                      size: 23,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(child: const SizedBox(height: 8)),
                        SliverFillRemaining(child: _buildUsersList()),
                      ],
                    ),
                  ),
                ),
              )
              : _buildAccessDenied(),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<List<UserModel>>(
      stream: _firestoreService.streamAllUsers(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: AppConstants.white,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 12),
                Text(
                  'Chargement des utilisateurs…',
                  style: GoogleFonts.poppins(color: AppConstants.textGrey),
                ),
              ],
            ),
          );
        }

        final all = snap.data ?? [];
        final items = all.where(_match).toList();
        final total = all.length;
        final totalAdmins = all.where((u) => u.isStaff || u.isSuperUser).length;
        final totalActifs = all.where((u) => u.isActive).length;

        final kpi = Row(
          children: [
            Expanded(
              child: _buildKpiHome(
                icon: CupertinoIcons.person_2_fill,
                value: '$total',
                label: 'Utilisateurs',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiHome(
                icon: CupertinoIcons.check_mark_circled_solid,
                value: '$totalActifs',
                label: 'Actifs',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiHome(
                icon: CupertinoIcons.person_crop_square_fill,
                value: '$totalAdmins',
                label: 'Admins',
              ),
            ),
          ],
        );

        if (items.isEmpty) {
          return Column(
            children: [
              const SizedBox(height: 8),
              kpi,
              Expanded(
                child: Center(
                  child: Text(
                    'Aucun utilisateur trouvé',
                    style: GoogleFonts.poppins(
                      color: AppConstants.textGrey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            if (i == 0)
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: kpi,
              );
            final u = items[i - 1];
            return _userListTile(u);
          },
        );
      },
    );
  }

  Widget _userListTile(UserModel u) {
    return GestureDetector(
      onTap: () => _openUserSheet(u),
      child: CustomCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: AppConstants.lightGrey,
        hasShadow: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppConstants.primaryGreen.withValues(
                alpha: 0.18,
              ),
              child: Text(
                _initialsFor(u),
                style: GoogleFonts.poppins(
                  color: AppConstants.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          u.fullName.trim().isEmpty
                              ? '@${u.username}'
                              : u.fullName,
                          style: GoogleFonts.poppins(
                            color: AppConstants.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (u.isSuperUser || u.isStaff)
                                  ? Colors.orange.withOpacity(0.18)
                                  : Colors.blue.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (u.isSuperUser || u.isStaff)
                              ? 'Admin'
                              : 'Utilisateur',
                          style: GoogleFonts.poppins(
                            color: AppConstants.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    u.email,
                    style: GoogleFonts.poppins(
                      color: AppConstants.textGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              u.isActive
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.xmark_circle_fill,
              color:
                  u.isActive
                      ? AppConstants.primaryGreen
                      : AppConstants.textGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // En-tête à la HomeScreen
  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppConstants.white,
          backgroundImage: AssetImage('assets/logo/box.png'),
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppConstants.darkGrey,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: _openCreateUserSheet,
                  child: Icon(
                    Icons.add,
                    color: AppConstants.textGrey,
                    size: 25,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/settings'),
              child: Container(
                decoration: BoxDecoration(
                  color: AppConstants.darkGrey,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    CupertinoIcons.settings,
                    color: AppConstants.textGrey,
                    size: 27,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppConstants.darkGrey,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    CupertinoIcons.person_fill,
                    color: AppConstants.textGrey,
                    size: 27,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // KPI homogènes avec HomeScreen
  Widget _buildKpiHome({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return CustomCard(
      backgroundColor: AppConstants.lightGrey,
      hasShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppConstants.darkGrey,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Icon(icon, color: AppConstants.primaryGreen, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppConstants.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppConstants.textGrey,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppConstants.lightGrey.withOpacity(0.25),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              CupertinoIcons.lock_shield,
              size: 60,
              color: Colors.red.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Accès refusé',
            style: GoogleFonts.poppins(
              color: AppConstants.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connectez-vous avec un compte administrateur pour accéder à cette interface.',
            style: GoogleFonts.poppins(
              color: AppConstants.textGrey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Ancien widget KPI retiré car remplacé par _buildKpiHome

void _validateEmail(String email) {
  final regex = RegExp(r'^.+@.+\..+$');
  if (!regex.hasMatch(email)) {
    throw Exception('Email invalide');
  }
}

void _validatePassword(String pwd) {
  if (pwd.length < 6) {
    throw Exception('Mot de passe trop court (6+)');
  }
}

extension on _AdminScreenState {
  void _openCreateUserSheet() {
    final emailCtrl = TextEditingController();
    final pwdCtrl = TextEditingController();
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Créer un utilisateur',
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
                _field('Prénom', CupertinoIcons.person, firstCtrl),
                const SizedBox(height: 10),
                _field('Nom', CupertinoIcons.person_2, lastCtrl),
                const SizedBox(height: 10),
                _field('Nom d\'utilisateur', CupertinoIcons.at, usernameCtrl),
                const SizedBox(height: 10),
                _field(
                  'Email',
                  CupertinoIcons.envelope,
                  emailCtrl,
                  keyboard: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                _field(
                  'Mot de passe',
                  CupertinoIcons.lock,
                  pwdCtrl,
                  obscure: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        _validateEmail(emailCtrl.text.trim());
                        _validatePassword(pwdCtrl.text.trim());
                        await _authService.signUp(
                          email: emailCtrl.text.trim(),
                          password: pwdCtrl.text.trim(),
                          firstName: firstCtrl.text.trim(),
                          lastName: lastCtrl.text.trim(),
                          username: usernameCtrl.text.trim(),
                        );
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Utilisateur créé')),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                      }
                    },
                    icon: const Icon(
                      CupertinoIcons.person_crop_circle_badge_plus,
                    ),
                    label: const Text('Créer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                      foregroundColor: AppConstants.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _field(
    String label,
    IconData icon,
    TextEditingController c, {
    bool obscure = false,
    TextInputType? keyboard,
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
              controller: c,
              obscureText: obscure,
              keyboardType: keyboard,
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
}
