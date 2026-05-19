import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../globals.dart';
import '../data/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'rentador'; 
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Verificar que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(tr('Las contraseñas no coinciden', 'Passwords do not match')),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Preparar los datos del usuario
    final dbHelper = DatabaseHelper();
    final uuid = const Uuid().v4();

    final userData = {
      'id': uuid,
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim().toLowerCase(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text, 
      'role': _selectedRole,
      'location': 'Sin definir',
      'favorites': '[]',
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Intentar registrar en base de datos
    final success = await dbHelper.registerUser(userData);

    // Para ver en consola
    await dbHelper.printTableData('users');

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Text(
              tr('Usuario registrado con éxito', 'User registered successfully'),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text(
              tr('Error: El correo ya está registrado', 'Error: Email already exists'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Crear Cuenta', 'Create Account'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                tr('Únete a AgroGo y comienza a ', 'Join AgroGo and start ') + 
                (_selectedRole == 'rentador' ? tr('rentar maquinaria', 'renting machinery') : tr('poner en alquiler tus tractores', 'listing your tractors')),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),
              
              _buildRoleSelector(isDark),
              
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: tr('Nombre Completo', 'Full Name'),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) => value == null || value.isEmpty ? tr('Campo requerido', 'Required field') : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: tr('Correo electrónico', 'Email'),
                        prefixIcon: const Icon(Icons.mail_outline),
                      ),
                      validator: (value) => value == null || !value.contains('@') ? tr('Correo inválido', 'Invalid email') : null,
                    ),
                    const SizedBox(height: 16),

                    // --- CAMPO DE TELÉFONO ARREGLADO ---
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10, // <--- Límite de 10 números
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // <--- Bloquea letras o símbolos raros
                      ],
                      decoration: InputDecoration(
                        labelText: tr('Teléfono', 'Phone'),
                        prefixIcon: const Icon(Icons.phone_outlined),
                        counterText: '', // <--- Oculta el contador de "0/10" para que se vea limpio
                      ),
                      validator: (value) => value == null || value.length < 10 ? tr('Ingresa 10 dígitos', 'Enter 10 digits') : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: tr('Contraseña', 'Password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 6 ? tr('Mínimo 6 caracteres', 'At least 6 characters') : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: tr('Confirmar Contraseña', 'Confirm Password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return tr('Las contraseñas no coinciden', 'Passwords do not match');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                tr('Registrarse como ', 'Register as ') + 
                                (_selectedRole == 'rentador' ? tr('Rentador', 'Renter') : tr('Arrendador', 'Landlord')),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildRoleSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = 'rentador'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedRole == 'rentador' 
                      ? AppTheme.primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedRole == 'rentador'
                      ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Text(
                  tr('Rentador', 'Renter'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedRole == 'rentador' ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = 'arrendador'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedRole == 'arrendador' 
                      ? AppTheme.primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedRole == 'arrendador'
                      ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Text(
                  tr('Arrendador', 'Landlord'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedRole == 'arrendador' ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
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