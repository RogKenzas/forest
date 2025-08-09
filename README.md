# BoisTech - Application de Suivi d'Inventaire Forestier

## Description

BoisTech est une application mobile Flutter conçue pour le suivi et la gestion d'inventaire forestier. L'application permet aux utilisateurs de collecter des données sur le terrain, gérer leur profil, consulter des tableaux de bord, et recevoir des notifications.

## Fonctionnalités

### 👤 Gestion des Utilisateurs
- **Authentification** : Connexion avec email et mot de passe
- **Gestion de profil** : Modification des informations utilisateur
- **Rôles** : Utilisateur standard et Super Admin

### 📊 Tableau de Bord
- **Statistiques** : Vue d'ensemble des données collectées
- **Documents récents** : Historique des dernières activités
- **Notifications** : Alertes et messages importants

### 🌲 Collecte de Données
- **Informations du chantier** : Chantier, UFE, ACC, Bloc
- **Données de prospection** : Numéro et code de prospect
- **Informations de l'arbre** : Essence, diamètre, qualité
- **Observations** : Notes supplémentaires

### 💾 Gestion des Sauvegardes
- **Sauvegarde locale** : Stockage des données hors ligne
- **Synchronisation** : Upload vers le serveur
- **Historique** : Consultation des sauvegardes

### 🔔 Notifications
- **Alertes système** : Notifications importantes
- **Statut de lecture** : Gestion des notifications non lues

## Architecture Technique

### Modèles de Données
- `UserModel` : Gestion des utilisateurs
- `DataCollectionModel` : Données de collecte forestière
- `BackupModel` : Gestion des sauvegardes
- `NotificationModel` : Système de notifications
- `HistoryModel` : Historique des activités

### Services
- `FirebaseService` : Initialisation de Firebase
- `AuthService` : Authentification et gestion des utilisateurs
- `FirestoreService` : Opérations de base de données

### Composants Réutilisables
- `CustomButton` : Boutons personnalisés
- `CustomInput` : Champs de saisie stylisés
- `CustomCard` : Cartes avec design cohérent

## Configuration Firebase

### Collections Firestore
- `users` : Données des utilisateurs
- `data_collections` : Données de collecte forestière
- `backups` : Sauvegardes utilisateur
- `notifications` : Notifications système
- `history` : Historique des activités

### Authentification
- Email/Mot de passe via Firebase Auth
- Stockage des profils utilisateur dans Firestore

## Installation

1. **Cloner le projet**
   ```bash
   git clone [url-du-repo]
   cd forest
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configurer Firebase**
   - Créer un projet Firebase
   - Ajouter les fichiers de configuration
   - Activer Authentication et Firestore

4. **Lancer l'application**
   ```bash
   flutter run
   ```

## Structure du Projet

```
lib/
├── components/          # Composants réutilisables
│   ├── custom_button.dart
│   ├── custom_input.dart
│   └── custom_card.dart
├── constants/           # Constantes de l'application
│   └── app_constants.dart
├── models/             # Modèles de données
│   ├── user_model.dart
│   ├── data_collection_model.dart
│   ├── backup_model.dart
│   ├── notification_model.dart
│   └── history_model.dart
├── screens/            # Écrans de l'application
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── inventory_screen.dart
│   └── data_collection_screen.dart
├── services/           # Services et logique métier
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   └── firestore_service.dart
└── main.dart          # Point d'entrée de l'application
```

## Design System

### Couleurs
- **Vert principal** : `#2DDF16`
- **Noir** : `#000000`
- **Gris foncé** : `#1A1A1A`
- **Gris clair** : `#2A2A2A`
- **Blanc** : `#FFFFFF`
- **Gris texte** : `#9E9E9E`

### Typographie
- **Police** : Google Fonts Poppins
- **Tailles** : 12px, 14px, 16px, 18px, 20px, 24px, 32px

### Composants
- **Boutons** : Coins arrondis, hauteur 50px
- **Cartes** : Coins arrondis 12px, ombre légère
- **Inputs** : Fond gris, bordure verte au focus

## Cas d'Usage

### Utilisateur Standard
1. **Connexion** à l'application
2. **Consultation** du tableau de bord
3. **Collecte** de données sur le terrain
4. **Gestion** des sauvegardes
5. **Réception** de notifications

### Super Admin
1. **Gestion** des comptes administrateurs
2. **Consultation** de l'historique système
3. **Attribution** des permissions
4. **Surveillance** des activités

## Développement

### Prérequis
- Flutter SDK 3.7.2+
- Dart 3.0+
- Android Studio / VS Code
- Compte Firebase

### Commandes Utiles
```bash
# Analyser le code
flutter analyze

# Tests unitaires
flutter test

# Build pour Android
flutter build apk

# Build pour iOS
flutter build ios
```

## Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## Support

Pour toute question ou problème, veuillez ouvrir une issue sur GitHub ou contacter l'équipe de développement.
