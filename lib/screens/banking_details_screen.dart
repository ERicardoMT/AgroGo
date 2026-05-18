import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../globals.dart';
import '../data/database_helper.dart'; // <-- IMPORT MBD

class BankingDetailsScreen extends StatefulWidget {
  const BankingDetailsScreen({super.key});

  @override
  State<BankingDetailsScreen> createState() => _BankingDetailsScreenState();
}

class _BankingDetailsScreenState extends State<BankingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true; // <-- Estado de carga
  
  // Controladores para los campos de datos bancarios (inicialmente vacíos)
  final TextEditingController _titularController = TextEditingController();
  final TextEditingController _bancoController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _swiftController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBankingDetails();
  }

  Future<void> _loadBankingDetails() async {
    final dbHelper = DatabaseHelper();
    final currentEmail = currentUserEmailNotifier.value;

    if (currentEmail != null) {
      final allAccounts = await dbHelper.getAll('bank_accounts');
      try {
        // Buscamos si este usuario ya tiene una cuenta (usaremos su email como ID para relacionarlo)
        final myAccount = allAccounts.firstWhere((acc) => acc['id'] == "bank_$currentEmail");
        setState(() {
          _titularController.text = myAccount['accountHolder']?.toString() ?? '';
          _bancoController.text = myAccount['bankName']?.toString() ?? '';
          _ibanController.text = myAccount['iban']?.toString() ?? '';
          _swiftController.text = myAccount['swiftCode']?.toString() ?? '';
        });
      } catch (e) {
        // No tiene cuenta registrada, los campos se quedan vacíos
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titularController.dispose();
    _bancoController.dispose();
    _ibanController.dispose();
    _swiftController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      final currentEmail = currentUserEmailNotifier.value;
      if (currentEmail == null) return;

      final dbHelper = DatabaseHelper();
      
      // Creamos el mapa de datos que coincida las columnas de SQLite
      final accountData = {
        'id': 'bank_$currentEmail', // Usamos el correo como base para enlazarlo con el usuario
        'accountHolder': _titularController.text.trim(),
        'bankName': _bancoController.text.trim(),
        'accountNumber': _ibanController.text.trim(), // Lo usamos como IBAN/Cuenta
        'accountType': 'checking', // Por defecto
        'swiftCode': _swiftController.text.trim(),
        'iban': _ibanController.text.trim(),
        'isDefault': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'documentUrl': '',
      };

      // Inserción en la base de datos local (reemplazará si ya existe con esa ID)
      await dbHelper.insert('bank_accounts', accountData);

      if (!mounted) return;

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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SafeArea(
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
