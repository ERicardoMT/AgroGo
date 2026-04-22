import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import 'personal_info_screen.dart';
import '../globals.dart'; // <--- Importamos los megáfonos globales

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  String? _illustrationUrl; 
  final ImagePicker _picker = ImagePicker();

  final List<String> _ilustraciones = [
    'https://api.dicebear.com/7.x/adventurer/png?seed=Felix',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Aneka',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Mimi',
    'https://api.dicebear.com/7.x/bottts/png?seed=Tractor',
    'https://api.dicebear.com/7.x/bottts/png?seed=Agro',
    'https://api.dicebear.com/7.x/fun-emoji/png?seed=Feliz',
  ];

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); 
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _illustrationUrl = null; 
        });
      }
    } catch (e) {
      print("Error al seleccionar imagen: $e");
    }
  }

  void _seleccionarIlustracion(String url) {
    setState(() {
      _imageFile = null; 
      _illustrationUrl = url; 
    });
    Navigator.pop(context); 
    Navigator.pop(context); 
  }

  void _mostrarIlustraciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(tr("Elige una ilustración", "Choose an illustration"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: _ilustraciones.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _seleccionarIlustracion(_ilustraciones[index]),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(_ilustraciones[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
  
  void _mostrarOpcionesDeFoto(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr("Cambiar imagen de perfil", "Change profile picture"),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.face, color: Colors.green),
                title: Text(tr("Ver ilustraciones", "See illustrations")),
                onTap: () => _mostrarIlustraciones(context),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: Text(tr("Subir desde dispositivo", "Upload from device")),
                onTap: () => _pickImage(ImageSource.gallery), 
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: Text(tr("Hacer una foto", "Take a photo")),
                onTap: () => _pickImage(ImageSource.camera), 
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarOpcionesIdioma(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return ValueListenableBuilder<String>(
          valueListenable: languageNotifier,
          builder: (context, idioma, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tr("Selecciona un idioma", "Select a language"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  ListTile(
                    title: const Text("Español"),
                    trailing: idioma == 'Español' ? const Icon(Icons.check, color: Colors.green) : null,
                    onTap: () {
                      languageNotifier.value = 'Español';
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text("English"),
                    trailing: idioma == 'Inglés' ? const Icon(Icons.check, color: Colors.green) : null,
                    onTap: () {
                      languageNotifier.value = 'Inglés';
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  ImageProvider? _obtenerImagenAvatar() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (_illustrationUrl != null) {
      return NetworkImage(_illustrationUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white, 
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _mostrarOpcionesDeFoto(context),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          backgroundImage: _obtenerImagenAvatar(), 
                          child: _imageFile == null && _illustrationUrl == null
                              ? Text(
                                  user.name.split(' ').map((n) => n[0]).take(2).join(),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                )
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt, size: 20, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.location,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat(context, '${MockData.bookings.length}', tr('Reservas', 'Bookings')),
                      Container(width: 1, height: 40, color: AppTheme.borderColor),
                      _buildStat(context, '12', tr('Equipos rentados', 'Rented equip.')),
                      Container(width: 1, height: 40, color: AppTheme.borderColor),
                      _buildStat(context, '4.8', tr('Calificación', 'Rating')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildMenuSection(context, tr('Cuenta', 'Account'), [
              _MenuItem(
                icon: Icons.person_outline,
                title: tr('Información personal', 'Personal Information'),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                  );
                  if (result == true) {
                    setState(() {}); 
                  }
                },
              ),
              _MenuItem(
                icon: Icons.credit_card_outlined,
                title: tr('Métodos de pago', 'Payment Methods'),
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.location_on_outlined,
                title: tr('Direcciones', 'Addresses'),
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 16),

            _buildMenuSection(context, tr('Preferencias', 'Preferences'), [
              _MenuItem(
                icon: Icons.notifications_outlined,
                title: tr('Notificaciones', 'Notifications'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: AppTheme.primaryColor,
                ),
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.language_outlined,
                title: tr('Idioma', 'Language'),
                subtitle: tr('Español', 'English'),
                onTap: () => _mostrarOpcionesIdioma(context),
              ),
              _MenuItem(
                icon: Icons.dark_mode_outlined,
                title: tr('Modo oscuro', 'Dark mode'),
                trailing: ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (context, currentMode, child) {
                    return Switch(
                      value: currentMode == ThemeMode.dark,
                      onChanged: (value) {
                        themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                      },
                      activeColor: AppTheme.primaryColor,
                    );
                  },
                ),
                onTap: () {
                  final isDark = themeNotifier.value == ThemeMode.dark;
                  themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
            ]),

            const SizedBox(height: 16),

            _buildMenuSection(context, tr('Soporte', 'Support'), [
              _MenuItem(
                icon: Icons.help_outline,
                title: tr('Centro de ayuda', 'Help Center'),
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.chat_outlined,
                title: tr('Contactar soporte', 'Contact Support'),
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.description_outlined,
                title: tr('Términos y condiciones', 'Terms & Conditions'),
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                label: Text(
                  tr('Cerrar sesión', 'Log out'),
                  style: const TextStyle(color: AppTheme.errorColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              tr('Versión 1.0.0', 'Version 1.0.0'),
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMenuSection(
      BuildContext context, String title, List<_MenuItem> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
            ),
          ),
          ...items.map((item) => _buildMenuItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(
        item.icon,
        color: isDark ? Colors.white : Colors.black87,
      ),
      title: Text(item.title),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      trailing: item.trailing ??
          Icon(
            Icons.chevron_right,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
      onTap: item.onTap,
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });
}