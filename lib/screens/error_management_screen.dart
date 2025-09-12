import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../components/custom_card.dart';
import '../components/custom_button.dart';
import '../components/custom_input.dart';
import '../components/custom_dropdown.dart';
import '../models/error_log_model.dart';
import '../models/user_model.dart';
import '../services/error_service.dart';

class ErrorManagementScreen extends StatefulWidget {
  final UserModel currentUser;

  const ErrorManagementScreen({super.key, required this.currentUser});

  @override
  State<ErrorManagementScreen> createState() => _ErrorManagementScreenState();
}

class _ErrorManagementScreenState extends State<ErrorManagementScreen>
    with TickerProviderStateMixin {
  final ErrorService _errorService = ErrorService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  late TabController _tabController;
  List<ErrorLogModel> _errorLogs = [];
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  String _selectedSeverity = 'all';
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadErrorLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadErrorLogs() async {
    setState(() => _isLoading = true);

    try {
      final errorLogs = await _errorService.getAllErrorLogs();
      final stats = await _errorService.getErrorStats();

      setState(() {
        _errorLogs = errorLogs;
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

  void _showCreateErrorDialog() {
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
            child: _CreateErrorForm(
              currentUser: widget.currentUser,
              onErrorCreated: () {
                Navigator.pop(context);
                _loadErrorLogs();
              },
            ),
          ),
    );
  }

  void _showErrorDetails(ErrorLogModel errorLog) {
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
                    errorLog.title,
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Statut et gravité
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            errorLog.status,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _getStatusColor(errorLog.status),
                          ),
                        ),
                        child: Text(
                          errorLog.statusDisplayName,
                          style: GoogleFonts.poppins(
                            color: _getStatusColor(errorLog.status),
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
                          color: _getSeverityColor(
                            errorLog.severity,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _getSeverityColor(errorLog.severity),
                          ),
                        ),
                        child: Text(
                          errorLog.severityDisplayName,
                          style: GoogleFonts.poppins(
                            color: _getSeverityColor(errorLog.severity),
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
                    errorLog.description,
                    style: GoogleFonts.poppins(
                      color: AppConstants.textGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informations
                  _buildInfoRow('Type', errorLog.errorTypeDisplayName),
                  _buildInfoRow('Signalé par', errorLog.reportedByUserName),
                  _buildInfoRow(
                    'Signalé le',
                    _dateFormat.format(errorLog.createdAt),
                  ),
                  if (errorLog.assignedToUserName?.isNotEmpty == true)
                    _buildInfoRow('Assigné à', errorLog.assignedToUserName!),
                  if (errorLog.resolvedAt != null)
                    _buildInfoRow(
                      'Résolu le',
                      _dateFormat.format(errorLog.resolvedAt!),
                    ),
                  if (errorLog.closedAt != null)
                    _buildInfoRow(
                      'Fermé le',
                      _dateFormat.format(errorLog.closedAt!),
                    ),

                  // Stack trace
                  if (errorLog.stackTrace.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Stack Trace',
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
                        errorLog.stackTrace,
                        style: GoogleFonts.poppins(
                          color: AppConstants.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],

                  // Résolution
                  if (errorLog.resolution.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Résolution',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorLog.resolution,
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Actions
                  if (errorLog.isOpen || errorLog.isInvestigating) ...[
                    Row(
                      children: [
                        if (errorLog.isOpen)
                          Expanded(
                            child: CustomButton(
                              text: 'Assigner',
                              onPressed: () {
                                Navigator.pop(context);
                                _assignError(errorLog);
                              },
                              isOutlined: true,
                            ),
                          ),
                        if (errorLog.isOpen) const SizedBox(width: 12),
                        if (errorLog.isInvestigating)
                          Expanded(
                            child: CustomButton(
                              text: 'Résoudre',
                              onPressed: () {
                                Navigator.pop(context);
                                _resolveError(errorLog);
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
      case 'open':
        return Colors.red;
      case 'investigating':
        return Colors.orange;
      case 'resolved':
        return AppConstants.primaryGreen;
      case 'closed':
        return Colors.grey;
      default:
        return AppConstants.textGrey;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return AppConstants.textGrey;
    }
  }

  void _assignError(ErrorLogModel errorLog) {
    // TODO: Implémenter l'assignation d'erreur
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'assignation à venir'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _resolveError(ErrorLogModel errorLog) {
    showDialog(
      context: context,
      builder:
          (context) => _ResolveErrorDialog(
            errorLog: errorLog,
            onResolved: () {
              _loadErrorLogs();
            },
          ),
    );
  }

  List<ErrorLogModel> _getFilteredErrorLogs() {
    List<ErrorLogModel> filtered = _errorLogs;

    // Filtrage par statut
    switch (_tabController.index) {
      case 0:
        break; // Tous
      case 1:
        filtered = filtered.where((e) => e.isOpen).toList();
        break;
      case 2:
        filtered = filtered.where((e) => e.isInvestigating).toList();
        break;
      case 3:
        filtered = filtered.where((e) => e.isResolved).toList();
        break;
    }

    // Filtrage par gravité
    if (_selectedSeverity != 'all') {
      filtered =
          filtered.where((e) => e.severity == _selectedSeverity).toList();
    }

    // Filtrage par type
    if (_selectedType != 'all') {
      filtered = filtered.where((e) => e.errorType == _selectedType).toList();
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
          'Gestion des Erreurs',
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
            onPressed: _loadErrorLogs,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.primaryGreen,
          labelColor: AppConstants.primaryGreen,
          unselectedLabelColor: AppConstants.textGrey,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Tous'),
            Tab(text: 'Ouverts'),
            Tab(text: 'En cours'),
            Tab(text: 'Résolus'),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomDropdown(
                            value: _selectedSeverity,
                            items: const [
                              'all',
                              'low',
                              'medium',
                              'high',
                              'critical',
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedSeverity = value!;
                              });
                            },
                            label: 'Gravité',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomDropdown(
                            value: _selectedType,
                            items: const [
                              'all',
                              'system',
                              'data',
                              'user',
                              'network',
                              'sync',
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                            label: 'Type',
                          ),
                        ),
                      ],
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
                          _buildStatItem('Ouverts', '${_stats['open'] ?? 0}'),
                          _buildStatItem(
                            'En cours',
                            '${_stats['investigating'] ?? 0}',
                          ),
                          _buildStatItem(
                            'Résolus',
                            '${_stats['resolved'] ?? 0}',
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Liste des erreurs
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: List.generate(4, (index) {
                        final filteredErrors = _getFilteredErrorLogs();

                        if (filteredErrors.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.exclamationmark_triangle,
                                  size: 64,
                                  color: AppConstants.textGrey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucune erreur',
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
                          itemCount: filteredErrors.length,
                          itemBuilder: (context, index) {
                            final errorLog = filteredErrors[index];
                            return _buildErrorCard(errorLog);
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateErrorDialog,
        backgroundColor: Colors.red,
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

  Widget _buildErrorCard(ErrorLogModel errorLog) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: () => _showErrorDetails(errorLog),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    errorLog.title,
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
                      errorLog.status,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(errorLog.status)),
                  ),
                  child: Text(
                    errorLog.statusDisplayName,
                    style: GoogleFonts.poppins(
                      color: _getStatusColor(errorLog.status),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              errorLog.description,
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
                  CupertinoIcons.exclamationmark_triangle,
                  color: _getSeverityColor(errorLog.severity),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  errorLog.severityDisplayName,
                  style: GoogleFonts.poppins(
                    color: _getSeverityColor(errorLog.severity),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  CupertinoIcons.tag,
                  color: AppConstants.primaryGreen,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  errorLog.errorTypeDisplayName,
                  style: GoogleFonts.poppins(
                    color: AppConstants.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  CupertinoIcons.time,
                  color: AppConstants.textGrey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _dateFormat.format(errorLog.createdAt),
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

class _CreateErrorForm extends StatefulWidget {
  final UserModel currentUser;
  final VoidCallback onErrorCreated;

  const _CreateErrorForm({
    required this.currentUser,
    required this.onErrorCreated,
  });

  @override
  State<_CreateErrorForm> createState() => _CreateErrorFormState();
}

class _CreateErrorFormState extends State<_CreateErrorForm> {
  final ErrorService _errorService = ErrorService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stackTraceController = TextEditingController();

  String _selectedErrorType = 'system';
  String _selectedSeverity = 'medium';
  bool _isLoading = false;

  final List<String> _errorTypes = [
    'system',
    'data',
    'user',
    'network',
    'sync',
  ];

  final List<String> _severities = ['low', 'medium', 'high', 'critical'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stackTraceController.dispose();
    super.dispose();
  }

  Future<void> _createError() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _errorService.createErrorLog(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        errorType: _selectedErrorType,
        severity: _selectedSeverity,
        reportedByUserId: widget.currentUser.id,
        reportedByUserName: widget.currentUser.fullName,
        stackTrace: _stackTraceController.text.trim(),
      );

      widget.onErrorCreated();
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
              'Signaler une Erreur',
              style: GoogleFonts.poppins(
                color: AppConstants.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Formulaire
            CustomInput(
              controller: _titleController,
              label: 'Titre de l\'erreur',
              hint: 'Entrez un titre descriptif',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le titre est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomInput(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Décrivez l\'erreur en détail',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La description est requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomDropdown(
                    value: _selectedErrorType,
                    items: _errorTypes,
                    onChanged: (value) {
                      setState(() {
                        _selectedErrorType = value!;
                      });
                    },
                    label: 'Type',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomDropdown(
                    value: _selectedSeverity,
                    items: _severities,
                    onChanged: (value) {
                      setState(() {
                        _selectedSeverity = value!;
                      });
                    },
                    label: 'Gravité',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomInput(
              controller: _stackTraceController,
              label: 'Stack Trace (optionnel)',
              hint: 'Collez le stack trace ici',
              maxLines: 4,
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
                    text: _isLoading ? 'Création...' : 'Signaler',
                    onPressed: _isLoading ? null : _createError,
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

class _ResolveErrorDialog extends StatefulWidget {
  final ErrorLogModel errorLog;
  final VoidCallback onResolved;

  const _ResolveErrorDialog({required this.errorLog, required this.onResolved});

  @override
  State<_ResolveErrorDialog> createState() => _ResolveErrorDialogState();
}

class _ResolveErrorDialogState extends State<_ResolveErrorDialog> {
  final ErrorService _errorService = ErrorService();
  final _resolutionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _resolutionController.dispose();
    super.dispose();
  }

  Future<void> _resolveError() async {
    if (_resolutionController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez entrer une résolution'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _errorService.resolveErrorLog(
        widget.errorLog.id,
        _resolutionController.text.trim(),
      );

      widget.onResolved();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppConstants.primaryBlack,
      title: Text(
        'Résoudre l\'erreur',
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
            widget.errorLog.title,
            style: GoogleFonts.poppins(
              color: AppConstants.textGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          CustomInput(
            controller: _resolutionController,
            label: 'Résolution',
            hint: 'Décrivez comment l\'erreur a été résolue',
            maxLines: 4,
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
          text: _isLoading ? 'Résolution...' : 'Résoudre',
          onPressed: _isLoading ? null : _resolveError,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
