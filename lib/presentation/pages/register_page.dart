import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import 'package:difereti/data/supabase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  String _selectedIdType = 'Cedula';
  final List<String> _idTypes = ['Cedula', 'NIT', 'Pasaporte'];

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create user in Supabase
      await SupabaseService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'full_name': _nameController.text.trim(),
          'id_type': _selectedIdType,
          'id_number': _idNumberController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': 'client', // Default role
        },
      );

      if (mounted) {
        // Show success message or auto login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to dashboard or login
        // Since signUp might auto-login in Supabase depending on config,
        // we can check currentUser or just go to dashboard
        context.go('/dashboard?role=client');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrarse: ${e.toString().replaceAll('Exception: ', '')}'),
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
    _nameController.dispose();
    _idNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Background Effects
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BrandColors.primary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: BrandColors.primary.withValues(alpha: 0.2),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        'Crear Cuenta',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Únete a la comunidad Difereti',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // 1. Name Field
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Nombre Completo',
                          prefixIcon: Icon(Icons.person_outline, color: BrandColors.primary),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 2. ID Type & Number Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ID Type Dropdown
                          SizedBox(
                            width: 130,
                            child: DropdownButtonFormField<String>(
                              value: _selectedIdType,
                              isExpanded: true,
                              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Tipo ID',
                                prefixIcon: Icon(Icons.badge_outlined, color: BrandColors.primary, size: 20),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                              ),
                              items: _idTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type, style: const TextStyle(fontSize: 14)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedIdType = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // ID Number Field
                          Expanded(
                            child: TextFormField(
                              controller: _idNumberController,
                              keyboardType: TextInputType.text, // Text to allow '-' in NIT
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                labelText: _selectedIdType == 'NIT' ? 'Número (con dígito)' : 'Número de Documento',
                                hintText: _selectedIdType == 'NIT' ? 'Ej: 901797007-1' : null,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresa el número';
                                }
                                if (_selectedIdType == 'NIT' && !value.contains('-')) {
                                  // Basic check for verification digit separator, optional but helpful
                                  // allowing standard input for now
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. Phone Field
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Celular',
                          prefixIcon: Icon(Icons.phone_outlined, color: BrandColors.primary),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu celular';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 4. Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          prefixIcon: Icon(Icons.email_outlined, color: BrandColors.primary),
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

                      // 5. Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outline, color: BrandColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa una contraseña';
                          }
                          if (value.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 6. Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Confirmar Contraseña',
                          prefixIcon: Icon(Icons.verified_user_outlined, color: BrandColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Register Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BrandColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: BrandColors.primary.withValues(alpha: 0.4),
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
                                  'REGISTRARSE',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/'),
                            child: Text(
                              'Inicia Sesión',
                              style: TextStyle(
                                color: BrandColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ),
        
          // Back Button
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              onPressed: () => context.go('/'),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
