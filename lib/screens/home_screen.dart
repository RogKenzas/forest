import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../components/custom_card.dart';
import '../components/custom_bottom_navbar.dart';
import '../models/data_collection_model.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final FirestoreService _firestoreService = FirestoreService();
  final DateFormat _dateFormat = DateFormat('dd/MM HH:mm');
  bool _isLoadingRecent = true;
  List<DataCollectionModel> _recentChantiers = [];

  @override
  void initState() {
    super.initState();
    _loadRecentChantiers();
  }

  Future<void> _loadRecentChantiers() async {
    setState(() => _isLoadingRecent = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _recentChantiers = [];
        _isLoadingRecent = false;
      });
      return;
    }
    final items = await _firestoreService.getDataCollectionsByUser(user.uid);
    setState(() {
      _recentChantiers = items.take(5).toList();
      _isLoadingRecent = false;
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 1) Navigator.pushNamed(context, '/inventory');
    if (index == 2) Navigator.pushNamed(context, '/data-collection');
  }

  void _onAddTap() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            height: 300,
            decoration: BoxDecoration(
              color: AppConstants.lightGrey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
    );
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
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppConstants.white,
                    backgroundImage: const AssetImage("assets/logo/box.png"),
                  ),
                  const SizedBox(width: 12),

                  Row(
                    children: [
                      Stack(
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
                              _onAddTap();
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

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

            // Stats Cards (inchangés)
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
                            child: Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: AppConstants.primaryGreen,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '0',
                            style: GoogleFonts.poppins(
                              color: AppConstants.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'En Rupture',
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
                            child: Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: Icon(
                                Icons.warning_amber_outlined,
                                color: AppConstants.primaryGreen,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '300',
                            style: GoogleFonts.poppins(
                              color: AppConstants.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Stock faible',
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
                            child: Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: Icon(
                                Icons.inventory,
                                color: AppConstants.primaryGreen,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '0',
                            style: GoogleFonts.poppins(
                              color: AppConstants.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Total',
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
                            final title = d.chantier;
                            final user = d.essence;
                            final time = _dateFormat.format(d.date);
                            final stockCount = d.bloc; // affichage côté droit
                            return _buildDocumentCard(
                              title,
                              user,
                              time,
                              stockCount,
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildDocumentCard(
    String title,
    String user,
    String time,
    int stockCount,
  ) {
    return CustomCard(
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
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppConstants.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppConstants.textGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: AppConstants.textGrey,
                    fontSize: 11,
                  ),
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
                  '$stockCount',
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
    );
  }
}
