import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../components/custom_card.dart';
import '../components/custom_button.dart';
import '../components/custom_input.dart';
import '../components/custom_dropdown.dart';
import '../models/forest_zone_model.dart';
import '../models/user_model.dart';
import '../services/forest_zone_service.dart';
import '../services/firestore_service.dart';

class ForestZonesManagementScreen extends StatefulWidget {
  final UserModel currentUser;

  const ForestZonesManagementScreen({super.key, required this.currentUser});

  @override
  State<ForestZonesManagementScreen> createState() =>
      _ForestZonesManagementScreenState();
}

class _ForestZonesManagementScreenState
    extends State<ForestZonesManagementScreen>
    with TickerProviderStateMixin {
  final ForestZoneService _forestZoneService = ForestZoneService();
  final FirestoreService _firestoreService = FirestoreService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  late TabController _tabController;
  List<ForestZoneModel> _forestZones = [];
  List<UserModel> _users = [];
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final forestZones = await _forestZoneService.getAllForestZones();
      final users = await _firestoreService.getAllUsers();
      final stats = await _forestZoneService.getZoneStats();

      setState(() {
        _forestZones = forestZones;
        _users = users;
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

  void _showCreateZoneDialog() {
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
            child: _CreateZoneForm(
              currentUser: widget.currentUser,
              users: _users,
              onZoneCreated: () {
                Navigator.pop(context);
                _loadData();
              },
            ),
          ),
    );
  }

  void _showZoneDetails(ForestZoneModel zone) {
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
                    zone.name,
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        zone.status,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: _getStatusColor(zone.status)),
                    ),
                    child: Text(
                      zone.statusDisplayName,
                      style: GoogleFonts.poppins(
                        color: _getStatusColor(zone.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                    zone.description,
                    style: GoogleFonts.poppins(
                      color: AppConstants.textGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informations
                  _buildInfoRow('Localisation', zone.location),
                  _buildInfoRow(
                    'Superficie',
                    '${zone.area.toStringAsFixed(2)} ha',
                  ),
                  _buildInfoRow('Créé le', _dateFormat.format(zone.createdAt)),
                  if (zone.lastInspection != null)
                    _buildInfoRow(
                      'Dernière inspection',
                      _dateFormat.format(zone.lastInspection!),
                    ),

                  // Coordonnées
                  const SizedBox(height: 16),
                  Text(
                    'Coordonnées GPS',
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Latitude', zone.latitude.toStringAsFixed(6)),
                  _buildInfoRow('Longitude', zone.longitude.toStringAsFixed(6)),

                  // Superviseur assigné
                  if (zone.assignedSupervisorId.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Superviseur assigné',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('ID', zone.assignedSupervisorId),
                  ],

                  // Agents assignés
                  if (zone.assignedAgentIds.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Agents assignés',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...zone.assignedAgentIds.map(
                      (agentId) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.person_circle,
                              color: AppConstants.primaryGreen,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              agentId,
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
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Modifier',
                          onPressed: () {
                            Navigator.pop(context);
                            _editZone(zone);
                          },
                          isOutlined: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: zone.isActive ? 'Désactiver' : 'Activer',
                          onPressed: () {
                            Navigator.pop(context);
                            _toggleZoneStatus(zone);
                          },
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
      case 'active':
        return AppConstants.primaryGreen;
      case 'inactive':
        return Colors.grey;
      case 'maintenance':
        return Colors.orange;
      case 'restricted':
        return Colors.red;
      default:
        return AppConstants.textGrey;
    }
  }

  void _editZone(ForestZoneModel zone) {
    // TODO: Implémenter l'édition de zone
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'édition à venir'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _toggleZoneStatus(ForestZoneModel zone) async {
    try {
      final newStatus = zone.isActive ? 'inactive' : 'active';
      await _forestZoneService.updateZoneStatus(zone.id, newStatus);

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Zone ${newStatus == 'active' ? 'activée' : 'désactivée'}',
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

  List<ForestZoneModel> _getFilteredZones() {
    List<ForestZoneModel> filtered = _forestZones;

    // Filtrage par statut
    switch (_tabController.index) {
      case 0:
        break; // Tous
      case 1:
        filtered = filtered.where((z) => z.isActive).toList();
        break;
      case 2:
        filtered = filtered.where((z) => !z.isActive).toList();
        break;
    }

    // Filtrage par statut sélectionné
    if (_selectedStatus != 'all') {
      filtered = filtered.where((z) => z.status == _selectedStatus).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlack,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryBlack,
        elevation: 0,
        title: Text(
          'Gestion des Zones Forestières',
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
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'Actives'),
            Tab(text: 'Inactives'),
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
                  // Filtres
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConstants.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomDropdown(
                      value: _selectedStatus,
                      items: const [
                        'all',
                        'active',
                        'inactive',
                        'maintenance',
                        'restricted',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                      label: 'Statut',
                    ),
                  ),

                  // Statistiques
                  if (_stats.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppConstants.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total',
                            '${_stats['totalZones'] ?? 0}',
                          ),
                          _buildStatItem(
                            'Actives',
                            '${_stats['activeZones'] ?? 0}',
                          ),
                          _buildStatItem(
                            'Superficie',
                            '${(_stats['totalArea'] ?? 0.0).toStringAsFixed(1)} ha',
                          ),
                          _buildStatItem(
                            'Avec superviseur',
                            '${_stats['zonesWithSupervisor'] ?? 0}',
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Liste des zones
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: List.generate(3, (index) {
                        final filteredZones = _getFilteredZones();

                        if (filteredZones.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.tree,
                                  size: 64,
                                  color: AppConstants.textGrey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucune zone forestière',
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
                          itemCount: filteredZones.length,
                          itemBuilder: (context, index) {
                            final zone = filteredZones[index];
                            return _buildZoneCard(zone);
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateZoneDialog,
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

  Widget _buildZoneCard(ForestZoneModel zone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: () => _showZoneDetails(zone),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    zone.name,
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
                    color: _getStatusColor(zone.status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(zone.status)),
                  ),
                  child: Text(
                    zone.statusDisplayName,
                    style: GoogleFonts.poppins(
                      color: _getStatusColor(zone.status),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              zone.description,
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
                  zone.location,
                  style: GoogleFonts.poppins(
                    color: AppConstants.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  CupertinoIcons.chart_bar_square,
                  color: AppConstants.textGrey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${zone.area.toStringAsFixed(1)} ha',
                  style: GoogleFonts.poppins(
                    color: AppConstants.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (zone.hasAssignedSupervisor || zone.hasAssignedAgents) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (zone.hasAssignedSupervisor) ...[
                    Icon(
                      CupertinoIcons.person_circle,
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Superviseur',
                      style: GoogleFonts.poppins(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (zone.hasAssignedAgents) ...[
                    Icon(
                      CupertinoIcons.group,
                      color: AppConstants.primaryGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${zone.assignedAgentIds.length} agent(s)',
                      style: GoogleFonts.poppins(
                        color: AppConstants.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CreateZoneForm extends StatefulWidget {
  final UserModel currentUser;
  final List<UserModel> users;
  final VoidCallback onZoneCreated;

  const _CreateZoneForm({
    required this.currentUser,
    required this.users,
    required this.onZoneCreated,
  });

  @override
  State<_CreateZoneForm> createState() => _CreateZoneFormState();
}

class _CreateZoneFormState extends State<_CreateZoneForm> {
  final ForestZoneService _forestZoneService = ForestZoneService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _areaController = TextEditingController();

  String _selectedStatus = 'active';
  String _selectedSupervisorId = '';
  List<String> _selectedAgentIds = [];
  bool _isLoading = false;

  final List<String> _statuses = [
    'active',
    'inactive',
    'maintenance',
    'restricted',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _createZone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _forestZoneService.createForestZone(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
        area: double.parse(_areaController.text.trim()),
        status: _selectedStatus,
        assignedSupervisorId: _selectedSupervisorId,
        assignedAgentIds: _selectedAgentIds,
      );

      widget.onZoneCreated();
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
              'Nouvelle Zone Forestière',
              style: GoogleFonts.poppins(
                color: AppConstants.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Formulaire
            CustomInput(
              controller: _nameController,
              label: 'Nom de la zone',
              hint: 'Entrez le nom de la zone',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomInput(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Décrivez la zone forestière',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La description est requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomInput(
              controller: _locationController,
              label: 'Localisation',
              hint: 'Ville, région, pays',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La localisation est requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomInput(
                    controller: _latitudeController,
                    label: 'Latitude',
                    hint: '0.000000',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Latitude requise';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Latitude invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomInput(
                    controller: _longitudeController,
                    label: 'Longitude',
                    hint: '0.000000',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Longitude requise';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Longitude invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomInput(
              controller: _areaController,
              label: 'Superficie (hectares)',
              hint: '0.00',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La superficie est requise';
                }
                if (double.tryParse(value.trim()) == null) {
                  return 'Superficie invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomDropdown(
              value: _selectedStatus,
              items: _statuses,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
              label: 'Statut',
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Annuler',
                    onPressed: () => Navigator.pop(context),
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: _isLoading ? 'Création...' : 'Créer',
                    onPressed: _isLoading ? null : _createZone,
                    isLoading: _isLoading,
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
