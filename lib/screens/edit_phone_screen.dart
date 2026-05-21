import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../globals.dart';
import '../data/database_helper.dart';

class EditPhoneScreen extends StatefulWidget {
  final String currentPhone;

  const EditPhoneScreen({super.key, required this.currentPhone});

  @override
  State<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  
  final TextEditingController _currentPhoneController = TextEditingController();
  final TextEditingController _newPhoneController = TextEditingController();
  final TextEditingController _confirmPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentPhoneController.text = widget.currentPhone;
  }

  @override
  void dispose() {
    _currentPhoneController.dispose();
    _newPhoneController.dispose();
    _confirmPhoneController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final currentEmail = currentUserEmailNotifier.value;
    if (currentEmail == null) return;

    setState(() => _isSaving = true);
    final success = await DatabaseHelper().updateUserByEmail(currentEmail, {
      'phone': _newPhoneController.text.trim(),
    });

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Teléfono actualizado con éxito', 'Phone updated successfully')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, _newPhoneController.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('No se pudo actualizar el teléfono', 'Could not update phone')),
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
          tr('Actualizar Teléfono', 'Update Phone'),
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
                  tr('Número de Contacto', 'Contact Number'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr('Actualiza tu número telefónico para mantenerte en contacto.', 'Update your phone number to stay in touch.'),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Campo: Teléfono actual
                TextFormField(
                  controller: _currentPhoneController,
                  readOnly: true,
                  style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                  decoration: InputDecoration(
                    labelText: tr('Teléfono anterior', 'Previous phone'),
                    prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo: Teléfono nuevo
                TextFormField(
                  controller: _newPhoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: tr('Teléfono nuevo', 'New phone'),
                    prefixIcon: const Icon(Icons.phone, color: AppTheme.primaryColor),
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
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('Por favor ingresa tu nuevo teléfono', 'Please enter your new phone');
                    }
                    if (value.length < 10) {
                      return tr('Ingresa 10 dígitos', 'Enter 10 digits');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: Confirmar Teléfono nuevo
                TextFormField(
                  controller: _confirmPhoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: tr('Confirmar teléfono nuevo', 'Confirm new phone'),
                    prefixIcon: const Icon(Icons.phone_iphone, color: AppTheme.primaryColor),
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
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('Por favor confirma tu nuevo teléfono', 'Please confirm your new phone');
                    }
                    if (value != _newPhoneController.text) {
                      return tr('Los números no coinciden', 'Phone numbers do not match');
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
}
