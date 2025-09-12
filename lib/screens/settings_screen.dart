import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forest/screens/home_screen.dart';
import 'package:forest/services/navigation_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final userId = AuthService().currentUser?.uid;

    Future<void> _smartPop() async {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        NavigationHelper.popFade(context);
      }
    }

    return Scaffold(
      backgroundColor:
          settings.darkMode ? AppConstants.primaryBlack : Colors.white,
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: Container(
          decoration: BoxDecoration(
            color: AppConstants.lightGrey,
            borderRadius: BorderRadius.circular(50),
          ),
          child: IconButton(
            onPressed: _smartPop,
            icon: Icon(
              CupertinoIcons.chevron_left,
              color: AppConstants.white,
              size: 20,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Compte',
            children: [
              _TileContainer(
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.moon,
                      color: AppConstants.primaryGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Mode sombre',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    Switch.adaptive(
                      value: settings.darkMode,
                      activeColor: AppConstants.primaryGreen,
                      onChanged: (v) => settings.toggleDarkMode(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _TileContainer(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bientôt disponible')),
                  );
                },
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.person,
                      color: AppConstants.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Modifier le profil',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                      color: AppConstants.textGrey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Notifications',
            children: [
              _TileContainer(
                onTap:
                    () => settings.togglePushNotification(
                      !settings.pushNotification,
                      userId: userId,
                    ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.bell, color: AppConstants.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Notifications push',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    Switch.adaptive(
                      value: settings.pushNotification,
                      activeColor: AppConstants.primaryGreen,
                      onChanged:
                          (v) => settings.togglePushNotification(
                            v,
                            userId: userId,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _TileContainer(
                onTap:
                    () => settings.toggleMailNotification(
                      !settings.mailNotification,
                      userId: userId,
                    ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.envelope,
                      color: AppConstants.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Email',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    Switch.adaptive(
                      value: settings.mailNotification,
                      activeColor: AppConstants.primaryGreen,
                      onChanged:
                          (v) => settings.toggleMailNotification(
                            v,
                            userId: userId,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Support',
            children: [
              _TileContainer(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.headphones,
                      color: AppConstants.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nous contacter',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                      color: AppConstants.textGrey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _TileContainer(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.question_circle,
                      color: AppConstants.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Centre d’aide',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                      color: AppConstants.textGrey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _TileContainer(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.doc_text,
                      color: AppConstants.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Termes et conditions',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                      color: AppConstants.textGrey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppConstants.primaryGreen,
                borderRadius: BorderRadius.circular(50),
              ),
              child: TextButton.icon(
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
                icon: const Icon(CupertinoIcons.square_arrow_left),
                label: Text(
                  'Se déconnecter',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: AppConstants.textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _TileContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _TileContainer({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppConstants.lightGrey,
          borderRadius: BorderRadius.circular(50),
        ),
        child: child,
      ),
    );
  }
}
