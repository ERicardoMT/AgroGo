import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      user.name.split(' ').map((n) => n[0]).take(2).join(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.location,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat(context, '${MockData.bookings.length}',
                          'Reservas'),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.borderColor,
                      ),
                      _buildStat(context, '12', 'Equipos rentados'),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.borderColor,
                      ),
                      _buildStat(context, '4.8', 'Calificación'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu Items
            _buildMenuSection(context, 'Cuenta', [
              _MenuItem(
                icon: Icons.person_outline,
                title: 'Información personal',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.credit_card_outlined,
                title: 'Métodos de pago',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.location_on_outlined,
                title: 'Direcciones',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 16),

            _buildMenuSection(context, 'Preferencias', [
              _MenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: AppTheme.primaryColor,
                ),
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.language_outlined,
                title: 'Idioma',
                subtitle: 'Español',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.dark_mode_outlined,
                title: 'Modo oscuro',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                  activeColor: AppTheme.primaryColor,
                ),
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 16),

            _buildMenuSection(context, 'Soporte', [
              _MenuItem(
                icon: Icons.help_outline,
                title: 'Centro de ayuda',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.chat_outlined,
                title: 'Contactar soporte',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.description_outlined,
                title: 'Términos y condiciones',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Versión 1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMenuSection(
      BuildContext context, String title, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
          ),
          ...items.map((item) => _buildMenuItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: AppTheme.textPrimary,
      ),
      title: Text(item.title),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      trailing: item.trailing ??
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textMuted,
          ),
      onTap: item.onTap,
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });
}
