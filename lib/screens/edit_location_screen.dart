import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../globals.dart';
import '../data/database_helper.dart';

class EditLocationScreen extends StatefulWidget {
  final String currentLocation;

  const EditLocationScreen({super.key, required this.currentLocation});

  @override
  State<EditLocationScreen> createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final TextEditingController _currentLocationController = TextEditingController();
  final TextEditingController _newLocationController = TextEditingController();
  final TextEditingController _confirmLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentLocationController.text = widget.currentLocation;
  }

  @override
  void dispose() {
    _currentLocationController.dispose();
    _newLocationController.dispose();
    _confirmLocationController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final currentEmail = currentUserEmailNotifier.value;
    if (currentEmail == null) return;

    setState(() => _isSaving = true);
    final dbHelper = DatabaseHelper();
    final success = await dbHelper.updateUserByEmail(currentEmail, {
      'location': _newLocationController.text.trim(),
    });

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Ubicación actualizada con éxito', 'Location updated successfully')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, _newLocationController.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('No se pudo actualizar la ubicación', 'Could not update location')),
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
          tr('Actualizar Ubicación', 'Update Location'),
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
                  tr('Ubicación', 'Location'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr(
                    'Actualiza tu ciudad y estado para que los rentadores te encuentren.',
                    'Update your city and state so renters can find you.',
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                _buildReadOnlyField(
                  controller: _currentLocationController,
                  label: tr('Ubicación anterior', 'Previous location'),
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                _buildEditableField(
                  controller: _newLocationController,
                  label: tr('Ubicación nueva (Ciudad, Estado)', 'New location (City, State)'),
                  isDark: isDark,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return tr('Por favor ingresa tu nueva ubicación', 'Please enter your new location');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildEditableField(
                  controller: _confirmLocationController,
                  label: tr('Confirmar ubicación nueva', 'Confirm new location'),
                  isDark: isDark,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return tr('Por favor confirma la ubicación nueva', 'Please confirm the new location');
                    }
                    if (value.trim() != _newLocationController.text.trim()) {
                      return tr('Las ubicaciones no coinciden', 'Locations do not match');
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
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
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
    required bool isDark,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.location_on, color: AppTheme.primaryColor),
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
