import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../components/custom_checkbox.dart';
import '../components/social_button.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                      'Bienvenue sur BoisTech',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BoisTech, inventaire forestier\nartisanal et toujours précis',
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
                label: 'Email',
                hint: 'Entrez votre email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              CustomInput(
                label: 'Mot de passe',
                hint: 'Entrez votre mot de passe',
                controller: _passwordController,
                isPassword: _obscurePassword,
                isRequired: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppConstants.textGrey,
                    size: 15,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 18),
              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: GestureDetector(
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
                  ),
                  GestureDetector(
                    onTap: () {
                      _showSnackBar('Fonctionnalité à venir');
                    },
                    child: Text(
                      'Mot de passe oublié?',
                      style: GoogleFonts.poppins(
                        color: AppConstants.primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Bouton de connexion
              CustomButton(
                text: 'Se connecter',
                isLoading: _isLoading,
                onPressed: _handleLogin,
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
              // Lien d'inscription
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vous n\'avez pas de compte? ',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: Text(
                        'S\'inscrire',
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

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _auth.signIn(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = 'Erreur de connexion';
      switch (e.code) {
        case 'user-not-found':
          msg = 'Utilisateur introuvable';
          break;
        case 'wrong-password':
          msg = 'Mot de passe incorrect';
          break;
        case 'invalid-email':
          msg = 'Email invalide';
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
