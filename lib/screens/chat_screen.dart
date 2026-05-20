import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/chat_message.dart';
import '../data/database_helper.dart';
import '../globals.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserName;
  final String equipmentName;
  final String otherUserRole; // 'arrendador' or 'rentador'
  final String otherUserPhone;

  const ChatScreen({
    super.key,
    required this.otherUserName,
    required this.equipmentName,
    required this.otherUserRole,
    required this.otherUserPhone,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  
  String get _conversationId => '${widget.otherUserName}_${widget.equipmentName}';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final db = await DatabaseHelper().database;
      final results = await db.query(
        'chat_messages',
        where: 'conversationId = ?',
        whereArgs: [_conversationId],
        orderBy: 'sentAt ASC',
      );
      
      if (results.isEmpty) {
        // Mock initial message
        final initialMsg = ChatMessage(
          id: 'M_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: _conversationId,
          senderId: 'other',
          senderName: widget.otherUserName,
          senderRole: widget.otherUserRole,
          message: widget.otherUserRole == 'arrendador' 
              ? '¡Hola! ¿En qué puedo ayudarte con el ${widget.equipmentName}?' 
              : 'Hola, tengo una pregunta sobre la renta del ${widget.equipmentName}.',
          sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
          isRead: true,
        );
        await DatabaseHelper().insert('chat_messages', initialMsg.toJson());
        
        if (mounted) {
          setState(() {
            _messages = [initialMsg];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _messages = results.map((m) => ChatMessage.fromJson(m)).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading messages: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: 'M_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: _conversationId,
      senderId: currentUserEmailNotifier.value ?? 'me', // Current user
      senderName: 'Yo',
      senderRole: userRoleNotifier.value,
      message: _messageController.text.trim(),
      sentAt: DateTime.now(),
      isRead: true,
      imageUrl: null, // ensure this is defined locally
    );

    // Save to DB
    try {
      await DatabaseHelper().insert('chat_messages', newMessage.toJson());
    } catch (e) {
      print("Error sending message: $e");
    }

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${tr('Teléfono:', 'Phone:')} ${widget.otherUserPhone} • ${widget.equipmentName}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // Could launch url here for tel:
            },
          )
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderRole == userRoleNotifier.value;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe 
                          ? AppTheme.primaryColor 
                          : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                        bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      message.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isMe ? Colors.white : null,
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: tr('Escribe un mensaje...', 'Type a message...'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
