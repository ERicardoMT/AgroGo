class MessageNotificationSummary {
  final String conversationId;
  final String senderName;
  final String senderRole;
  final String message;
  final DateTime sentAt;
  final String equipmentName;
  final int unreadCount;

  MessageNotificationSummary({
    required this.conversationId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.sentAt,
    required this.equipmentName,
    required this.unreadCount,
  });
}
