// lib/models/chat_models.dart

class ChatUserMini {
  final String id;
  final String name;
  final String email;
  final String? role;

  ChatUserMini({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory ChatUserMini.fromJson(Map<String, dynamic> json) {
    return ChatUserMini(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      role: json['role']?.toString(),
    );
  }
}

class ConversationModel {
  final String id;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final ChatUserMini participant;

  ConversationModel({
    required this.id,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.participant,
  });

  ConversationModel copyWith({String? lastMessage, DateTime? lastMessageAt}) {
    return ConversationModel(
      id: id,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      participant: participant,
    );
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: (json['_id'] ?? '').toString(),
      lastMessage: (json['lastMessage'] ?? '') as String,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'].toString())
          : null,
      participant: ChatUserMini.fromJson(
        Map<String, dynamic>.from(json['participant'] ?? {}),
      ),
    );
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final ChatUserMini sender;
  final ChatUserMini receiver;
  final String text;
  final String status;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.receiver,
    required this.text,
    required this.status,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final conv = json['conversation'];
    String convId;
    if (conv is Map) {
      convId = (conv['_id'] ?? conv['id'] ?? '').toString();
    } else {
      convId = conv.toString();
    }

    return MessageModel(
      id: (json['_id'] ?? '').toString(),
      conversationId: convId,
      sender: ChatUserMini.fromJson(
        Map<String, dynamic>.from(json['sender'] ?? {}),
      ),
      receiver: ChatUserMini.fromJson(
        Map<String, dynamic>.from(json['receiver'] ?? {}),
      ),
      text: (json['text'] ?? '') as String,
      status: (json['status'] ?? 'sent') as String,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
