import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../components/custom_button.dart';
import '../components/custom_card.dart';
import '../models/user_model.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String username;

  const RoleSelectionScreen({
    super.key,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.username,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  final List<Map<String, dynamic>> _roles = [
    {
      'role': UserRole.agent,
      'title': 'Agent de Terrain',
      'description': 'Collecte de données, missions, inventaire',
      'icon': CupertinoIcons.person_badge_plus,
      'color': AppConstants.primaryGreen,
      'features': [
        'Saisir inventaire',
        'Consulter missions',
        'Synchroniser données',
        'Collecter données',
        'Gérer son profil'
      ],
    },
    {
      'role': UserRole.analyst,
      'title': 'Analyste',
      'description': 'Analyse des données, rapports, export',
      'icon': CupertinoIcons.chart_bar_alt_fill,
      'color': Colors.blue,
      'features': [
        'Gérer son profil',
        'Analyser données',
        'Exporter données',
        'Créer des rapports',
        'Visualiser les statistiques'
      ],
    },
    {
      'role': UserRole.supervisor,
      'title': 'Superviseur',
      'description': 'Gestion des erreurs, rapports, sauvegardes',
      'icon': CupertinoIcons.person_2_fill,
      'color': Colors.orange,
      'features': [
        'Gérer erreurs',
        'Générer rapports',
        'Suivre les inventaires',
        'Consulter historique',
        'Gérer sauvegarde'
      ],
    },
    {
      'role': UserRole.admin,
      'title': 'Administrateur',
      'description': 'Gestion complète du système',
      'icon': CupertinoIcons.gear_alt_fill,
      'color': Colors.purple,
      'features': [
        'Consulter tableau de bord',
        'Gérer compte utilisateur',
        'Configurer plateforme',
        'Gérer zone forestière',
        'Administrer le système'
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        CupertinoIcons.person_badge_plus,
                        color: AppConstants.primaryGreen,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Choisissez votre type de compte',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sélectionnez le rôle qui correspond le mieux à vos responsabilités',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppConstants.textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Liste des rôles
              ..._roles.map((roleData) => _buildRoleCard(roleData)).toList(),
              
              const SizedBox(height: 32),
              
              // Bouton de confirmation
              CustomButton(
                text: 'Continuer',
                onPressed: _selectedRole != null ? _handleContinue : null,
                isLoading: false,
              ),
              
              const SizedBox(height: 16),
              
              // Informations
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.darkGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.info_circle,
                      color: AppConstants.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vous pourrez modifier votre rôle plus tard dans les paramètres',
                        style: GoogleFonts.poppins(
                          color: AppConstants.textGrey,
                          fontSize: 12,
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
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> roleData) {
    final role = roleData['role'] as UserRole;
    final title = roleData['title'] as String;
    final description = roleData['description'] as String;
    final icon = roleData['icon'] as IconData;
    final color = roleData['color'] as Color;
    final features = roleData['features'] as List<String>;
    
    final isSelected = _selectedRole == role;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: CustomCard(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
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
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: GoogleFonts.poppins(
                              color: AppConstants.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.checkmark,
                          color: AppConstants.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Fonctionnalités incluses :',
                  style: GoogleFonts.poppins(
                    color: AppConstants.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: features.map((feature) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      feature,
                      style: GoogleFonts.poppins(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_selectedRole == null) return;
    
    // Retourner au RegisterScreen avec le rôle sélectionné
    Navigator.pop(context, _selectedRole);
  }
}
