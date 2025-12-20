import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme.dart';
import '../../data/mock_data.dart';
import '../../nav.dart';
import 'home_page.dart';
import 'services_page.dart';
import 'emergency_page.dart';
import 'inbox_page.dart';
import 'technician_page.dart';
import '../../services/supabase_service.dart';

class DashboardPage extends StatefulWidget {
  final String role;
  const DashboardPage({super.key, this.role = 'client'});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  String? _getUserAvatarUrl() {
    final user = SupabaseService.currentUser;
    final url = SupabaseService.getAvatarUrlFromUser(user);
    return (url != null && url.isNotEmpty) ? url : null;
  }

  String _getUserInitials() {
    try {
      final user = SupabaseService.currentUser;
      final meta = user?.userMetadata ?? {};
      final fullNameRaw = meta['full_name']?.toString().trim();

      if (fullNameRaw == null || fullNameRaw.isEmpty) {
        // Fallback to email first letter if available
        final email = user?.email ?? '';
        if (email.isNotEmpty) return email.characters.first.toUpperCase();
        return 'NM';
      }

      final parts = fullNameRaw.split(RegExp(r"\s+")).where((p) => p.isNotEmpty).toList();
      if (parts.isEmpty) return 'NM';
      final first = parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '';
      final last = (parts.length > 1 && parts.last.isNotEmpty) ? parts.last[0].toUpperCase() : '';
      final initials = (first + last).trim();
      return initials.isEmpty ? 'NM' : initials;
    } catch (e) {
      debugPrint('Failed to compute user initials: $e');
      return 'NM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFab(),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_currentIndex == 2 && widget.role == 'client') return null; // Hide for emergency page

    final avatarUrl = _getUserAvatarUrl();
    return AppBar(
      title: Text(
        _getTitle(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _showProfileDialog(context),
          borderRadius: BorderRadius.circular(50),
          child: CircleAvatar(
            backgroundColor: Colors.grey[800],
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null ? Text(_getUserInitials()) : null,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const UserProfileDialog(),
    );
  }

  String _getTitle() {
    if (widget.role == 'technician') {
      switch (_currentIndex) {
        case 0: return 'Tablero Técnico';
        case 1: return 'Inventario';
        default: return 'Difereti';
      }
    }
    
    if (widget.role == 'admin') {
      switch (_currentIndex) {
        case 0: return 'CRM & Mensajes';
        case 1: return 'Estadísticas';
        default: return 'Difereti';
      }
    }

    // Client
    switch (_currentIndex) {
      case 0: return 'Inicio';
      case 1: return 'Servicios';
      case 2: return 'Emergencia';
      default: return 'Difereti';
    }
  }

  Widget _buildBody() {
    if (widget.role == 'technician') {
      switch (_currentIndex) {
        case 0: return const TechnicianKanbanPage();
        case 1: return const Center(child: Text('Inventario'));
        default: return const Center(child: Text('Perfil'));
      }
    }

    if (widget.role == 'admin') {
      switch (_currentIndex) {
        case 0: return const UnifiedInboxPage();
        case 1: return const Center(child: Text('Estadísticas'));
        default: return const Center(child: Text('Configuración'));
      }
    }

    // Client
    switch (_currentIndex) {
      case 0: return const ClientHomePage();
      case 1: return const ServicesPage();
      case 2: return const EmergencyPage();
      default: return const ClientHomePage();
    }
  }

  Widget _buildBottomNav() {
    List<BottomNavigationBarItem> items = [];

    if (widget.role == 'technician') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Tablero'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Inventario'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
      ];
    } else if (widget.role == 'admin') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Stats'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
      ];
    } else {
      // Client
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Servicios'),
        BottomNavigationBarItem(icon: Icon(Icons.emergency_outlined), label: 'S.O.S'),
      ];
    }

    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
      },
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.build),
          label: 'Reparaciones',
        ),
        NavigationDestination(
          icon: Icon(Icons.sos),
          label: 'SOS',
        ),
        NavigationDestination(
          icon: Icon(Icons.speaker_group),
          label: 'Alquiler',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu),
          label: 'Opciones',
        ),
      ],
    );
  }

  Widget? _buildFab() {
    if (widget.role == 'technician' && _currentIndex == 0) {
      return FloatingActionButton(
        onPressed: () {},
        backgroundColor: BrandColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return null;
  }
}

class UserProfileDialog extends StatefulWidget {
  const UserProfileDialog({super.key});

  @override
  State<UserProfileDialog> createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _aliasController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  // Address controllers
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  
  bool _isEditing = false;
  bool _isUploadingAvatar = false;
  String _profileImage = '';
  String _phoneCode = '+57';
  int _tabIndex = 0; // 0: Información, 1: Dirección
  
  final user = SupabaseService.currentUser;

  @override
  void initState() {
    super.initState();
    final metadata = user?.userMetadata ?? {};
    
    _nameController = TextEditingController(text: metadata['full_name'] ?? '');
    _aliasController = TextEditingController(text: metadata['dj_alias'] ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    // Address
    _addressLine1Controller = TextEditingController(text: metadata['address_line1'] ?? '');
    _addressLine2Controller = TextEditingController(text: metadata['address_line2'] ?? '');
    _cityController = TextEditingController(text: metadata['city'] ?? '');
    _stateController = TextEditingController(text: metadata['state'] ?? '');
    _postalCodeController = TextEditingController(text: metadata['postal_code'] ?? '');
    _countryController = TextEditingController(text: metadata['country'] ?? '');

    // Prefer our stored avatar_url, then provider picture
    final avatar = (metadata['avatar_url'] ?? metadata['picture'])?.toString();
    _profileImage = avatar ?? '';
    
    String phone = metadata['phone'] ?? '';
    // Attempt to extract country code if it matches common ones or starts with +
    if (phone.startsWith('+57')) {
       _phoneCode = '+57';
       if (phone.length > 3) phone = phone.substring(3).trim();
    }
    _phoneController = TextEditingController(text: phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    try {
      final updates = <String, dynamic>{
        'full_name': _nameController.text.trim(),
        'dj_alias': _aliasController.text.trim(),
        'phone': '$_phoneCode${_phoneController.text.trim()}',
        // Address
        'address_line1': _addressLine1Controller.text.trim(),
        'address_line2': _addressLine2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
        'country': _countryController.text.trim(),
      };

      // Update metadata
      await SupabaseService.updateUser(data: updates);
      
      // Update email if changed
      if (_emailController.text.trim() != user?.email) {
        await SupabaseService.updateUser(email: _emailController.text.trim());
      }

      setState(() {
        _isEditing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _changeProfilePhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: BrandColors.primary),
              title: const Text('Tomar foto', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadAvatar(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: BrandColors.primary),
              title: const Text('Elegir de galería', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadAvatar(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar({required bool fromCamera}) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file == null) return;

      setState(() => _isUploadingAvatar = true);

      final bytes = await file.readAsBytes();
      final contentType = _inferContentType(file.path);

      final url = await SupabaseService.uploadAvatarBytes(bytes: bytes, contentType: contentType);

      if (!mounted) return;
      setState(() {
        _profileImage = url;
        _isUploadingAvatar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto de perfil actualizada')));
    } catch (e) {
      debugPrint('Avatar upload failed: $e');
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la foto: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _inferContentType(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    if (p.endsWith('.heic') || p.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final metadata = user?.userMetadata ?? {};
    final idType = metadata['id_type'] ?? 'ID';
    final idNumber = metadata['id_number'] ?? 'N/A';
    final role = metadata['role'] ?? 'client';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF1E1E1E),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Image
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: BrandColors.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _profileImage.isNotEmpty ? NetworkImage(_profileImage) : null,
                      child: _profileImage.isEmpty 
                          ? const Icon(Icons.person, size: 50, color: Colors.white54)
                          : null,
                    ),
                  ),
                  if (_isUploadingAvatar)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      ),
                    ),
                  if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _changeProfilePhoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: BrandColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Name & Alias Section (Centered)
              if (_isEditing) ...[
                TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'Nombre Completo',
                    labelStyle: TextStyle(color: Colors.grey),
                    alignLabelWithHint: true,
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BrandColors.primary)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _aliasController,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: BrandColors.primary, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'DJ Alias / A.K.A',
                    labelStyle: TextStyle(color: Colors.grey),
                    alignLabelWithHint: true,
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BrandColors.primary)),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Text(
                  _nameController.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_aliasController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _aliasController.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: BrandColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                
                // Role Badge
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(
                     color: BrandColors.primary.withValues(alpha: 0.2),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Text(
                     role.toString().toUpperCase(),
                     style: const TextStyle(
                       color: BrandColors.primary,
                       fontSize: 10,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                ),
                const SizedBox(height: 8),
                
                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                  onPressed: _toggleEdit,
                  tooltip: 'Editar perfil',
                ),
              ],
              
              // Tabs: Información / Dirección
              DefaultTabController(
                length: 2,
                initialIndex: _tabIndex,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TabBar(
                      onTap: (i) => setState(() => _tabIndex = i),
                      indicatorColor: BrandColors.primary,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(icon: Icon(Icons.info_outline), text: 'Información'),
                        Tab(icon: Icon(Icons.location_on_outlined), text: 'Dirección'),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              
              // Tab content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _tabIndex == 0
                    ? Column(
                        key: const ValueKey('info-tab'),
                        children: [
                          // 1. ID Document (Read-Only)
                          _buildReadOnlyRow(Icons.badge_outlined, '$idType $idNumber', 'Documento de Identidad'),
                          const SizedBox(height: 16),
                          // 2. Phone (Editable)
                          if (_isEditing) ...[
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
                                  ),
                                  child: CountryCodePicker(
                                    onChanged: (code) => _phoneCode = code.dialCode ?? '+57',
                                    initialSelection: 'CO',
                                    favorite: const ['+57', 'CO'],
                                    showCountryOnly: false,
                                    showOnlyCountryWhenClosed: false,
                                    alignLeft: false,
                                    textStyle: const TextStyle(color: Colors.white),
                                    dialogTextStyle: const TextStyle(color: Colors.black),
                                    searchDecoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.search),
                                      hintText: 'Buscar país',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'Celular',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BrandColors.primary)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            _buildReadOnlyRow(Icons.phone_outlined, '$_phoneCode ${_phoneController.text}', 'Celular'),
                          ],
                          const SizedBox(height: 16),
                          // 3. Email (Editable)
                          if (_isEditing)
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Correo Electrónico',
                                labelStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BrandColors.primary)),
                              ),
                            )
                          else
                            _buildReadOnlyRow(Icons.email_outlined, _emailController.text, 'Correo Electrónico'),
                          const SizedBox(height: 32),
                        ],
                      )
                    : Column(
                        key: const ValueKey('address-tab'),
                        children: [
                          if (_isEditing) ...[
                            TextField(
                              controller: _addressLine1Controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Dirección',
                                labelStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BrandColors.primary)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _addressLine2Controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Complemento (Apto, Interior, etc.)',
                                labelStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(Icons.home_work_outlined, color: Colors.grey),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BrandColors.primary)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _cityController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'Ciudad',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BrandColors.primary)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _stateController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'Departamento/Estado',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BrandColors.primary)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _postalCodeController,
                                    keyboardType: TextInputType.streetAddress,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'Código Postal',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BrandColors.primary)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _countryController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'País',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BrandColors.primary)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            _buildReadOnlyRow(Icons.location_on_outlined, _addressLine1Controller.text.isEmpty
                                ? 'No especificado'
                                : _addressLine1Controller.text, 'Dirección'),
                            const SizedBox(height: 12),
                            if (_addressLine2Controller.text.isNotEmpty)
                              _buildReadOnlyRow(Icons.home_work_outlined, _addressLine2Controller.text, 'Complemento'),
                            const SizedBox(height: 12),
                            _buildReadOnlyRow(Icons.location_city_outlined, _cityController.text.isEmpty ? 'No especificado' : _cityController.text, 'Ciudad'),
                            const SizedBox(height: 12),
                            _buildReadOnlyRow(Icons.map_outlined, _stateController.text.isEmpty ? 'No especificado' : _stateController.text, 'Departamento/Estado'),
                            const SizedBox(height: 12),
                            _buildReadOnlyRow(Icons.local_post_office_outlined, _postalCodeController.text.isEmpty ? 'No especificado' : _postalCodeController.text, 'Código Postal'),
                            const SizedBox(height: 12),
                            _buildReadOnlyRow(Icons.flag_outlined, _countryController.text.isEmpty ? 'No especificado' : _countryController.text, 'País'),
                            const SizedBox(height: 32),
                          ],
                        ],
                      ),
              ),
              
              // Action Buttons
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _toggleEdit,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BrandColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                )
              else
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await SupabaseService.signOut();
                      if (context.mounted) {
                        context.pop(); // Close dialog
                        context.go(AppRoutes.login); // Logout action
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A2A),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyRow(IconData icon, String text, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          if (label == 'Documento de Identidad')
             Column(
               children: [
                 const Icon(Icons.lock_outline, color: Colors.grey, size: 16),
                 if (text.isEmpty)
                   Padding(
                     padding: const EdgeInsets.only(top: 4.0),
                     child: Text(
                       'Requerido',
                       style: TextStyle(color: Colors.red[400], fontSize: 9),
                     ),
                   ),
               ],
             ),
        ],
      ),
    );
  }
}
