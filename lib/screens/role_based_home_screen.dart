import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'agent_home_screen.dart';
import 'analyst_home_screen.dart';
import 'supervisor_home_screen.dart';
import 'admin_home_screen.dart';

class RoleBasedHomeScreen extends StatefulWidget {
  const RoleBasedHomeScreen({super.key});

  @override
  State<RoleBasedHomeScreen> createState() => _RoleBasedHomeScreenState();
}

class _RoleBasedHomeScreenState extends State<RoleBasedHomeScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Erreur: Utilisateur non trouvé'),
        ),
      );
    }

    // Rediriger vers l'écran d'accueil approprié selon le rôle
    switch (_currentUser!.role) {
      case UserRole.agent:
        return const AgentHomeScreen();
      case UserRole.analyst:
        return const AnalystHomeScreen();
      case UserRole.supervisor:
        return const SupervisorHomeScreen();
      case UserRole.admin:
        return const AdminHomeScreen();
    }
  }
}
