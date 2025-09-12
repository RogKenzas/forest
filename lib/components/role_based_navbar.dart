import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class RoleBasedNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final UserRole userRole;

  const RoleBasedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppConstants.darkGrey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _getNavItems(),
      ),
    );
  }

  List<Widget> _getNavItems() {
    switch (userRole) {
      case UserRole.agent:
        return [
          _buildNavItem(icon: CupertinoIcons.home, label: 'Accueil', index: 0),
          _buildNavItem(
            icon: CupertinoIcons.cube_box,
            label: 'Chantiers',
            index: 1,
          ),
          _buildNavItem(
            icon: CupertinoIcons.paperclip,
            label: 'Rapports',
            index: 2,
          ),
          _buildNavItem(
            icon: CupertinoIcons.settings,
            label: 'Paramètres',
            index: 3,
          ),
          _buildNavItem(
            icon: CupertinoIcons.person_fill,
            label: 'Profil',
            index: 4,
          ),
        ];
      case UserRole.analyst:
        return [
          _buildNavItem(icon: CupertinoIcons.home, label: 'Accueil', index: 0),
          _buildNavItem(
            icon: CupertinoIcons.chart_bar_alt_fill,
            label: 'Analyse',
            index: 1,
          ),
          _buildNavItem(
            icon: CupertinoIcons.settings,
            label: 'Paramètres',
            index: 2,
          ),
          _buildNavItem(
            icon: CupertinoIcons.person_fill,
            label: 'Profil',
            index: 3,
          ),
        ];
      case UserRole.supervisor:
        return [
          _buildNavItem(icon: CupertinoIcons.home, label: 'Accueil', index: 0),
          _buildNavItem(
            icon: CupertinoIcons.exclamationmark_triangle,
            label: 'Erreurs',
            index: 1,
          ),
          _buildNavItem(
            icon: CupertinoIcons.cloud,
            label: 'Sauvegardes',
            index: 2,
          ),
          _buildNavItem(
            icon: CupertinoIcons.person_fill,
            label: 'Profil',
            index: 3,
          ),
        ];
      case UserRole.admin:
        return [
          _buildNavItem(icon: CupertinoIcons.home, label: 'Accueil', index: 0),
          _buildNavItem(
            icon: CupertinoIcons.person_2,
            label: 'Utilisateurs',
            index: 1,
          ),
          _buildNavItem(icon: CupertinoIcons.tree, label: 'Zones', index: 2),
          _buildNavItem(
            icon: CupertinoIcons.person_fill,
            label: 'Profil',
            index: 3,
          ),
        ];
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        onTap(index);
        HapticFeedback.lightImpact();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected ? _getRoleColor() : Colors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                icon,
                color: isSelected ? AppConstants.white : AppConstants.textGrey,
                size: 23,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? _getRoleColor() : AppConstants.textGrey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor() {
    switch (userRole) {
      case UserRole.agent:
        return AppConstants.primaryGreen;
      case UserRole.analyst:
        return Colors.blue;
      case UserRole.supervisor:
        return Colors.orange;
      case UserRole.admin:
        return Colors.purple;
    }
  }
}
