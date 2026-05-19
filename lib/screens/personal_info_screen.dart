import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../globals.dart';
import '../data/database_helper.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final dbHelper = DatabaseHelper();
    final users = await dbHelper.getAll('users');
    final currentEmail = currentUserEmailNotifier.value;

    if (users.isNotEmpty && currentEmail != null) {
      try {
        final miUsuario = users.firstWhere((user) => user['email'] == currentEmail);
        setState(() {
          _nameController.text = miUsuario['name']?.toString() ?? '';
          _locationController.text = miUsuario['location']?.toString() ?? 'Sin definir';
          _emailController.text = miUsuario['email']?.toString() ?? '';
          _phoneController.text = miUsuario['phone']?.toString() ?? '';
        });
      } catch (e) {
        print("Usuario no encontrado");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      final currentEmail = currentUserEmailNotifier.value;

      if (currentEmail != null) {
        await db.update(
          'users',
          {
            'name': _nameController.text.trim(),
            'location': _locationController.text.trim(),
            'phone': _phoneController.text.trim(),
          },
          where: 'email = ?',
          whereArgs: [currentEmail],
        );
      }

      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('Información actualizada correctamente', 'Information updated successfully')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); 
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Información Personal', 'Personal Information')),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr("Edita tus datos", "Edit your data"),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(
                      "Asegúrate de que la información coincida con tus documentos oficiales para poder rentar maquinaria.",
                      "Make sure the information matches your official documents to be able to rent machinery."
                    ),
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: tr('Nombre completo', 'Full name'),
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? tr('El nombre es requerido', 'Name is required') : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: tr('Ubicación (Ciudad, Estado)', 'Location (City, State)'),
                      prefixIcon: const Icon(Icons.location_city_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? tr('La ubicación es requerida', 'Location is required') : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    enabled: false, 
                    decoration: InputDecoration(
                      labelText: tr('Correo electrónico (No editable)', 'Email address'),
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: const OutlineInputBorder(),
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: tr('Teléfono', 'Phone number'),
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: const OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _guardarCambios,
                      child: Text(tr('Guardar cambios', 'Save changes'), style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}