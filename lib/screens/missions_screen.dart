import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../components/custom_card.dart';
import '../components/custom_button.dart';
import '../models/mission_model.dart';
import '../models/user_model.dart';
import '../services/mission_service.dart';

class MissionsScreen extends StatefulWidget {
  final UserModel currentUser;

  const MissionsScreen({super.key, required this.currentUser});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen>
    with TickerProviderStateMixin {
  final MissionService _missionService = MissionService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  late TabController _tabController;
  List<MissionModel> _missions = [];
  bool _isLoading = true;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    setState(() => _isLoading = true);

    try {
      final missions = await _missionService.getUserMissions(
        widget.currentUser.id,
      );
      final stats = await _missionService.getMissionStats(
        widget.currentUser.id,
      );

      setState(() {
        _missions = missions;
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

  void _updateMissionStatus(MissionModel mission, String newStatus) async {
    try {
      await _missionService.updateMissionStatus(
        mission.id,
        newStatus,
        startDate: newStatus == 'in_progress' ? DateTime.now() : null,
        endDate: newStatus == 'completed' ? DateTime.now() : null,
      );

      await _loadMissions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mission ${newStatus == 'in_progress' ? 'démarrée' : 'terminée'}',
            ),
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

  void _showMissionDetails(MissionModel mission) {
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
                    mission.title,
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Statut et priorité
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            mission.status,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _getStatusColor(mission.status),
                          ),
                        ),
                        child: Text(
                          mission.statusDisplayName,
                          style: GoogleFonts.poppins(
                            color: _getStatusColor(mission.status),
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
                          color: _getPriorityColor(
                            mission.priority,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _getPriorityColor(mission.priority),
                          ),
                        ),
                        child: Text(
                          mission.priorityDisplayName,
                          style: GoogleFonts.poppins(
                            color: _getPriorityColor(mission.priority),
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
                    mission.description,
                    style: GoogleFonts.poppins(
                      color: AppConstants.textGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informations
                  _buildInfoRow('Zone', mission.zone),
                  _buildInfoRow(
                    'Créée le',
                    _dateFormat.format(mission.createdAt),
                  ),
                  if (mission.dueDate != null)
                    _buildInfoRow(
                      'Échéance',
                      _dateFormat.format(mission.dueDate!),
                    ),
                  if (mission.startDate != null)
                    _buildInfoRow(
                      'Démarrée le',
                      _dateFormat.format(mission.startDate!),
                    ),
                  if (mission.endDate != null)
                    _buildInfoRow(
                      'Terminée le',
                      _dateFormat.format(mission.endDate!),
                    ),

                  // Matériels requis
                  if (mission.requiredMaterials.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Matériels requis',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...mission.requiredMaterials.map(
                      (material) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              color: AppConstants.primaryGreen,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              material,
                              style: GoogleFonts.poppins(
                                color: AppConstants.textGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Actions
                  if (mission.isPending || mission.isInProgress) ...[
                    Row(
                      children: [
                        if (mission.isPending)
                          Expanded(
                            child: CustomButton(
                              text: 'Démarrer',
                              onPressed: () {
                                Navigator.pop(context);
                                _updateMissionStatus(mission, 'in_progress');
                              },
                              // backgroundColor: AppConstants.primaryGreen,
                            ),
                          ),
                        if (mission.isPending) const SizedBox(width: 12),
                        if (mission.isInProgress)
                          Expanded(
                            child: CustomButton(
                              text: 'Terminer',
                              onPressed: () {
                                Navigator.pop(context);
                                _updateMissionStatus(mission, 'completed');
                              },
                              // backgroundColor: AppConstants.primaryGreen,
                            ),
                          ),
                      ],
                    ),
                  ],
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
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return AppConstants.primaryGreen;
      case 'cancelled':
        return Colors.red;
      default:
        return AppConstants.textGrey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.purple;
      default:
        return AppConstants.textGrey;
    }
  }

  List<MissionModel> _getFilteredMissions() {
    switch (_tabController.index) {
      case 0:
        return _missions;
      case 1:
        return _missions.where((m) => m.isPending).toList();
      case 2:
        return _missions.where((m) => m.isInProgress).toList();
      case 3:
        return _missions.where((m) => m.isCompleted).toList();
      default:
        return _missions;
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
          'Mes Missions',
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
            onPressed: _loadMissions,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.primaryGreen,
          labelColor: AppConstants.primaryGreen,
          unselectedLabelColor: AppConstants.textGrey,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'En attente'),
            Tab(text: 'En cours'),
            Tab(text: 'Terminées'),
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
                            'En cours',
                            '${_stats['in_progress'] ?? 0}',
                          ),
                          _buildStatItem(
                            'Terminées',
                            '${_stats['completed'] ?? 0}',
                          ),
                          _buildStatItem(
                            'En retard',
                            '${_stats['overdue'] ?? 0}',
                          ),
                        ],
                      ),
                    ),

                  // Liste des missions
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: List.generate(4, (index) {
                        final filteredMissions = _getFilteredMissions();

                        if (filteredMissions.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.doc_text,
                                  size: 64,
                                  color: AppConstants.textGrey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucune mission',
                                  style: GoogleFonts.poppins(
                                    color: AppConstants.textGrey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredMissions.length,
                          itemBuilder: (context, index) {
                            final mission = filteredMissions[index];
                            return _buildMissionCard(mission);
                          },
                        );
                      }),
                    ),
                  ),
                ],
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

  Widget _buildMissionCard(MissionModel mission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: () => _showMissionDetails(mission),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mission.title,
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      mission.status,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(mission.status)),
                  ),
                  child: Text(
                    mission.statusDisplayName,
                    style: GoogleFonts.poppins(
                      color: _getStatusColor(mission.status),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mission.description,
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
                  CupertinoIcons.location,
                  color: AppConstants.primaryGreen,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  mission.zone,
                  style: GoogleFonts.poppins(
                    color: AppConstants.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (mission.dueDate != null) ...[
                  Icon(
                    CupertinoIcons.time,
                    color:
                        mission.isOverdue ? Colors.red : AppConstants.textGrey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _dateFormat.format(mission.dueDate!),
                    style: GoogleFonts.poppins(
                      color:
                          mission.isOverdue
                              ? Colors.red
                              : AppConstants.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            if (mission.isOverdue) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'En retard',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
