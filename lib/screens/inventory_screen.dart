import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forest/components/custom_bottom_navbar.dart';
import 'package:forest/screens/settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../components/custom_card.dart';
import '../components/custom_input.dart';
import '../components/custom_dropdown.dart';
import '../services/navigation_helper.dart';
import 'home_screen.dart';
import 'data_collection_screen.dart';
import 'package:printing/printing.dart';
import '../services/pdf_service.dart';
import '../models/data_collection_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _currentIndex = 1;
  final FirestoreService _firestoreService = FirestoreService();

  // Matériels nécessaires et utilisés (mock local pour l'instant)
  final List<Map<String, dynamic>> _materielsUtilises = [
    {'name': 'Tronçonneuse', 'qty': 2, 'unit': 'pcs'},
    {'name': 'Bidon carburant', 'qty': 10, 'unit': 'L'},
  ];

  final List<String> _essences = const [
    'Azobé (Lophira alata)',
    'Iroko (Milicia excelsa)',
  ];

  Future<void> _smartPop() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      NavigationHelper.pushReplacementFade(context, const HomeScreen());
    }
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      NavigationHelper.pushReplacementFade(context, const HomeScreen());
      return;
    }
    if (index == 1) {
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
  }

  void _openChantierActions(DataCollectionModel d) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.lightGrey,
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
                  Text(
                    'Chantier: ${d.chantier}',
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.xmark,
                      color: AppConstants.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Matériels nécessaires',
                    style: GoogleFonts.poppins(
                      color: AppConstants.textGrey,
                      fontSize: 13,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      _openAddMaterielModal(d);
                      if (mounted) _openChantierActions(d);
                    },
                    icon: const Icon(
                      CupertinoIcons.add_circled,
                      color: AppConstants.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (d.materielsNecessaires.isEmpty)
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.info,
                      color: AppConstants.textGrey,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ajouter un matériel nécessaire',
                        style: GoogleFonts.poppins(
                          color: AppConstants.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      d.materielsNecessaires
                          .map(
                            (m) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.lightGrey,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${m['name'] ?? '-'} x ${m['qty'] ?? '-'}${(m['unit'] ?? '').toString().isEmpty ? '' : ' ${m['unit']}'}',
                                style: GoogleFonts.poppins(
                                  color: AppConstants.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              const SizedBox(height: 16),
              Text(
                'Matériels utilisés',
                style: GoogleFonts.poppins(
                  color: AppConstants.textGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    _materielsUtilises
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${e['name']}',
                                  style: GoogleFonts.poppins(
                                    color: AppConstants.white,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${e['qty']} ${e['unit']}',
                                  style: GoogleFonts.poppins(
                                    color: AppConstants.textGrey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final List<String> names =
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
                      consommations: _materielsUtilises,
                      observations:
                          'Rapport généré automatiquement depuis BoisTech',
                    );
                    await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryGreen,
                    foregroundColor: AppConstants.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(CupertinoIcons.doc_richtext),
                  label: Text(
                    'Générer le rapport PDF',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _openAddMaterielModal(DataCollectionModel d) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final unitController = TextEditingController(text: 'pcs');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConstants.darkGrey,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ajouter un matériel',
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
              TextField(
                controller: nameController,
                style: GoogleFonts.poppins(color: AppConstants.white),
                decoration: InputDecoration(
                  labelText: 'Nom du matériel',
                  labelStyle: GoogleFonts.poppins(color: AppConstants.textGrey),
                  filled: true,
                  fillColor: AppConstants.lightGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(color: AppConstants.white),
                      decoration: InputDecoration(
                        labelText: 'Quantité',
                        labelStyle: GoogleFonts.poppins(
                          color: AppConstants.textGrey,
                        ),
                        filled: true,
                        fillColor: AppConstants.lightGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: unitController,
                      style: GoogleFonts.poppins(color: AppConstants.white),
                      decoration: InputDecoration(
                        labelText: 'Unité',
                        hintText: 'pcs, L, m, ...',
                        hintStyle: GoogleFonts.poppins(
                          color: AppConstants.textGrey,
                        ),
                        labelStyle: GoogleFonts.poppins(
                          color: AppConstants.textGrey,
                        ),
                        filled: true,
                        fillColor: AppConstants.lightGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final qty = num.tryParse(qtyController.text.trim());
                    final unit =
                        unitController.text.trim().isEmpty
                            ? 'pcs'
                            : unitController.text.trim();
                    if (name.isEmpty || qty == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Renseignez un nom et une quantité valide',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      await _firestoreService.addMaterielNecessaire(
                        chantierId: d.id,
                        name: name,
                        qty: qty,
                        unit: unit,
                      );
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
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
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openActionsMenu(DataCollectionModel d) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.lightGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Actions chantier',
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await _openEditChantierSheet(d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppConstants.darkGrey,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.pencil,
                                color: AppConstants.primaryGreen,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Modifier',
                                style: GoogleFonts.poppins(
                                  color: AppConstants.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await _openDeleteConfirmSheet(d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A2A2A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.trash,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Supprimer',
                                style: GoogleFonts.poppins(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await _exportAndSave(d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppConstants.darkGrey,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.cloud_upload,
                                color: AppConstants.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Exporter PDF',
                                style: GoogleFonts.poppins(
                                  color: AppConstants.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await _openMarkAlertSheet(d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppConstants.darkGrey,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.bell,
                                color: Colors.orangeAccent,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                d.isAlert
                                    ? 'Modifier alerte'
                                    : 'Marquer alerte',
                                style: GoogleFonts.poppins(
                                  color: AppConstants.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            d.isAlert
                                ? () async {
                                  Navigator.pop(context);
                                  try {
                                    await _firestoreService.clearChantierAlert(
                                      d.id,
                                    );
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Alerte retirée'),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erreur: $e')),
                                    );
                                  }
                                }
                                : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A2A2A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.bell_slash,
                                color:
                                    d.isAlert
                                        ? Colors.redAccent
                                        : AppConstants.textGrey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Retirer alerte',
                                style: GoogleFonts.poppins(
                                  color:
                                      d.isAlert
                                          ? Colors.redAccent
                                          : AppConstants.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openMarkAlertSheet(DataCollectionModel d) async {
    final TextEditingController reasonController = TextEditingController(
      text: d.alertReason,
    );
    String level = d.alertLevel.isNotEmpty ? d.alertLevel : 'Moyenne';
    await showModalBottomSheet(
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
                          d.isAlert
                              ? 'Modifier l\'alerte'
                              : 'Marquer en alerte',
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
                    Text(
                      'Niveau d\'alerte',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final opt in const ['Faible', 'Moyenne', 'Élevée'])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(opt),
                              selected: level == opt,
                              onSelected:
                                  (v) => setModalState(() => level = opt),
                              selectedColor: _alertColor(opt).withOpacity(0.2),
                              labelStyle: GoogleFonts.poppins(
                                color: AppConstants.white,
                                fontSize: 12,
                              ),
                              backgroundColor: AppConstants.darkGrey,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(color: AppConstants.white),
                      decoration: InputDecoration(
                        labelText: 'Raison de l\'alerte',
                        labelStyle: GoogleFonts.poppins(
                          color: AppConstants.textGrey,
                        ),
                        filled: true,
                        fillColor: AppConstants.lightGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final reason = reasonController.text.trim();
                          if (reason.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Veuillez préciser la raison'),
                              ),
                            );
                            return;
                          }
                          try {
                            await _firestoreService.markChantierAlert(
                              chantierId: d.id,
                              level: level,
                              reason: reason,
                            );
                            await _firestoreService.notifyAllUsers(
                              title: 'Alerte chantier: ${d.chantier}',
                              message:
                                  'Niveau: $level • Bloc ${d.bloc} • Raison: $reason',
                            );
                            if (mounted) Navigator.pop(context);
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        },
                        icon: const Icon(CupertinoIcons.bell),
                        label: Text(
                          d.isAlert
                              ? 'Mettre à jour l\'alerte'
                              : 'Marquer en alerte',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
              );
            },
          ),
        );
      },
    );
  }

  Color _alertColor(String level) {
    switch (level) {
      case 'Faible':
        return Colors.amber;
      case 'Élevée':
        return Colors.redAccent;
      case 'Moyenne':
      default:
        return Colors.orange;
    }
  }

  Future<void> _exportAndSave(DataCollectionModel d) async {
    try {
      final List<String> names =
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
        consommations: _materielsUtilises,
        observations: 'Rapport généré automatiquement depuis BoisTech',
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez vous connecter')),
        );
        return;
      }
      final storage = StorageService();
      final url = await storage.uploadChantierPdf(
        userId: user.uid,
        chantierId: d.id,
        data: pdfBytes,
      );
      await _firestoreService.saveBackupRecord(
        userId: user.uid,
        downloadUrl: url,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF sauvegardé dans le cloud')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur export: $e')));
    }
  }

  // Future<bool> _confirm(String message) async {
  //   return await showDialog<bool>(
  //         context: context,
  //         builder:
  //             (context) => AlertDialog(
  //               backgroundColor: AppConstants.darkGrey,
  //               title: Text(
  //                 'Confirmation',
  //                 style: GoogleFonts.poppins(color: AppConstants.white),
  //               ),
  //               content: Text(
  //                 message,
  //                 style: GoogleFonts.poppins(color: AppConstants.textGrey),
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () => Navigator.pop(context, false),
  //                   child: const Text('Annuler'),
  //                 ),
  //                 TextButton(
  //                   onPressed: () => Navigator.pop(context, true),
  //                   child: const Text('Confirmer'),
  //                 ),
  //               ],
  //             ),
  //       ) ??
  //       false;
  // }

  Future<void> _openEditChantierSheet(DataCollectionModel d) async {
    final chantierController = TextEditingController(text: d.chantier);
    final ufeController = TextEditingController(text: d.ufe.toString());
    final blocController = TextEditingController(text: d.bloc.toString());
    final diametreController = TextEditingController(
      text: d.diametre.toString(),
    );
    final observationController = TextEditingController(text: d.observation);
    String essenceValue = d.essence.isEmpty ? _essences.first : d.essence;

    await showModalBottomSheet(
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
                          'Modifier le chantier',
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
                    CustomInput(
                      label: 'Nom du chantier',
                      hint: 'Ex: Chantier A',
                      controller: chantierController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            label: 'UFE',
                            hint: 'Unité Forestière',
                            controller: ufeController,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomInput(
                            label: 'Bloc',
                            hint: 'Numéro de bloc',
                            controller: blocController,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDropdown(
                            label: 'Essence',
                            hint: 'Type d\'essence',
                            value: essenceValue,
                            items: _essences,
                            isRequired: true,
                            onChanged:
                                (val) => setModalState(
                                  () => essenceValue = val ?? essenceValue,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomInput(
                            label: 'Diamètre (cm)',
                            hint: 'Diamètre de l\'arbre',
                            controller: diametreController,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomInput(
                      label: 'Observations',
                      hint: 'Notes...',
                      controller: observationController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final updated = d.copyWith(
                            chantier:
                                chantierController.text.trim().isEmpty
                                    ? d.chantier
                                    : chantierController.text.trim(),
                            ufe:
                                int.tryParse(ufeController.text.trim()) ??
                                d.ufe,
                            bloc:
                                int.tryParse(blocController.text.trim()) ??
                                d.bloc,
                            diametre:
                                int.tryParse(diametreController.text.trim()) ??
                                d.diametre,
                            essence: essenceValue,
                            observation: observationController.text.trim(),
                          );
                          try {
                            await _firestoreService.updateDataCollection(
                              updated,
                            );
                            if (mounted) Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur mise à jour: $e')),
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

  Future<void> _openDeleteConfirmSheet(DataCollectionModel d) async {
    await showModalBottomSheet(
      context: context,
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
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF3A2A2A),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      CupertinoIcons.trash,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Confirmer la suppression',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
              Text(
                'Cette action est irréversible. Le chantier "${d.chantier}" sera supprimé définitivement.',
                style: GoogleFonts.poppins(
                  color: AppConstants.textGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppConstants.textGrey),
                        foregroundColor: AppConstants.textGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Annuler', style: GoogleFonts.poppins()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _firestoreService.deleteDataCollection(d.id);
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur suppression: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: AppConstants.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Supprimer',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) return true;
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: AppConstants.primaryBlack,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppConstants.lightGrey,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        onPressed: _smartPop,
                        icon: Icon(
                          CupertinoIcons.chevron_left,
                          color: AppConstants.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Inventaire',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
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
                      child: Icon(
                        Icons.tune,
                        color: AppConstants.white,
                        size: 23,
                      ),
                    ),
                  ],
                ),
              ),

              // Section Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chantiers',
                      style: GoogleFonts.poppins(
                        color: AppConstants.white,
                        fontSize: 18,
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

              // Stream chantiers
              Expanded(
                child: Builder(
                  builder: (context) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      return Center(
                        child: Text(
                          'Veuillez vous connecter',
                          style: GoogleFonts.poppins(
                            color: AppConstants.textGrey,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }

                    return StreamBuilder<List<DataCollectionModel>>(
                      stream: _firestoreService.streamDataCollectionsByUser(
                        user.uid,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppConstants.primaryGreen,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Erreur de chargement',
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          );
                        }
                        final data = snapshot.data ?? [];
                        if (data.isEmpty) {
                          return Center(
                            child: Text(
                              "Aucun chantier pour l'instant",
                              style: GoogleFonts.poppins(
                                color: AppConstants.textGrey,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final d = data[index];
                            return _buildItemCard(d);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }

  Widget _buildItemCard(DataCollectionModel d) {
    return GestureDetector(
      onTap: () => _openChantierActions(d),
      onLongPress: () => _openAddMaterielModal(d),
      child: CustomCard(
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppConstants.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.map_pin_ellipse,
                color: AppConstants.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.chantier,
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Bloc ${d.bloc} • Essence ${d.essence}',
                          style: GoogleFonts.poppins(
                            color: AppConstants.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (d.isAlert && d.alertLevel.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _alertColor(d.alertLevel).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _alertColor(d.alertLevel),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.exclamationmark_triangle,
                                size: 14,
                                color: _alertColor(d.alertLevel),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                d.alertLevel,
                                style: GoogleFonts.poppins(
                                  color: AppConstants.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppConstants.darkGrey,
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: const Icon(
                  CupertinoIcons.ellipsis_vertical,
                  color: AppConstants.textGrey,
                  size: 15,
                ),
                onPressed: () => _openActionsMenu(d),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
