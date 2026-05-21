import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../globals.dart';
import '../data/database_helper.dart';

class EditNameScreen extends StatefulWidget {
  final String currentName;

  const EditNameScreen({super.key, required this.currentName});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final TextEditingController _currentNameController = TextEditingController();
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _confirmNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentNameController.text = widget.currentName;
  }

  @override
  void dispose() {
    _currentNameController.dispose();
    _newNameController.dispose();
    _confirmNameController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final currentEmail = currentUserEmailNotifier.value;
    if (currentEmail == null) return;

    setState(() => _isSaving = true);
    final dbHelper = DatabaseHelper();
    final success = await dbHelper.updateUserByEmail(currentEmail, {
      'name': _newNameController.text.trim(),
    });

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Nombre actualizado con éxito', 'Name updated successfully')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, _newNameController.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('No se pudo actualizar el nombre', 'Could not update name')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          tr('Actualizar Nombre', 'Update Name'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Información Personal', 'Personal Information'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr('Actualiza tu nombre completo.', 'Update your full name.'),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                _buildReadOnlyField(
                  controller: _currentNameController,
                  label: tr('Nombre anterior', 'Previous name'),
                  icon: Icons.person_outline,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                _buildEditableField(
                  controller: _newNameController,
                  label: tr('Nombre nuevo', 'New name'),
                  icon: Icons.person,
                  isDark: isDark,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return tr('Por favor ingresa tu nuevo nombre', 'Please enter your new name');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildEditableField(
                  controller: _confirmNameController,
                  label: tr('Confirmar nombre nuevo', 'Confirm new name'),
                  icon: Icons.person_pin,
                  isDark: isDark,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return tr('Por favor confirma el nombre nuevo', 'Please confirm the new name');
                    }
                    if (value.trim() != _newNameController.text.trim()) {
                      return tr('Los nombres no coinciden', 'Names do not match');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _guardarCambios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            tr('Guardar Información', 'Save Information'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
