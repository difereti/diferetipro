import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../theme.dart';
import 'package:difereti/data/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _listenAuthChanges();
    // If already logged in (e.g., returned from OAuth), route to dashboard
    final user = SupabaseService.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final role = user.userMetadata?['role'] ?? 'client';
        context.go('/dashboard?role=$role');
      });
    }
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final email = await _storage.read(key: 'email');
      final password = await _storage.read(key: 'password');

      if (email != null && password != null) {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
          _rememberMe = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading credentials: $e');
    }
  }

  void _listenAuthChanges() {
    try {
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null && mounted) {
          final role = session.user.userMetadata?['role'] ?? 'client';
          context.go('/dashboard?role=$role');
        }
      });
    } catch (e) {
      debugPrint('Auth listener error: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Login with Supabase
      final response = await SupabaseService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Handle Remember Me
        try {
          if (_rememberMe) {
            await _storage.write(
                key: 'email', value: _emailController.text.trim());
            await _storage.write(
                key: 'password', value: _passwordController.text);
          } else {
            await _storage.delete(key: 'email');
            await _storage.delete(key: 'password');
          }
        } catch (e) {
          debugPrint('Error saving credentials: $e');
          // Non-critical error, continue with login
        }

        if (mounted) {
          // Determine role from user metadata
          final role = response.user!.userMetadata?['role'] ?? 'client';
          context.go('/dashboard?role=$role');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al iniciar sesión: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we are in dark mode based on system/app theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Background abstract effect - Top Right
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BrandColors.primary.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: BrandColors.primary.withValues(alpha: 0.35),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          // Background abstract effect - Bottom Left
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BrandColors.primary.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: BrandColors.primary.withValues(alpha: 0.25),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: BrandColors.primary.withValues(alpha: 0.1),
                            border: Border.all(
                                color:
                                    BrandColors.primary.withValues(alpha: 0.3)),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ClipOval(
                        child: Image.asset(
                          'assets/images/Logo_difereti_blanco.png',
                          width: 128,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: BrandColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        'Mantenimiento | Reparación | Alquiler     Compraventa de sonido profesional',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: BrandColors.primary),
                          hintText: 'ejemplo@difereti.com',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo';
                          }
                          if (!value.contains('@')) {
                            return 'Ingresa un correo válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outline,
                              color: BrandColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: BrandColors.primary,
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey[400]!
                                    : Colors.grey[600]!,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Recordarme",
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BrandColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                            shadowColor:
                                BrandColors.primary.withValues(alpha: 0.4),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'INICIAR SESIÓN',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() => _isLoading = true);
                                  try {
                                    await SupabaseService.signInWithGoogle();
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e
                                              .toString()
                                              .replaceAll('Exception: ', ''),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    if (mounted) setState(() => _isLoading = false);
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                            foregroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          icon: Icon(
                            Icons.g_mobiledata, // Minimalist G icon
                            size: 28,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          label: Text(
                            'Continuar con Google',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          '¿No tienes cuenta?',
                          style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => context.go('/register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: BrandColors.primary,
                            side: BorderSide(
                                color: BrandColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(
                            'REGÍSTRATE',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: BrandColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300]),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Acceso Demo',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _DemoButton(
                            label: 'Admin',
                            onTap: () {
                              _emailController.text = 'admin@difereti.com';
                              _passwordController.text = 'admin123';
                            },
                          ),
                          const SizedBox(width: 8),
                          _DemoButton(
                            label: 'Técnico',
                            onTap: () {
                              _emailController.text = 'tech@difereti.com';
                              _passwordController.text = 'tech123';
                            },
                          ),
                          const SizedBox(width: 8),
                          _DemoButton(
                            label: 'Cliente',
                            onTap: () {
                              _emailController.text = 'cliente@gmail.com';
                              _passwordController.text = 'cliente123';
                            },
                          ),
                        ],
                      ),
                    ],
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

class _DemoButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DemoButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
