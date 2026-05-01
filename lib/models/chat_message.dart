class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderRole; // rentador, arrendador
  final String message;
  final DateTime sentAt;
  final bool isRead;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.sentAt,
    required this.isRead,
    this.imageUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderRole: json['senderRole'],
      message: json['message'],
      sentAt: DateTime.parse(json['sentAt']),
      isRead: json['isRead'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }
}

class ChatConversation {
  final String id;
  final String rentalId;
  final String equipmentName;
  final String otherUserName;
  final String otherUserRole;
  final String? otherUserImage;
  final DateTime lastMessageAt;
  final String lastMessage;
  final int unreadCount;
  final List<ChatMessage> messages;

  ChatConversation({
    required this.id,
    required this.rentalId,
    required this.equipmentName,
    required this.otherUserName,
    required this.otherUserRole,
    this.otherUserImage,
    required this.lastMessageAt,
    required this.lastMessage,
    required this.unreadCount,
    required this.messages,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      rentalId: json['rentalId'],
      equipmentName: json['equipmentName'],
      otherUserName: json['otherUserName'],
      otherUserRole: json['otherUserRole'],
      otherUserImage: json['otherUserImage'],
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      lastMessage: json['lastMessage'],
      unreadCount: json['unreadCount'] ?? 0,
      messages: (json['messages'] as List?)
              ?.map((m) => ChatMessage.fromJson(m))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rentalId': rentalId,
      'equipmentName': equipmentName,
      'otherUserName': otherUserName,
      'otherUserRole': otherUserRole,
      'otherUserImage': otherUserImage,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}
