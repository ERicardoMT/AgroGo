import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../globals.dart';
import '../data/database_helper.dart';
import '../models/message_notification.dart';
import 'communication_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isLoading = true;
  List<MessageNotificationSummary> messageNotifications = [];
  List<Map<String, dynamic>> systemAlerts = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final dbHelper = DatabaseHelper();
    final currentRole = userRoleNotifier.value;

    final messages =
        await dbHelper.getMessageNotificationSummaries(currentRole);
    final alerts = await dbHelper.getAll('landlord_alerts');

    List<Map<String, dynamic>> sortedAlerts = List.from(alerts);
    sortedAlerts.sort(
      (a, b) => (b['createdAt'] ?? '').toString().compareTo(
            (a['createdAt'] ?? '').toString(),
          ),
    );

    if (!mounted) return;
    setState(() {
      messageNotifications = messages;
      systemAlerts = sortedAlerts;
      isLoading = false;
    });
  }

  Future<void> _openMessageChat(MessageNotificationSummary notification) async {
    await DatabaseHelper().markConversationMessagesAsRead(
      notification.conversationId,
      userRoleNotifier.value,
    );

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunicationScreen(
          initialConversationId: notification.conversationId,
        ),
      ),
    );

    _loadNotifications();
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
    final hasMessages = messageNotifications.isNotEmpty;
    final hasAlerts = systemAlerts.isNotEmpty;
    final isEmpty = !hasMessages && !hasAlerts;

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
          : isEmpty
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
                        tr(
                          'No tienes notificaciones recientes.',
                          'You have no recent notifications.',
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (hasMessages) ...[
                        Text(
                          tr('Mensajes', 'Messages'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...messageNotifications.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildMessageNotificationCard(item, isDark),
                          ),
                        ),
                      ],
                      if (hasAlerts) ...[
                        if (hasMessages) const SizedBox(height: 8),
                        Text(
                          tr('Alertas', 'Alerts'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...systemAlerts.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSystemAlertCard(item, isDark),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildMessageNotificationCard(
    MessageNotificationSummary item,
    bool isDark,
  ) {
    final hasUnread = item.unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openMessageChat(item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasUnread
                  ? AppTheme.primaryColor.withOpacity(0.5)
                  : (isDark ? const Color(0xFF303030) : AppTheme.borderColor),
              width: hasUnread ? 1.5 : 1,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                  child: Text(
                    item.senderName.isNotEmpty
                        ? item.senderName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.senderName,
                    style: TextStyle(
                      fontWeight:
                          hasUnread ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  _formatTime(item.sentAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  item.equipmentName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    height: 1.3,
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(height: 6),
                  Text(
                    tr('Nuevo mensaje', 'New message'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemAlertCard(Map<String, dynamic> item, bool isDark) {
    final isRead = item['isRead'] == 1;
    final type = item['type']?.toString();
    final color = _getColorForType(type, isDark);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.transparent : color.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(_getIconForType(type), color: color),
        ),
        title: Text(
          item['title']?.toString() ?? tr('Alerta', 'Alert'),
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w500 : FontWeight.w800,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
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
  }
}
