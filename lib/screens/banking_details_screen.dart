import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../globals.dart';

class BankingDetailsScreen extends StatefulWidget {
  const BankingDetailsScreen({super.key});

  @override
  State<BankingDetailsScreen> createState() => _BankingDetailsScreenState();
}

class _BankingDetailsScreenState extends State<BankingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos de datos bancarios
  final TextEditingController _titularController = TextEditingController(text: 'Carlos Rodríguez López');
  final TextEditingController _bancoController = TextEditingController(text: 'Banco Santander');
  final TextEditingController _ibanController = TextEditingController(text: 'ES91 1234 5678 9012 3456 7890');
  final TextEditingController _swiftController = TextEditingController(text: 'BSCHESMM');

  @override
  void dispose() {
    _titularController.dispose();
    _bancoController.dispose();
    _ibanController.dispose();
    _swiftController.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      // Aquí iría la lógica para guardar los datos en backend/base de datos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Datos bancarios guardados con éxito', 'Banking details saved successfully')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
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
          tr('Datos Bancarios', 'Banking Details'),
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
                  tr('Gestión de Pagos', 'Payment Management'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr('Ingresa la información bancaria donde recibirás los pagos por tus rentas.', 'Enter the banking information where you will receive payments for your rentals.'),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Campo: Titular de la cuenta
                _buildTextField(
                  controller: _titularController,
                  label: tr('Titular de la cuenta', 'Account Holder'),
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('Por favor ingresa el titular', 'Please enter the account holder');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: Banco
                _buildTextField(
                  controller: _bancoController,
                  label: tr('Nombre del Banco', 'Bank Name'),
                  icon: Icons.account_balance_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('Por favor ingresa el banco', 'Please enter the bank name');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: IBAN/Número de cuenta
                _buildTextField(
                  controller: _ibanController,
                  label: tr('IBAN / Número de cuenta', 'IBAN / Account Number'),
                  icon: Icons.numbers_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('Por favor ingresa el IBAN', 'Please enter the IBAN');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: SWIFT/BIC
                _buildTextField(
                  controller: _swiftController,
                  label: tr('Código SWIFT / BIC', 'SWIFT / BIC Code'),
                  icon: Icons.code,
                ),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _guardarCambios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      validator: validator,
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
        enabledBorder: OutlineInputBorder(
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
    );
  }
}
