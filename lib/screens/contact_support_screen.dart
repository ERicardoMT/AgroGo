import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart';
import '../theme/app_theme.dart';
import '../data/database_helper.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController(text: 'Soporte requerido en AgroGo');
  final _messageController = TextEditingController();
  
  bool _isOpeningMail = false;
  bool _isLoading = true;

  static const String _supportEmail = 'soporte.agrogo@gmail.com';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _messageController.text = tr(
      'Hola equipo de AgroGo,\n\nNecesito apoyo con la siguiente situación:\n\n'
      '- Tipo de problema:\n'
      '- Pantalla donde ocurrió:\n'
      '- Descripción:\n\n'
      'Quedo atento a su respuesta.\n',
      'Hello AgroGo team,\n\nI need help with the following situation:\n\n'
      '- Problem type:\n'
      '- Screen where it happened:\n'
      '- Description:\n\n'
      'I look forward to your response.\n',
    );
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
          _emailController.text = currentEmail;
        });
      } catch (e) {
        setState(() {
          _nameController.text = 'Usuario';
          _emailController.text = currentEmail ?? '';
        });
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendSupportEmail() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isOpeningMail = true);

    final subject = Uri.encodeComponent(_subjectController.text.trim());
    final body = Uri.encodeComponent(
      '''
Nombre: ${_nameController.text.trim()}
Correo de contacto: ${_emailController.text.trim()}

Mensaje:
${_messageController.text.trim()}

---
Enviado desde AgroGo App
''',
    );
    final uri = Uri.parse('mailto:$_supportEmail?subject=$subject&body=$body');

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) _showError();
    } catch (_) {
      if (mounted) _showError();
    }

    if (mounted) setState(() => _isOpeningMail = false);
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        content: Text(
          tr('No se pudo abrir la app de correo. Revisa que tengas una cuenta configurada.',
             'Could not open the mail app. Make sure you have an email account configured.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(tr('Contactar soporte', 'Contact Support'))),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSupportHeader(context, isDark),
              const SizedBox(height: 20),
              _buildSupportForm(context),
            ],
          ),
    );
  }

  Widget _buildSupportHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF333333) : AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.mark_email_read_outlined, color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tr('Cuéntanos qué ocurrió. Se abrirá tu aplicación de correo con el mensaje listo para enviar.',
                 'Tell us what happened. Your email app will open with the message ready to send.'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            enabled: false,
            decoration: InputDecoration(labelText: tr('Nombre', 'Name'), prefixIcon: const Icon(Icons.person_outline_rounded)),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            enabled: false,
            decoration: InputDecoration(labelText: tr('Correo de contacto', 'Contact email'), prefixIcon: const Icon(Icons.email_outlined)),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _subjectController,
            decoration: InputDecoration(labelText: tr('Asunto', 'Subject'), prefixIcon: const Icon(Icons.subject_rounded)),
            validator: (value) => (value ?? '').trim().isEmpty ? tr('Escribe el asunto del mensaje.', 'Enter the message subject.') : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _messageController,
            minLines: 7, maxLines: 10,
            decoration: InputDecoration(
              labelText: tr('Mensaje', 'Message'),
              alignLabelWithHint: true,
              prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 116), child: Icon(Icons.edit_note_rounded)),
            ),
            validator: (value) => (value ?? '').trim().length < 15 ? tr('Describe un poco más tu situación.', 'Describe your situation with more detail.') : null,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isOpeningMail ? null : _sendSupportEmail,
              icon: _isOpeningMail
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                  : const Icon(Icons.send_rounded),
              label: Text(tr('Abrir correo de soporte', 'Open support email')),
            ),
          ),
        ],
      ),
    );
  }
}