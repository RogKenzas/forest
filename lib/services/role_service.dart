import '../models/user_model.dart';

class RoleService {
  static const Map<UserRole, List<String>> _rolePermissions = {
    UserRole.agent: [
      'inventory.view',
      'inventory.create',
      'inventory.update',
      'data_collection.view',
      'data_collection.create',
      'data_collection.update',
      'mission.view',
      'mission.update_status',
      'profile.view',
      'profile.update',
      'sync.data',
    ],
    UserRole.analyst: [
      'data_collection.view',
      'analysis.create',
      'analysis.view',
      'analysis.update',
      'report.create',
      'report.view',
      'report.export',
      'profile.view',
      'profile.update',
    ],
    UserRole.supervisor: [
      'inventory.view',
      'inventory.create',
      'inventory.update',
      'data_collection.view',
      'data_collection.create',
      'data_collection.update',
      'mission.view',
      'mission.create',
      'mission.update',
      'mission.assign',
      'report.view',
      'report.create',
      'report.approve',
      'error.view',
      'error.manage',
      'backup.create',
      'backup.restore',
      'history.view',
      'profile.view',
      'profile.update',
    ],
    UserRole.admin: [
      'all', // Toutes les permissions
    ],
  };

  static const Map<UserRole, List<String>> _roleFeatures = {
    UserRole.agent: [
      'inventory_management',
      'data_collection',
      'mission_consultation',
      'data_synchronization',
      'profile_management',
    ],
    UserRole.analyst: [
      'data_analysis',
      'report_generation',
      'data_export',
      'profile_management',
    ],
    UserRole.supervisor: [
      'error_management',
      'report_generation',
      'inventory_monitoring',
      'history_consultation',
      'backup_management',
      'mission_management',
      'profile_management',
    ],
    UserRole.admin: [
      'dashboard_consultation',
      'user_management',
      'platform_configuration',
      'forest_zone_management',
      'all_features',
    ],
  };

  /// Vérifie si un utilisateur a une permission spécifique
  static bool hasPermission(UserModel user, String permission) {
    if (user.isAdmin) return true;

    final rolePermissions = _rolePermissions[user.role] ?? [];
    return rolePermissions.contains(permission) ||
        rolePermissions.contains('all') ||
        user.hasPermission(permission);
  }

  /// Vérifie si un utilisateur a accès à une fonctionnalité
  static bool hasFeature(UserModel user, String feature) {
    if (user.isAdmin) return true;

    final roleFeatures = _roleFeatures[user.role] ?? [];
    return roleFeatures.contains(feature) ||
        roleFeatures.contains('all_features');
  }

  /// Retourne toutes les permissions d'un rôle
  static List<String> getRolePermissions(UserRole role) {
    return _rolePermissions[role] ?? [];
  }

  /// Retourne toutes les fonctionnalités d'un rôle
  static List<String> getRoleFeatures(UserRole role) {
    return _roleFeatures[role] ?? [];
  }

  /// Retourne la liste des rôles disponibles
  static List<UserRole> getAvailableRoles() {
    return UserRole.values;
  }

  /// Retourne le nom d'affichage d'un rôle
  static String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.agent:
        return 'Agent de terrain';
      case UserRole.analyst:
        return 'Analyste';
      case UserRole.supervisor:
        return 'Superviseur';
      case UserRole.admin:
        return 'Administrateur';
    }
  }

  /// Retourne la description d'un rôle
  static String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.agent:
        return 'Collecte des données sur le terrain, gestion des inventaires et exécution des missions';
      case UserRole.analyst:
        return 'Analyse des données collectées, génération de rapports et export des données';
      case UserRole.supervisor:
        return 'Supervision des opérations, gestion des erreurs, rapports et sauvegardes';
      case UserRole.admin:
        return 'Administration complète de la plateforme, gestion des utilisateurs et configuration';
    }
  }

  /// Vérifie si un utilisateur peut gérer un autre utilisateur
  static bool canManageUser(UserModel manager, UserModel targetUser) {
    if (manager.isAdmin) return true;
    if (manager.id == targetUser.id)
      return true; // Peut gérer son propre profil

    // Un superviseur peut gérer les agents
    if (manager.isSupervisor && targetUser.isAgent) return true;

    return false;
  }

  /// Vérifie si un utilisateur peut assigner des missions
  static bool canAssignMissions(UserModel user) {
    return hasPermission(user, 'mission.assign') ||
        user.isAdmin ||
        user.isSupervisor;
  }

  /// Vérifie si un utilisateur peut approuver des rapports
  static bool canApproveReports(UserModel user) {
    return hasPermission(user, 'report.approve') ||
        user.isAdmin ||
        user.isSupervisor;
  }

  /// Vérifie si un utilisateur peut gérer les erreurs
  static bool canManageErrors(UserModel user) {
    return hasPermission(user, 'error.manage') ||
        user.isAdmin ||
        user.isSupervisor;
  }

  /// Vérifie si un utilisateur peut gérer les sauvegardes
  static bool canManageBackups(UserModel user) {
    return hasPermission(user, 'backup.create') ||
        user.isAdmin ||
        user.isSupervisor;
  }

  /// Retourne les fonctionnalités accessibles pour un utilisateur
  static List<String> getAccessibleFeatures(UserModel user) {
    return _roleFeatures[user.role] ?? [];
  }

  /// Retourne les permissions accessibles pour un utilisateur
  static List<String> getAccessiblePermissions(UserModel user) {
    if (user.isAdmin) return ['all'];
    return _rolePermissions[user.role] ?? [];
  }

  /// Vérifie si un rôle peut être assigné par un utilisateur
  static bool canAssignRole(UserModel assigner, UserRole targetRole) {
    if (assigner.isAdmin) return true;

    // Un superviseur peut assigner le rôle d'agent
    if (assigner.isSupervisor && targetRole == UserRole.agent) return true;

    return false;
  }

  /// Retourne les rôles qu'un utilisateur peut assigner
  static List<UserRole> getAssignableRoles(UserModel user) {
    if (user.isAdmin) return UserRole.values;
    if (user.isSupervisor) return [UserRole.agent];
    return [];
  }
}
