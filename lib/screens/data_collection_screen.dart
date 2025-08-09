import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forest/components/custom_bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../components/custom_input.dart';
import '../components/custom_dropdown.dart';
import '../components/custom_button.dart';
import '../models/data_collection_model.dart';
import '../services/firestore_service.dart';

class DataCollectionScreen extends StatefulWidget {
  const DataCollectionScreen({super.key});

  @override
  State<DataCollectionScreen> createState() => _DataCollectionScreenState();
}

class _DataCollectionScreenState extends State<DataCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  // Controllers for form fields
  final _chantierController = TextEditingController();
  final _ufeController = TextEditingController();
  final _accController = TextEditingController();
  final _blocController = TextEditingController();
  final _numeroProspeController = TextEditingController();
  final _codeProspeController = TextEditingController();
  String? _essenceValue;
  final _diametreController = TextEditingController();
  final _qualiteController = TextEditingController();
  final _observationController = TextEditingController();

  final List<String> _essences = const [
    'Azobé (Lophira alata)',
    'Iroko (Milicia excelsa)',
  ];

  @override
  void dispose() {
    _chantierController.dispose();
    _ufeController.dispose();
    _accController.dispose();
    _blocController.dispose();
    _numeroProspeController.dispose();
    _codeProspeController.dispose();
    _diametreController.dispose();
    _qualiteController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veuillez vous connecter')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = DataCollectionModel(
        id: '',
        date: DateTime.now(),
        chantier: _chantierController.text,
        ufe: int.parse(_ufeController.text),
        acc: int.parse(_accController.text),
        bloc: int.parse(_blocController.text),
        numeroProspe: int.parse(_numeroProspeController.text),
        codeProspe: int.parse(_codeProspeController.text),
        essence: _essenceValue ?? '',
        diametre: int.parse(_diametreController.text),
        qualite: _qualiteController.text,
        observation: _observationController.text,
        userId: user.uid,
      );

      await _firestoreService.addDataCollection(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données collectées avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _currentIndex = 2;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) Navigator.pushNamed(context, '/home');
    if (index == 1) Navigator.pushNamed(context, '/inventory');
    if (index == 2) Navigator.pushNamed(context, '/data-collection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlack,
      appBar: AppBar(
        title: Text(
          'Collecte de Données',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: AppConstants.lightGrey,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Icon(CupertinoIcons.chevron_left),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Informations du Chantier',
              style: GoogleFonts.poppins(
                color: AppConstants.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            CustomInput(
              label: 'Chantier',
              hint: 'Nom du chantier',
              controller: _chantierController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le chantier est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomInput(
                    label: 'UFE',
                    hint: 'Unité Forestière',
                    controller: _ufeController,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'UFE requis';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre requis';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomInput(
                    label: 'ACC',
                    hint: 'Code d\'accès',
                    controller: _accController,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ACC requis';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre requis';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomInput(
                    label: 'Bloc',
                    hint: 'Numéro de bloc',
                    controller: _blocController,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bloc requis';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre requis';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomInput(
                    label: 'Numéro Prospect',
                    hint: 'Numéro de prospect',
                    controller: _numeroProspeController,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Numéro requis';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre requis';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomInput(
              label: 'Code Prospect',
              hint: 'Code du prospect',
              controller: _codeProspeController,
              keyboardType: TextInputType.number,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Code requis';
                }
                if (int.tryParse(value) == null) {
                  return 'Nombre requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            Text(
              'Informations de l\'Arbre',
              style: GoogleFonts.poppins(
                color: AppConstants.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Essence dropdown remplaçant l'input
            CustomDropdown(
              label: 'Essence',
              hint: 'Type d\'essence',
              value: _essenceValue,
              items: _essences,
              isRequired: true,
              onChanged: (val) {
                setState(() {
                  _essenceValue = val;
                });
              },
              validator: (val) {
                if (val == null || val.isEmpty) return 'L\'essence est requise';
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomInput(
                    label: 'Diamètre (cm)',
                    hint: 'Diamètre de l\'arbre',
                    controller: _diametreController,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Diamètre requis';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre requis';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomInput(
                    label: 'Qualité',
                    hint: 'Qualité de l\'arbre',
                    controller: _qualiteController,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Qualité requise';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomInput(
              label: 'Observations',
              hint: 'Observations supplémentaires',
              controller: _observationController,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            CustomButton(
              text: 'Enregistrer les Données',
              onPressed: _submitData,
              isLoading: _isLoading,
              icon: Icons.save,
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
}
