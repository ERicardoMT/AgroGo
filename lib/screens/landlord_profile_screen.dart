import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../globals.dart';
import 'help_center_screen.dart';
import 'contact_support_screen.dart';
import 'terms_conditions_screen.dart';
import 'banking_details_screen.dart';
import 'edit_email_screen.dart';
import 'edit_phone_screen.dart';
import 'edit_name_screen.dart';
import 'edit_location_screen.dart';
import '../data/database_helper.dart';

class LandlordProfileScreen extends StatefulWidget {
  const LandlordProfileScreen({super.key});

  @override
  State<LandlordProfileScreen> createState() => _LandlordProfileScreenState();
}

class _LandlordProfileData {
  String name;
  String location;
  int totalRentals;
  String totalIncome;
  double rating;
  String email;
  String phone;
  String registeredSince;
  int activeTractors;
  int totalReviews;

  _LandlordProfileData({
    required this.name,
    required this.location,
    required this.totalRentals,
    required this.totalIncome,
    required this.rating,
    required this.email,
    required this.phone,
    required this.registeredSince,
    required this.activeTractors,
    required this.totalReviews,
  });
}

class _LandlordProfileScreenState extends State<LandlordProfileScreen> {
  File? _imageFile;
  String? _illustrationUrl;
  final ImagePicker _picker = ImagePicker();

  final List<String> _ilustraciones = [
    'https://api.dicebear.com/7.x/adventurer/png?seed=Carlos',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Farmer',
    'https://api.dicebear.com/7.x/bottts/png?seed=TractorMaster',
    'https://api.dicebear.com/7.x/bottts/png?seed=AgriculturePro',
    'https://api.dicebear.com/7.x/fun-emoji/png?seed=Agricultor',
    'https://api.dicebear.com/7.x/fun-emoji/png?seed=Rentador',
  ];

  _LandlordProfileData? landlordData; // Cambia a opcional (?) y quita 'late'
  bool isLoading = true; // Variable para la pantalla de carga

  @override
  void initState() {
    super.initState();
    _loadUserFromDB();
  }

  Future<void> _loadUserFromDB() async {
    final dbHelper = DatabaseHelper();
    final users = await dbHelper.getAll('users');
    final currentEmail = currentUserEmailNotifier.value;

    final totalRentals = await dbHelper.getLandlordRentalsCount();
    final activeTractors = await dbHelper.getLandlordTractorsCount();
    final rating = await dbHelper.getUserAverageRating();
    final totalReviews = await dbHelper.getLandlordReviewsCount();
    final incomeAmount = await dbHelper.getLandlordTotalIncome();

    if (users.isNotEmpty && currentEmail != null) {
      try {
        final miUsuario = users.firstWhere((user) => user['email'] == currentEmail);
        final createdAt = miUsuario['createdAt']?.toString() ?? '';
        final profilePic = miUsuario['profile_picture']?.toString();

        if (!mounted) return;
        setState(() {
          if (profilePic != null && profilePic.isNotEmpty) {
            if (profilePic.startsWith('http')) {
              _illustrationUrl = profilePic;
              _imageFile = null;
            } else {
              _imageFile = File(profilePic);
              _illustrationUrl = null;
            }
          }
          landlordData = _LandlordProfileData(
            name: miUsuario['name']?.toString() ?? 'Usuario Sin Nombre',
            location: _formatLocation(miUsuario['location']?.toString()),
            email: miUsuario['email']?.toString() ?? 'Sin Correo',
            phone: miUsuario['phone']?.toString() ?? 'Sin Teléfono',
            totalRentals: totalRentals,
            totalIncome: '\$${incomeAmount.toStringAsFixed(2)}',
            rating: double.parse(rating.toStringAsFixed(1)),
            registeredSince:
                createdAt.length >= 4 ? createdAt.substring(0, 4) : '2024',
            activeTractors: activeTractors,
            totalReviews: totalReviews,
          );
          isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatLocation(String? location) {
    if (location == null || location.trim().isEmpty) {
      return tr('Sin definir', 'Not set');
    }
    return location;
  }

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
              Text(
                tr("Elige una ilustración", "Choose an illustration"),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
      },
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
                leading: const Icon(Icons.face, color: AppTheme.primaryColor),
                title: Text(tr("Ver ilustraciones", "See illustrations")),
                onTap: () => _mostrarIlustraciones(context),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
                title: Text(tr("Subir desde dispositivo", "Upload from device")),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ValueListenableBuilder<String>(
          valueListenable: languageNotifier,
          builder: (context, idioma, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr("Selecciona un idioma", "Select a language"),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ListTile(
                    title: const Text("Español"),
                    trailing: idioma == 'Español' ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                    onTap: () {
                      languageNotifier.value = 'Español';
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text("English"),
                    trailing: idioma == 'Inglés' ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                    onTap: () {
                      languageNotifier.value = 'Inglés';
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
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

  void _mostrarDialogoEdicion({
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) {
    final TextEditingController _controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: tr('Ingrese nuevo valor', 'Enter new value'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('Cancelar', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  onSave(_controller.text);
                });
                Navigator.pop(context);
              },
              child: Text(tr('Guardar', 'Save')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (landlordData == null) {
      return const Scaffold(body: Center(child: Text("No se encontró ningún usuario.")));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          tr('Mi Perfil', 'My Profile'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
                  ),
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
                            backgroundColor:
                                AppTheme.primaryColor.withOpacity(0.1),
                            backgroundImage: _obtenerImagenAvatar(),
                            child: _imageFile == null &&
                                    _illustrationUrl == null
                                ? Text(
                                    landlordData!.name
                                        .split(' ')
                                        .map((n) => n[0])
                                        .take(2)
                                        .join(),
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
                            child: Icon(Icons.camera_alt,
                                size: 20, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      landlordData!.name,
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
                          landlordData!.location,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(context,
                            landlordData!.totalRentals.toString(),
                            tr('Rentas', 'Rentals')),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.borderColor,
                        ),
                        _buildStat(context,
                            landlordData!.activeTractors.toString(),
                            tr('Tractores', 'Tractors')),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.borderColor,
                        ),
                        _buildStat(context, landlordData!.rating.toString(),
                            tr('Calificación', 'Rating')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money_rounded,
                            color: AppTheme.primaryColor, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('Ingresos Totales', 'Total Income'),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(fontSize: 11),
                              ),
                              Text(
                                landlordData!.totalIncome,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'ID: #${landlordData!.registeredSince}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuSection(context, tr('Cuenta', 'Account'), [
                _MenuItem(
                  icon: Icons.badge_outlined,
                  title: tr('Nombre Completo', 'Full Name'),
                  subtitle: landlordData!.name,
                  onTap: () async {
                    final newName = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditNameScreen(currentName: landlordData!.name),
                      ),
                    );
                    if (newName != null && newName.isNotEmpty) {
                      setState(() {
                        landlordData!.name = newName;
                      });
                    }
                  },
                ),
                _MenuItem(
                  icon: Icons.mail_outline,
                  title: tr('Correo electrónico', 'Email'),
                  subtitle: landlordData!.email,
                  onTap: () async {
                    final newEmail = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditEmailScreen(currentEmail: landlordData!.email),
                      ),
                    );
                    if (newEmail != null && newEmail.isNotEmpty) {
                      setState(() {
                        landlordData!.email = newEmail;
                      });
                    }
                  },
                ),
                _MenuItem(
                  icon: Icons.phone_outlined,
                  title: tr('Teléfono', 'Phone'),
                  subtitle: landlordData!.phone,
                  onTap: () async {
                    final newPhone = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditPhoneScreen(currentPhone: landlordData!.phone),
                      ),
                    );
                    if (newPhone != null && newPhone.isNotEmpty) {
                      setState(() {
                        landlordData!.phone = newPhone;
                      });
                    }
                  },
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  title: tr('Ubicación', 'Location'),
                  subtitle: landlordData!.location,
                  onTap: () async {
                    final newLocation = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditLocationScreen(
                          currentLocation: landlordData!.location,
                        ),
                      ),
                    );
                    if (newLocation != null && newLocation.isNotEmpty) {
                      setState(() {
                        landlordData!.location = newLocation;
                      });
                    }
                  },
                ),
                _MenuItem(
                  icon: Icons.business_outlined,
                  title: tr('Datos Bancarios', 'Banking Details'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BankingDetailsScreen(),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 16),
              _buildMenuSection(
                  context, tr('Preferencias', 'Preferences'), [
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
                          themeNotifier.value =
                              value ? ThemeMode.dark : ThemeMode.light;
                        },
                        activeColor: AppTheme.primaryColor,
                      );
                    },
                  ),
                  onTap: () {
                    final isDark = themeNotifier.value == ThemeMode.dark;
                    themeNotifier.value =
                        isDark ? ThemeMode.light : ThemeMode.dark;
                  },
                ),
              ]),
              const SizedBox(height: 16),
              _buildMenuSection(
                  context, tr('Soporte', 'Support'), [
                _MenuItem(
                  icon: Icons.help_outline,
                  title: tr('Centro de ayuda', 'Help Center'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpCenterScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.chat_outlined,
                  title: tr('Contactar soporte', 'Contact Support'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactSupportScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  title: tr('Términos y condiciones',
                      'Terms & Conditions'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TermsConditionsScreen(),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    isLoggedInNotifier.value = false;
                  },
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
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
        ),
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
