import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../globals.dart';
import '../data/database_helper.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final dbHelper = DatabaseHelper();
    
    // Si la tabla está vacía, podríamos insertar unas de prueba para demostración,
    // pero respetando la base de datos, solo leemos.
    final data = await dbHelper.getAll('landlord_alerts');
    
    List<Map<String, dynamic>> sortedData = List.from(data);
    // Ordenamos de más reciente a más antiguo
    sortedData.sort((a, b) => (b['createdAt'] ?? '').toString().compareTo((a['createdAt'] ?? '').toString()));

    setState(() {
      notifications = sortedData;
      isLoading = false;
    });
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'critical':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'success':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForType(String? type, bool isDark) {
    switch (type) {
      case 'critical':
        return AppTheme.errorColor;
      case 'warning':
        return Colors.orange;
      case 'success':
        return isDark ? Colors.greenAccent : Colors.green;
      default:
        return isDark ? AppTheme.primaryLight : AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          tr('Notificaciones', 'Notifications'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr('No tienes notificaciones recientes.', 'You have no recent notifications.'),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    final isRead = (item['isRead'] == 1);
                    final type = item['type']?.toString();
                    final color = _getColorForType(type, isDark);

                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isRead 
                              ? Colors.transparent 
                              : color.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.1),
                          child: Icon(
                            _getIconForType(type),
                            color: color,
                          ),
                        ),
                        title: Text(
                          item['title']?.toString() ?? 'Alerta',
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            item['message']?.toString() ?? '',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
