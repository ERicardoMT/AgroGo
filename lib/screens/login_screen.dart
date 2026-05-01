import 'package:flutter/material.dart';
import '../globals.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController(
    text: 'carlos.mendoza@email.com',
  );
  final _passwordController = TextEditingController(
    text: 'agrogo123',
  );

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String _selectedRole = 'rentador'; // 'rentador' o 'arrendador'

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  static const String _demoEmail = 'carlos.mendoza@email.com';
  static const String _demoPassword = 'agrogo123';

  @override
  void initState() {
    super.initState();

    // Optimización de UI: una sola animación controla entrada y opacidad,
    // evitando varios controllers innecesarios para una pantalla ligera.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Simulación realista de autenticación.
    // Cuando conecten backend/Firebase/API, este bloque se reemplaza por la llamada HTTP.
    await Future.delayed(const Duration(milliseconds: 750));

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email == _demoEmail && password == _demoPassword) {
      userRoleNotifier.value = _selectedRole;
      isLoggedInNotifier.value = true;
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.errorColor,
          content: Text(
            tr(
              'Correo o contraseña incorrectos. Usa la cuenta demo.',
              'Wrong email or password. Use the demo account.',
            ),
          ),
        ),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _fillDemoCredentials() {
    _emailController.text = _demoEmail;
    _passwordController.text = _demoPassword;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          tr(
            'Credenciales demo cargadas.',
            'Demo credentials loaded.',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.02),
                          _buildBrandHeader(isDark),
                          const SizedBox(height: 26),
                          _buildLoginCard(isDark),
                          const SizedBox(height: 20),
                          _buildFooter(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF0E1A12),
                  Color(0xFF121212),
                  Color(0xFF1B1B1B),
                ]
              : const [
                  Color(0xFFEFF7EC),
                  Color(0xFFF8F6F1),
                  Color(0xFFFFF8E1),
                ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -45,
            child: _decorativeCircle(
              size: 190,
              color: AppTheme.primaryLight.withOpacity(isDark ? 0.18 : 0.22),
            ),
          ),
          Positioned(
            bottom: -65,
            left: -55,
            child: _decorativeCircle(
              size: 210,
              color: AppTheme.accentColor.withOpacity(isDark ? 0.16 : 0.24),
            ),
          ),
          Positioned(
            top: 145,
            left: 24,
            child: Icon(
              Icons.eco_rounded,
              size: 52,
              color: AppTheme.primaryColor.withOpacity(0.12),
            ),
          ),
          Positioned(
            bottom: 165,
            right: 28,
            child: Icon(
              Icons.agriculture_rounded,
              size: 62,
              color: AppTheme.accentColor.withOpacity(0.16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorativeCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildBrandHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryLight,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(isDark ? 0.18 : 0.28),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.agriculture_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'AgroGo',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          tr(
            'Renta maquinaria agrícola de forma rápida y segura',
            'Rent agricultural machinery quickly and safely',
          ),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.35,
              ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E).withOpacity(0.96)
            : Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Bienvenido de nuevo', 'Welcome back'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              tr(
                'Inicia sesión para consultar reservas, favoritos y tu perfil.',
                'Sign in to check bookings, favorites and your profile.',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildRoleSelector(isDark),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: tr('Correo electrónico', 'Email'),
                hintText: 'usuario@email.com',
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';

                if (email.isEmpty) {
                  return tr(
                    'Ingresa tu correo electrónico.',
                    'Enter your email.',
                  );
                }

                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                if (!emailRegex.hasMatch(email)) {
                  return tr(
                    'Escribe un correo válido.',
                    'Enter a valid email.',
                  );
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: tr('Contraseña', 'Password'),
                hintText: tr('Mínimo 6 caracteres', 'At least 6 characters'),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                final password = value?.trim() ?? '';

                if (password.isEmpty) {
                  return tr(
                    'Ingresa tu contraseña.',
                    'Enter your password.',
                  );
                }

                if (password.length < 6) {
                  return tr(
                    'La contraseña debe tener al menos 6 caracteres.',
                    'Password must have at least 6 characters.',
                  );
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() => _rememberMe = value ?? false);
                  },
                ),
                Expanded(
                  child: Text(
                    tr('Recordarme', 'Remember me'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          tr(
                            'Recuperación de contraseña pendiente de backend.',
                            'Password recovery pending backend connection.',
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    tr('¿Olvidaste tu contraseña?', 'Forgot password?'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _isLoading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          tr('Iniciar sesión', 'Sign in'),
                          key: const ValueKey('text'),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _fillDemoCredentials,
                icon: const Icon(Icons.auto_fix_high_rounded),
                label: Text(
                  tr('Usar cuenta demo', 'Use demo account'),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _buildDemoAccessNote(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoAccessNote(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(isDark ? 0.24 : 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr(
                'Demo: carlos.mendoza@email.com / agrogo123',
                'Demo: carlos.mendoza@email.com / agrogo123',
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        Text(
          tr('¿Aún no tienes cuenta?', 'Do not have an account yet?'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Text(
            tr('Crear cuenta en AgroGo', 'Create AgroGo account'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Selecciona tu rol', 'Select your role'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRoleButton(
                label: tr('Rentador', 'Renter'),
                isSelected: _selectedRole == 'rentador',
                onTap: () {
                  setState(() => _selectedRole = 'rentador');
                },
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleButton(
                label: tr('Arrendador', 'Landlord'),
                isSelected: _selectedRole == 'arrendador',
                onTap: () {
                  setState(() => _selectedRole = 'arrendador');
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark ? const Color(0xFF404040) : const Color(0xFFE0E0E0),
                ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
          ),
        ),
      ),
    );
  }
}