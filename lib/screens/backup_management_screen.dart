import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../components/custom_card.dart';
import '../components/custom_button.dart';
import '../components/custom_dropdown.dart';
import '../components/custom_input.dart';
import '../models/backup_model.dart';
import '../models/user_model.dart';
import '../services/backup_service.dart';

class BackupManagementScreen extends StatefulWidget {
  final UserModel currentUser;

  const BackupManagementScreen({super.key, required this.currentUser});

  @override
  State<BackupManagementScreen> createState() => _BackupManagementScreenState();
}

class _BackupManagementScreenState extends State<BackupManagementScreen>
    with TickerProviderStateMixin {
  final BackupService _backupService = BackupService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  late TabController _tabController;
  List<BackupModel> _backups = [];
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  String _selectedBackupType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBackups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);

    try {
      final backups = await _backupService.getAllBackups();
      final stats = await _backupService.getBackupStats();

      setState(() {
        _backups = backups;
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

  void _showCreateBackupDialog() {
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
            child: _CreateBackupForm(
              currentUser: widget.currentUser,
              onBackupCreated: () {
                Navigator.pop(context);
                _loadBackups();
              },
            ),
          ),
    );
  }

  void _showBackupDetails(BackupModel backup) {
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
                    'Détails de la Sauvegarde',
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
                            backup.status,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _getStatusColor(backup.status),
                          ),
                        ),
                        child: Text(
                          backup.statusDisplayName,
                          style: GoogleFonts.poppins(
                            color: _getStatusColor(backup.status),
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
                          backup.backupTypeDisplayName,
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
                  if (backup.description.isNotEmpty) ...[
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
                      backup.description,
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Informations
                  _buildInfoRow('Créé par', backup.createdByUserName),
                  _buildInfoRow(
                    'Créé le',
                    _dateFormat.format(backup.createdAt),
                  ),
                  if (backup.startedAt != null)
                    _buildInfoRow(
                      'Démarré le',
                      _dateFormat.format(backup.startedAt!),
                    ),
                  if (backup.completedAt != null)
                    _buildInfoRow(
                      'Terminé le',
                      _dateFormat.format(backup.completedAt!),
                    ),
                  if (backup.failedAt != null)
                    _buildInfoRow(
                      'Échoué le',
                      _dateFormat.format(backup.failedAt!),
                    ),
                  if (backup.filePath != null && backup.filePath!.isNotEmpty)
                    _buildInfoRow('Fichier', backup.filePath!),
                  if (backup.fileSize > 0)
                    _buildInfoRow('Taille', _formatFileSize(backup.fileSize)),

                  // Métadonnées
                  if (backup.metadata.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Métadonnées',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.lightGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        backup.metadata.toString(),
                        style: GoogleFonts.poppins(
                          color: AppConstants.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],

                  // Message d'erreur
                  if (backup.errorMessage != null &&
                      backup.errorMessage!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Message d\'erreur',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        backup.errorMessage!,
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Actions
                  if (backup.status == 'completed') ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Restaurer',
                            onPressed: () {
                              Navigator.pop(context);
                              _restoreBackup(backup);
                            },
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Télécharger',
                            onPressed: () {
                              Navigator.pop(context);
                              _downloadBackup(backup);
                            },
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
            width: 100,
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
        return Colors.grey;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return AppConstants.primaryGreen;
      case 'failed':
        return Colors.red;
      default:
        return AppConstants.textGrey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _restoreBackup(BackupModel backup) {
    showDialog(
      context: context,
      builder:
          (context) => _RestoreBackupDialog(
            backup: backup,
            currentUser: widget.currentUser,
            onRestored: () {
              _loadBackups();
            },
          ),
    );
  }

  void _downloadBackup(BackupModel backup) {
    // TODO: Implémenter le téléchargement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de téléchargement à venir'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  List<BackupModel> _getFilteredBackups() {
    List<BackupModel> filtered = _backups;

    // Filtrage par statut
    switch (_tabController.index) {
      case 0:
        break; // Tous
      case 1:
        filtered = filtered.where((b) => b.status == 'completed').toList();
        break;
      case 2:
        filtered = filtered.where((b) => b.status == 'in_progress').toList();
        break;
      case 3:
        filtered = filtered.where((b) => b.status == 'failed').toList();
        break;
    }

    // Filtrage par type
    if (_selectedBackupType != 'all') {
      filtered =
          filtered.where((b) => b.backupType == _selectedBackupType).toList();
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
          'Gestion des Sauvegardes',
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
            onPressed: _loadBackups,
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
            Tab(text: 'Terminées'),
            Tab(text: 'En cours'),
            Tab(text: 'Échouées'),
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
                      value: _selectedBackupType,
                      items: const [
                        'all',
                        'full',
                        'incremental',
                        'data_only',
                        'users_only',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedBackupType = value!;
                        });
                      },
                      label: 'Type de sauvegarde',
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
                          _buildStatItem('Total', '${_stats['total'] ?? 0}'),
                          _buildStatItem(
                            'Terminées',
                            '${_stats['completed'] ?? 0}',
                          ),
                          _buildStatItem(
                            'En cours',
                            '${_stats['inProgress'] ?? 0}',
                          ),
                          _buildStatItem(
                            'Échouées',
                            '${_stats['failed'] ?? 0}',
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Liste des sauvegardes
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: List.generate(4, (index) {
                        final filteredBackups = _getFilteredBackups();

                        if (filteredBackups.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.cloud,
                                  size: 64,
                                  color: AppConstants.textGrey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucune sauvegarde',
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
                          itemCount: filteredBackups.length,
                          itemBuilder: (context, index) {
                            final backup = filteredBackups[index];
                            return _buildBackupCard(backup);
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateBackupDialog,
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

  Widget _buildBackupCard(BackupModel backup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: () => _showBackupDetails(backup),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    backup.description.isNotEmpty
                        ? backup.description
                        : 'Sauvegarde ${backup.backupTypeDisplayName}',
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
                      backup.status,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(backup.status)),
                  ),
                  child: Text(
                    backup.statusDisplayName,
                    style: GoogleFonts.poppins(
                      color: _getStatusColor(backup.status),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Créé par ${backup.createdByUserName}',
              style: GoogleFonts.poppins(
                color: AppConstants.textGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  CupertinoIcons.cloud,
                  color: AppConstants.primaryGreen,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  backup.backupTypeDisplayName,
                  style: GoogleFonts.poppins(
                    color: AppConstants.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (backup.fileSize > 0) ...[
                  Icon(
                    CupertinoIcons.doc,
                    color: AppConstants.textGrey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatFileSize(backup.fileSize),
                    style: GoogleFonts.poppins(
                      color: AppConstants.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Icon(
                  CupertinoIcons.time,
                  color: AppConstants.textGrey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _dateFormat.format(backup.createdAt),
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
    );
  }
}

class _CreateBackupForm extends StatefulWidget {
  final UserModel currentUser;
  final VoidCallback onBackupCreated;

  const _CreateBackupForm({
    required this.currentUser,
    required this.onBackupCreated,
  });

  @override
  State<_CreateBackupForm> createState() => _CreateBackupFormState();
}

class _CreateBackupFormState extends State<_CreateBackupForm> {
  final BackupService _backupService = BackupService();
  final _descriptionController = TextEditingController();

  String _selectedBackupType = 'full';
  bool _isLoading = false;

  final List<String> _backupTypes = [
    'full',
    'incremental',
    'data_only',
    'users_only',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String _getBackupTypeDisplayName(String type) {
    switch (type) {
      case 'full':
        return 'Complète';
      case 'incremental':
        return 'Incrémentale';
      case 'data_only':
        return 'Données uniquement';
      case 'users_only':
        return 'Utilisateurs uniquement';
      default:
        return type;
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);

    try {
      if (_selectedBackupType == 'full') {
        await _backupService.performFullBackup(
          createdByUserId: widget.currentUser.id,
          createdByUserName: widget.currentUser.fullName,
          description:
              _descriptionController.text.trim().isNotEmpty
                  ? _descriptionController.text.trim()
                  : 'Sauvegarde complète manuelle',
        );
      } else if (_selectedBackupType == 'incremental') {
        await _backupService.performIncrementalBackup(
          createdByUserId: widget.currentUser.id,
          createdByUserName: widget.currentUser.fullName,
          description:
              _descriptionController.text.trim().isNotEmpty
                  ? _descriptionController.text.trim()
                  : 'Sauvegarde incrémentale manuelle',
        );
      } else {
        await _backupService.createBackup(
          createdByUserId: widget.currentUser.id,
          createdByUserName: widget.currentUser.fullName,
          backupType: _selectedBackupType,
          description:
              _descriptionController.text.trim().isNotEmpty
                  ? _descriptionController.text.trim()
                  : 'Sauvegarde ${_getBackupTypeDisplayName(_selectedBackupType).toLowerCase()} manuelle',
        );
      }

      widget.onBackupCreated();
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
            'Nouvelle Sauvegarde',
            style: GoogleFonts.poppins(
              color: AppConstants.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Formulaire
          CustomDropdown(
            value: _selectedBackupType,
            items: _backupTypes,
            onChanged: (value) {
              setState(() {
                _selectedBackupType = value!;
              });
            },
            label: 'Type de sauvegarde',
          ),
          const SizedBox(height: 16),

          CustomInput(
            controller: _descriptionController,
            label: 'Description (optionnel)',
            hint: 'Description de la sauvegarde',
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
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: _isLoading ? 'Création...' : 'Créer',
                  onPressed: _isLoading ? null : _createBackup,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RestoreBackupDialog extends StatefulWidget {
  final BackupModel backup;
  final UserModel currentUser;
  final VoidCallback onRestored;

  const _RestoreBackupDialog({
    required this.backup,
    required this.currentUser,
    required this.onRestored,
  });

  @override
  State<_RestoreBackupDialog> createState() => _RestoreBackupDialogState();
}

class _RestoreBackupDialogState extends State<_RestoreBackupDialog> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;

  Future<void> _restoreBackup() async {
    setState(() => _isLoading = true);

    try {
      await _backupService.restoreBackup(
        widget.backup.id,
        widget.currentUser.id,
        widget.currentUser.fullName,
      );

      widget.onRestored();
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppConstants.primaryBlack,
      title: Text(
        'Restaurer la sauvegarde',
        style: GoogleFonts.poppins(
          color: AppConstants.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Êtes-vous sûr de vouloir restaurer cette sauvegarde ?',
            style: GoogleFonts.poppins(
              color: AppConstants.textGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette action va remplacer toutes les données actuelles.',
            style: GoogleFonts.poppins(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Annuler',
            style: GoogleFonts.poppins(color: AppConstants.textGrey),
          ),
        ),
        CustomButton(
          text: _isLoading ? 'Restauration...' : 'Restaurer',
          onPressed: _isLoading ? null : _restoreBackup,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
