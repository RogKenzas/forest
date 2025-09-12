import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../components/custom_checkbox.dart';
import '../components/social_button.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'role_selection_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

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
              const SizedBox(height: 40),
              // Logo et titre
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      child: Image.asset("assets/logo/box.png"),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Inscription',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Remplissez les champs ci-dessous pour commencer',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppConstants.textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Formulaire
              CustomInput(
                label: 'Nom complet',
                hint: 'Entrez votre nom complet',
                controller: _nameController,
                keyboardType: TextInputType.name,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              CustomInput(
                label: 'Email',
                hint: 'Entrez votre email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              CustomInput(
                label: 'Mot de passe',
                hint: 'Créez un mot de passe',
                controller: _passwordController,
                isPassword: _obscurePassword,
                isRequired: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppConstants.textGrey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Case à cocher
              GestureDetector(
                onTap: () {
                  setState(() {
                    _rememberMe = !_rememberMe;
                  });
                },
                child: CustomCheckbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  label: 'Se souvenir de moi',
                ),
              ),
              const SizedBox(height: 32),
              // Bouton d'inscription
              CustomButton(
                text: 'S\'inscrire',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 24),
              // Séparateur
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppConstants.textGrey.withValues(alpha: 0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Ou continuer avec',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppConstants.textGrey.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Boutons sociaux
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SocialButton(
                    provider: 'google',
                    onPressed: () => _handleSocialLogin('google'),
                  ),
                  SocialButton(
                    provider: 'apple',
                    onPressed: () => _handleSocialLogin('apple'),
                  ),
                  SocialButton(
                    provider: 'facebook',
                    onPressed: () => _handleSocialLogin('facebook'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Lien de connexion
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vous avez déjà un compte? ',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Se connecter',
                        style: GoogleFonts.poppins(
                          color: AppConstants.primaryGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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

  Future<void> _handleRegister() async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs');
      return;
    }

    // Découper le nom complet
    final parts = fullName.split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final username =
        email.contains('@') ? email.split('@').first : firstName.toLowerCase();

    // Naviguer vers la sélection du rôle
    final selectedRole = await Navigator.push<UserRole>(
      context,
      MaterialPageRoute(
        builder:
            (context) => RoleSelectionScreen(
              email: email,
              password: password,
              firstName: firstName,
              lastName: lastName,
              username: username,
            ),
      ),
    );

    if (selectedRole == null) return;

    setState(() => _isLoading = true);

    try {
      await _auth.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        username: username,
        role: selectedRole,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = 'Erreur inconnue';
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'Cet email est déjà utilisé';
          break;
        case 'invalid-email':
          msg = 'Email invalide';
          break;
        case 'weak-password':
          msg = 'Mot de passe trop faible';
          break;
        default:
          msg = e.message ?? msg;
      }
      _showSnackBar(msg);
    } catch (e) {
      if (mounted) _showSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSocialLogin(String provider) {
    _showSnackBar('Connexion avec $provider en cours...');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.primaryGreen,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
