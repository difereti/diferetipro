import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import 'package:difereti/data/supabase_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:difereti/data/country_data.dart';

class RegisterPage extends StatefulWidget {
  final String? initialCountryCode;
  final String? initialCountryName;
  const RegisterPage({super.key, this.initialCountryCode, this.initialCountryName});

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
  final _countryController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _locatingCountry = false;
  String? _countryCode; // ISO 3166-1 alpha-2
  
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
          'country': _countryController.text.trim(),
          'country_code': _countryCode,
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
    _countryController.dispose();
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

                      // 3. Country + Phone Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Country selector (compact) on the left
                          SizedBox(
                            width: 180,
                            child: _CountryAutocompleteField(
                              controller: _countryController,
                              isDark: isDark,
                              countryCode: _countryCode,
                              locating: _locatingCountry,
                              onDetect: _detectCountry,
                              onCountrySelected: (country) {
                                setState(() {
                                  _countryController.text = country.name;
                                  _countryCode = country.code;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Phone number on the right with dial code prefix
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Celular',
                                prefixIcon: (_countryCode != null && _countryCode!.isNotEmpty)
                                    ? SizedBox(
                                        width: 80,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              countryFlag(_countryCode!),
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              dialCodeFor(_countryCode!).isNotEmpty ? dialCodeFor(_countryCode!) : '+',
                                              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Icon(Icons.phone_outlined, color: BrandColors.primary),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu celular';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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

  @override
  void initState() {
    super.initState();
    // Prefill from navigation params if available, otherwise try auto-detect once
    if ((widget.initialCountryCode != null && widget.initialCountryCode!.isNotEmpty) &&
        (widget.initialCountryName != null && widget.initialCountryName!.isNotEmpty)) {
      _countryCode = widget.initialCountryCode!.toUpperCase();
      _countryController.text = widget.initialCountryName!;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _detectCountry(silent: true));
    }
  }

  Future<void> _detectCountry({bool silent = false}) async {
    setState(() => _locatingCountry = true);
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado. Ingresa el país manualmente.')),
          );
        }
        return;
      }

      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activa la ubicación para detectar tu país.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      final placemarks = await geocoding.placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final isoCode = place.isoCountryCode ?? '';
        final name = place.country ?? '';
        if (isoCode.isNotEmpty && name.isNotEmpty) {
          setState(() {
            _countryCode = isoCode.toUpperCase();
            _countryController.text = name;
          });
        }
      }
    } catch (e) {
      debugPrint('Country detection failed: $e');
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo detectar el país automáticamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _locatingCountry = false);
    }
  }
}

class _CountryAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;
  final String? countryCode;
  final bool locating;
  final VoidCallback? onDetect;
  final ValueChanged<Country> onCountrySelected;

  const _CountryAutocompleteField({
    required this.controller,
    required this.isDark,
    required this.countryCode,
    required this.locating,
    required this.onDetect,
    required this.onCountrySelected,
  });

  @override
  State<_CountryAutocompleteField> createState() => _CountryAutocompleteFieldState();
}

class _CountryAutocompleteFieldState extends State<_CountryAutocompleteField> {
  late List<Country> _options;

  @override
  void initState() {
    super.initState();
    _options = countries;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final flag = widget.countryCode != null ? countryFlag(widget.countryCode!) : null;

    return RawAutocomplete<Country>(
      textEditingController: widget.controller,
      focusNode: FocusNode(),
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return const Iterable<Country>.empty();
        return _options.where((c) => c.name.toLowerCase().contains(query) || c.code.toLowerCase().startsWith(query));
      },
      displayStringForOption: (Country option) => option.name,
      onSelected: widget.onCountrySelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            labelText: 'País',
            prefixIcon: SizedBox(
              width: 44,
              child: Center(
                child: Text(
                  flag ?? '🌐',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            suffixIcon: widget.locating
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: BrandColors.primary,
                      ),
                    ),
                  )
                : IconButton(
                    tooltip: 'Detectar automáticamente',
                    icon: Icon(Icons.my_location_outlined, color: BrandColors.primary),
                    onPressed: widget.onDetect,
                  ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Ingresa tu país';
            return null;
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, minWidth: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final Country option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: Text(countryFlag(option.code), style: const TextStyle(fontSize: 18)),
                    title: Text(option.name, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    subtitle: Text(option.code, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
