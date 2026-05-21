import 'package:flutter/material.dart';
import '../globals.dart';
import '../theme/app_theme.dart';
import '../models/chat_message.dart';
import '../models/review.dart';
import '../data/database_helper.dart';

class CommunicationScreen extends StatefulWidget {
  final String? initialConversationId;

  const CommunicationScreen({super.key, this.initialConversationId});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<ChatConversation> conversations = [];
  List<Review> myReviews = [];
  List<RenterRating> renterRatings = [];

  ChatConversation? selectedConversation;
  final messageController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMockData() async {
    try {
      final dbHelper = DatabaseHelper();
      if (widget.initialConversationId != null) {
        await dbHelper.markConversationMessagesAsRead(
          widget.initialConversationId!,
          userRoleNotifier.value,
        );
      }

      final db = await dbHelper.database;
      final messagesData = await db.query('chat_messages', orderBy: 'sentAt ASC');
      
      // Agrupar mensajes en conversaciones
      Map<String, List<ChatMessage>> grouped = {};
      for (var m in messagesData) {
        final msg = ChatMessage.fromJson(m);
        if (!grouped.containsKey(msg.conversationId)) {
          grouped[msg.conversationId] = [];
        }
        grouped[msg.conversationId]!.add(msg);
      }
      
      List<ChatConversation> loadedConversations = [];
      grouped.forEach((convId, msgs) {
        if (msgs.isEmpty) return;
        
        final parts = convId.split('_');
        String otherName = parts.isNotEmpty ? parts[0] : 'Usuario';
        String equipmentName = parts.length > 1 ? parts.sublist(1).join('_') : 'Equipo';
        
        // Buscar un mensaje del otro rol para sacar bien el nombre
        ChatMessage? otherMsg;
        try {
          otherMsg = msgs.firstWhere((element) => element.senderRole != userRoleNotifier.value);
          otherName = otherMsg.senderName;
        } catch (e) {
          // En caso de que no haya mensajes del otro
          otherName = parts.isNotEmpty ? parts[0] : 'Usuario';
        }

        loadedConversations.add(
          ChatConversation(
            id: convId,
            rentalId: 'R_$convId', // Simulado
            equipmentName: equipmentName,
            otherUserName: otherName,
            otherUserRole: otherMsg?.senderRole ?? 'Rentador/Arrendador',
            lastMessageAt: msgs.last.sentAt,
            lastMessage: msgs.last.message,
            unreadCount: msgs.where((m) => !m.isRead && m.senderRole != userRoleNotifier.value).length,
            messages: msgs,
          ),
        );
      });

      ChatConversation? openConversation;
      if (widget.initialConversationId != null) {
        try {
          openConversation = loadedConversations.firstWhere(
            (c) => c.id == widget.initialConversationId,
          );
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          conversations = loadedConversations;
          selectedConversation = openConversation;
          myReviews = [];
          renterRatings = [];
          _isLoading = false;
        });
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          tr('Comunicación y Reputación', 'Communication and Reputation'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: isDark ? Colors.grey[600] : Colors.grey[700],
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(
              text: tr('Chat', 'Chat'),
              icon: const Icon(Icons.chat_rounded),
            ),
            Tab(
              text: tr('Reputación', 'Reputation'),
              icon: const Icon(Icons.star_rounded),
            ),
          ],
        ),
      ),
      body: selectedConversation != null
          ? _buildChatDetailView(isDark)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChatTab(isDark),
                _buildReputationTab(isDark),
              ],
            ),
    );
  }

  // ========== TAB 1: CHAT ==========
  Widget _buildChatTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_rounded,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              tr('Sin conversaciones', 'No conversations'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: conversations.length,
      itemBuilder: (context, index) =>
          _buildConversationCard(conversations[index], isDark),
    );
  }

  Future<void> _openConversation(ChatConversation conversation) async {
    await DatabaseHelper().markConversationMessagesAsRead(
      conversation.id,
      userRoleNotifier.value,
    );
    if (!mounted) return;
    setState(() {
      selectedConversation = conversation;
    });
  }

  Widget _buildConversationCard(ChatConversation conversation, bool isDark) {
    return GestureDetector(
      onTap: () => _openConversation(conversation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              child: Text(
                conversation.otherUserName[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.otherUserName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.equipmentName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          fontSize: 11,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontSize: 10,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${conversation.lastMessageAt.hour}:${conversation.lastMessageAt.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 6),
                if (conversation.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      conversation.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatDetailView(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () {
                  setState(() {
                    selectedConversation = null;
                  });
                },
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                child: Text(
                  selectedConversation!.otherUserName[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedConversation!.otherUserName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      selectedConversation!.equipmentName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: selectedConversation!.messages.length,
            itemBuilder: (context, index) {
              final message = selectedConversation!.messages[index];
              final isMe = message.senderRole == userRoleNotifier.value;

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppTheme.primaryColor
                        : (isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isMe ? Colors.white : null,
                          fontSize: 12,
                        ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: tr('Escribe un mensaje...', 'Type a message...'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                onPressed: () async {
                  if (messageController.text.isNotEmpty && selectedConversation != null) {
                    String senderName = tr('Usuario', 'User');
                    final email = currentUserEmailNotifier.value;
                    if (email != null) {
                      final users = await DatabaseHelper().getAll('users');
                      try {
                        final user = users.firstWhere((u) => u['email'] == email);
                        senderName = user['name']?.toString() ?? senderName;
                      } catch (_) {}
                    }

                    final newMsg = ChatMessage(
                      id: 'M_${DateTime.now().millisecondsSinceEpoch}',
                      conversationId: selectedConversation!.id,
                      senderId: currentUserEmailNotifier.value ?? 'me',
                      senderName: senderName,
                      senderRole: userRoleNotifier.value,
                      message: messageController.text.trim(),
                      sentAt: DateTime.now(),
                      isRead: true,
                    );
                    
                    // Insert into DB
                    await DatabaseHelper().insert('chat_messages', newMsg.toJson());

                    setState(() {
                      selectedConversation!.messages.add(newMsg);
                      // Move this conversation to top is done manually or by sorting
                      messageController.clear();
                    });
                  }
                },
                child: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========== TAB 2: REPUTACIÓN ==========
  Widget _buildReputationTab(bool isDark) {
    double averageRating = myReviews.isEmpty
        ? 0.0
        : myReviews.reduce((a, b) => Review(
              id: '',
              rentalId: '',
              reviewerName: '',
              reviewerRole: '',
              rating: a.rating + b.rating,
              comment: '',
              createdAt: DateTime.now(),
              categories: [],
            )).rating /
            myReviews.length;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      children: [
        // Resumen de reputación
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Mi Calificación', 'My Rating'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 28,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index < averageRating.toInt()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${myReviews.length} ${tr('valoraciones', 'ratings')}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          tr('Valoraciones Recibidas', 'Received Ratings'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
        ),
        const SizedBox(height: 10),
        if (myReviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                tr('Sin valoraciones aún', 'No ratings yet'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
              ),
            ),
          )
        else
          Column(
            children: myReviews
                .map((review) => _buildReviewCard(review, isDark))
                .toList(),
          ),
        const SizedBox(height: 20),
        Text(
          tr('Calificaciones de Clientes', 'Renter Ratings'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
        ),
        const SizedBox(height: 10),
        Column(
          children: renterRatings
              .map((rating) => _buildRenterRatingCard(rating, isDark))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.reviewerName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating.toInt()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  fontSize: 9,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenterRatingCard(RenterRating rating, bool isDark) {
    Color ratingColor = rating.averageRating >= 4.5
        ? Colors.green
        : (rating.averageRating >= 3.5
            ? Colors.orange
            : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: ratingColor.withOpacity(0.2),
            child: Text(
              rating.renterName[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ratingColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rating.renterName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                    ),
                    if (rating.isVerified)
                      Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: Colors.green,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating.averageRating.toInt()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: ratingColor,
                          size: 13,
                        ),
                      ),
                    ),
                    Text(
                      rating.formattedAverageRating,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ratingColor,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${rating.totalReviews} ${tr("rentas", "rentals")}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
