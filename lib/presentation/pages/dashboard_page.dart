import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';
import '../../data/mock_data.dart';
import '../../nav.dart';
import 'home_page.dart';
import 'services_page.dart';
import 'emergency_page.dart';
import 'inbox_page.dart';
import 'technician_page.dart';

class DashboardPage extends StatefulWidget {
  final String role;
  const DashboardPage({super.key, this.role = 'client'});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

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
            child: const Text('JP'),
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
      destinations: items.map((item) => NavigationDestination(
        icon: item.icon,
        label: item.label!,
      )).toList(),
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
  bool _isEditing = false;
  String _profileImage = 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&q=80&w=200';
  
  // Use mock data
  final user = MockData.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: user.name);
    _aliasController = TextEditingController(text: user.djAlias ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    // In a real app, update the backend/provider here
    setState(() {
      // For now just toggle back, assuming "saved"
      _isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado')),
    );
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
              onTap: () {
                // Mock action
                Navigator.pop(context);
                setState(() {
                  _profileImage = 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&q=80&w=200';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Foto actualizada (Simulado)')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: BrandColors.primary),
              title: const Text('Elegir de galería', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _profileImage = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Foto actualizada (Simulado)')),
                );
              },
            ),
            if (_profileImage.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text('Eliminar foto', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = ''; // Or set to a placeholder
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto eliminada')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF1E1E1E),
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
              
              // Name & Alias Section
              if (_isEditing) ...[
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nombre Completo',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BrandColors.primary)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _aliasController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'DJ Alias / A.K.A',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BrandColors.primary)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _toggleEdit,
                      child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          Text(
                            _nameController.text, // Use controller text to reflect changes immediately
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_aliasController.text.isNotEmpty)
                            Text(
                              _aliasController.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: BrandColors.primary.withValues(alpha: 0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                      onPressed: _toggleEdit,
                      tooltip: 'Editar nombre',
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),
              
              // Role Badge
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                 decoration: BoxDecoration(
                   color: BrandColors.primary.withValues(alpha: 0.2),
                   borderRadius: BorderRadius.circular(20),
                 ),
                 child: Text(
                   user.role.name.toUpperCase(),
                   style: const TextStyle(
                     color: BrandColors.primary,
                     fontSize: 10,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
              ),
              const SizedBox(height: 24),
              
              // Info items (Read Only)
              _buildInfoRow(Icons.email_outlined, user.email),
              _buildInfoRow(Icons.phone_outlined, user.phoneNumber),
              // ID is strictly read-only as requested
              _buildInfoRow(Icons.badge_outlined, '${user.idType ?? "CC"} ${user.idNumber ?? "N/A"}'),
              
              const SizedBox(height: 32),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pop(); // Close dialog
                    context.go(AppRoutes.login); // Logout action using AppRoutes
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
        ],
      ),
    );
  }
}
