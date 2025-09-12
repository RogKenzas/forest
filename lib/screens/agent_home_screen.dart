import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forest/screens/notifications_screen.dart';
import 'package:forest/screens/settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../constants/app_constants.dart';
import '../components/custom_card.dart';
import '../components/role_based_navbar.dart';
import '../models/data_collection_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/navigation_helper.dart';
import '../services/pdf_service.dart';
import '../services/auth_service.dart';
import 'inventory_screen.dart';
import 'data_collection_screen.dart';
import 'profile_screen.dart';
import 'missions_screen.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  int _currentIndex = 0;

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final DateFormat _dateFormat = DateFormat('dd/MM HH:mm');
  bool _isLoadingRecent = true;
  List<DataCollectionModel> _recentChantiers = [];
  Map<String, UserModel> _userCache = {};
  StreamSubscription<int>? _alertsSub;
  UserModel? _currentUser;

  int _totalReleves = 0;
  int _distinctEspeces = 0;
  int _unreadAlerts = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadRecentChantiers();
    _listenAlerts();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadRecentChantiers() async {
    setState(() => _isLoadingRecent = true);

    final items = await _firestoreService.getRecentDataCollections(limit: 20);
    final userIds = items.map((e) => e.userId).toSet().toList();
    final userMap = await _firestoreService.getUsersByIds(userIds);

    setState(() {
      _recentChantiers = items.take(10).toList();
      _userCache = userMap;
      _totalReleves = items.length;
      _distinctEspeces = items.map((e) => e.essence).toSet().length;
      _unreadAlerts = 0;
      _isLoadingRecent = false;
    });
  }

  void _listenAlerts() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _alertsSub?.cancel();
    _alertsSub = _firestoreService.streamAlertsForUser(user.uid).listen((
      count,
    ) {
      if (!mounted) return;
      setState(() => _unreadAlerts = count);
    });
  }

  @override
  void dispose() {
    try {
      _alertsSub?.cancel();
    } catch (_) {}
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      return;
    }
    if (index == 1) {
      NavigationHelper.pushReplacementFade(context, const InventoryScreen());
      return;
    }
    if (index == 2) {
      NavigationHelper.pushReplacementFade(
        context,
        const DataCollectionScreen(),
      );
      return;
    }
    if (index == 3) {
      NavigationHelper.pushReplacementFade(context, const SettingsScreen());
      return;
    }
    if (index == 4) {
      NavigationHelper.pushReplacementFade(context, const ProfileScreen());
      return;
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppConstants.white,
                        backgroundImage: const AssetImage(
                          "assets/logo/box.png",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Agent de Terrain',
                            style: GoogleFonts.poppins(
                              color: AppConstants.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_currentUser != null)
                            Text(
                              'Bonjour, ${_currentUser!.firstName}',
                              style: GoogleFonts.poppins(
                                color: AppConstants.textGrey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
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
                        child: Stack(
                          children: [
                            Container(
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
                            if (_unreadAlerts > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppConstants.darkGrey,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              // Action pour ajouter
                            },
                            child: Icon(
                              Icons.add,
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

            // Fonctionnalités Agent de Terrain
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
              child: _buildAgentFeatures(),
            ),
            const SizedBox(height: 20),

            // Statistiques
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
                                CupertinoIcons.map,
                                color: AppConstants.primaryGreen,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_totalReleves',
                            style: GoogleFonts.poppins(
                              color: AppConstants.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Total Relevés',
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
                                CupertinoIcons.helm,
                                color: AppConstants.primaryGreen,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_distinctEspeces',
                            style: GoogleFonts.poppins(
                              color: AppConstants.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Espèces',
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
                          GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationsScreen(),
                                  ),
                                ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppConstants.darkGrey,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(13.0),
                                child: Icon(
                                  CupertinoIcons.bell,
                                  color: AppConstants.primaryGreen,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_unreadAlerts',
                            style: GoogleFonts.poppins(
                              color: AppConstants.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Alertes',
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

            // Titre section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chantiers Récents',
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Voir Tout',
                    style: GoogleFonts.poppins(
                      color: AppConstants.primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Liste chantiers
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child:
                    _isLoadingRecent
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppConstants.primaryGreen,
                          ),
                        )
                        : (_recentChantiers.isEmpty)
                        ? Center(
                          child: Text(
                            "Aucun chantier pour l'instant",
                            style: GoogleFonts.poppins(
                              color: AppConstants.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        )
                        : ListView.separated(
                          itemCount: _recentChantiers.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final d = _recentChantiers[index];
                            final author = _userCache[d.userId];
                            final me = FirebaseAuth.instance.currentUser?.uid;
                            final displayName =
                                (author == null)
                                    ? 'Inconnu'
                                    : (author.id == me
                                        ? 'vous'
                                        : '@${author.username.isNotEmpty ? author.username : author.fullName}');
                            return _buildDocumentCard(d, displayName, author);
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: RoleBasedNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        userRole: UserRole.agent,
      ),
    );
  }

  Widget _buildAgentFeatures() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: CupertinoIcons.doc_text,
          title: 'Mes Missions',
          subtitle: 'Consulter et gérer vos missions',
          onTap: () {
            if (_currentUser != null) {
              NavigationHelper.pushFade(
                context,
                MissionsScreen(currentUser: _currentUser!),
              );
            }
          },
        ),
        _buildFeatureCard(
          icon: CupertinoIcons.arrow_clockwise,
          title: 'Synchronisation',
          subtitle: 'Synchroniser vos données',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fonctionnalité de synchronisation à venir'),
                backgroundColor: AppConstants.primaryGreen,
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
                color: AppConstants.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppConstants.primaryGreen, size: 24),
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

  Widget _buildDocumentCard(
    DataCollectionModel d,
    String displayName,
    UserModel? author,
  ) {
    return GestureDetector(
      onTap: () => _openPrintSheet(d),
      child: CustomCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppConstants.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.helm,
                color: AppConstants.primaryGreen,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.chantier,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          color: AppConstants.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '  •  ${_dateFormat.format(d.date)}',
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${d.bloc}',
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bloc',
                  style: GoogleFonts.poppins(
                    color: AppConstants.textGrey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openPrintSheet(DataCollectionModel d) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.primaryBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
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
                  Text(
                    'Impression du chantier',
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 16,
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
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      CupertinoIcons.doc_plaintext,
                      color: AppConstants.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.chantier,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppConstants.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_dateFormat.format(d.date)} • ${d.essence} • Bloc ${d.bloc}',
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final names =
                            d.materielsNecessaires
                                .map((e) => (e['name'] ?? '').toString())
                                .where((s) => s.isNotEmpty)
                                .toList();
                        final pdfBytes = await PdfService.buildChantierReport(
                          chantier: d.chantier,
                          date: d.date,
                          essence: d.essence,
                          bloc: d.bloc,
                          ufe: d.ufe,
                          acc: d.acc,
                          materiels: names,
                          consommations: const [],
                          observations: d.observation,
                        );
                        await Printing.layoutPdf(
                          onLayout: (_) async => pdfBytes,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryGreen,
                        foregroundColor: AppConstants.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(CupertinoIcons.printer),
                      label: Text(
                        'Aperçu & impression',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final names =
                            d.materielsNecessaires
                                .map((e) => (e['name'] ?? '').toString())
                                .where((s) => s.isNotEmpty)
                                .toList();
                        final pdfBytes = await PdfService.buildChantierReport(
                          chantier: d.chantier,
                          date: d.date,
                          essence: d.essence,
                          bloc: d.bloc,
                          ufe: d.ufe,
                          acc: d.acc,
                          materiels: names,
                          consommations: const [],
                          observations: d.observation,
                        );
                        await Printing.sharePdf(
                          bytes: pdfBytes,
                          filename: 'chantier_${d.chantier}.pdf',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppConstants.textGrey),
                        foregroundColor: AppConstants.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(CupertinoIcons.paperplane),
                      label: Text(
                        'Partager PDF',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}
