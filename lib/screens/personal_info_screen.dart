import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../globals.dart'; // <--- IMPORT GLOBAL

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = MockData.currentUser;
    _nameController = TextEditingController(text: user.name);
    _locationController = TextEditingController(text: user.location);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      // Aquí en un futuro conectarías con tu base de datos o API.
      MockData.currentUser.name = _nameController.text;
      MockData.currentUser.location = _locationController.text;
      MockData.currentUser.email = _emailController.text;
      MockData.currentUser.phone = _phoneController.text;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Información actualizada correctamente', 'Information updated successfully')), // TRADUCCIÓN
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark; // DETECCIÓN DE TEMA

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Información Personal', 'Personal Information')), // TRADUCCIÓN
        backgroundColor: isDark ? Colors.grey[900] : Colors.white, // ADAPTACIÓN
        foregroundColor: isDark ? Colors.white : Colors.black, // ADAPTACIÓN
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr("Edita tus datos", "Edit your data"), // TRADUCCIÓN
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                tr(
                  "Asegúrate de que la información coincida con tus documentos oficiales para poder rentar maquinaria.",
                  "Make sure the information matches your official documents to be able to rent machinery."
                ), // TRADUCCIÓN
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]), // ADAPTACIÓN
              ),
              const SizedBox(height: 30),

              // Campo: Nombre
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: tr('Nombre completo', 'Full name'), // TRADUCCIÓN
                  prefixIcon: const Icon(Icons.person_outline),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return tr('El nombre es requerido', 'Name is required'); // TRADUCCIÓN
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo: Ubicación
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: tr('Ubicación (Ciudad, Estado)', 'Location (City, State)'), // TRADUCCIÓN
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return tr('La ubicación es requerida', 'Location is required'); // TRADUCCIÓN
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo: Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: tr('Correo electrónico', 'Email address'), // TRADUCCIÓN
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@')) return tr('Ingresa un correo válido', 'Enter a valid email'); // TRADUCCIÓN
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo: Teléfono
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: tr('Teléfono', 'Phone number'), // TRADUCCIÓN
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _guardarCambios,
                  child: Text(tr('Guardar cambios', 'Save changes'), style: const TextStyle(fontSize: 16)), // TRADUCCIÓN
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}