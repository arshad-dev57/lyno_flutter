// lib/controller/chat_controller.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/chat_models.dart';

class ChatController extends GetxController {
  static const String baseUrl = 'https://lyno-shopping.vercel.app';

  String token = "";
  String currentUserId = "";

  /// STATE
  final RxList<ChatUserMini> users = <ChatUserMini>[].obs;
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;

  final Rxn<ConversationModel> selectedConversation = Rxn<ConversationModel>();

  final isLoadingUsers = false.obs;
  final isLoadingConversations = false.obs;
  final isLoadingMessages = false.obs;
  final sending = false.obs;

  final messageController = TextEditingController();

  final RxBool isOtherTyping = false.obs;
  Timer? _typingTimer;

  late IO.Socket socket;

  @override
  void onInit() {
    super.onInit();
    _loadCredentials(); // Load token & userId
  }

  /// Load token + userId first before making API calls
  Future<void> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    token = prefs.getString("token") ?? "";
    currentUserId = prefs.getString("userId") ?? "";

    debugPrint("🔥 Loaded Token: $token");
    debugPrint("🔥 Loaded UserId: $currentUserId");

    if (token.isEmpty || currentUserId.isEmpty) {
      debugPrint("❌ Token or UserId missing in SharedPreferences!");
      return;
    }

    /// After loading token or userId, start everything
    _connectSocket();
    fetchUsers();
    fetchConversations();
  }

  @override
  void onClose() {
    messageController.dispose();
    _typingTimer?.cancel();
    try {
      socket.dispose();
    } catch (_) {}
    super.onClose();
  }

  // SOCKET CONNECTION
  void _connectSocket() {
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      debugPrint("Socket Connected");
      socket.emit("join", currentUserId);
    });

    socket.onDisconnect((_) => debugPrint("Socket Disconnected"));

    socket.on("newMessage", (data) {
      final msg = MessageModel.fromJson(Map<String, dynamic>.from(data));
      _handleIncomingMessage(msg);
    });

    socket.on("messageSent", (data) {
      final msg = MessageModel.fromJson(Map<String, dynamic>.from(data));
      _handleIncomingMessage(msg);
    });

    socket.on("typing", (data) {
      final map = Map<String, dynamic>.from(data ?? {});
      final convoId = map["conversationId"]?.toString();
      final fromId = map["from"]?.toString();

      if (selectedConversation.value?.id == convoId &&
          selectedConversation.value?.participant.id == fromId) {
        isOtherTyping.value = true;
      }
    });

    socket.on("stopTyping", (data) {
      final map = Map<String, dynamic>.from(data ?? {});
      final convoId = map["conversationId"]?.toString();
      final fromId = map["from"]?.toString();

      if (selectedConversation.value?.id == convoId &&
          selectedConversation.value?.participant.id == fromId) {
        isOtherTyping.value = false;
      }
    });
  }

  // ===== FETCH USERS =====
  Future<void> fetchUsers() async {
    try {
      isLoadingUsers.value = true;

      final uri = Uri.parse("$baseUrl/api/chat/users");
      final res = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final List raw = (body['data'] ?? body['users'] ?? []) as List;

        final list = raw
            .map((e) => ChatUserMini.fromJson(Map<String, dynamic>.from(e)))
            .where((u) => u.id != currentUserId)
            .toList();

        users.assignAll(list);
      } else {
        debugPrint('fetchUsers error: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint("fetchUsers ERROR: $e");
    } finally {
      isLoadingUsers.value = false;
    }
  }

  // ===== FETCH CONVERSATIONS =====
  Future<void> fetchConversations() async {
    try {
      isLoadingConversations.value = true;

      final uri = Uri.parse(
        "$baseUrl/api/chat/conversations?userId=$currentUserId",
      );

      final res = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final List list = body["data"] ?? [];

        final parsed = list
            .map(
              (e) => ConversationModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();

        conversations.assignAll(parsed);

        if (parsed.isNotEmpty && selectedConversation.value == null) {
          selectConversation(parsed.first);
        }
      } else {
        debugPrint('fetchConversations error: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint("fetchConversations ERROR: $e");
    } finally {
      isLoadingConversations.value = false;
    }
  }

  Future<void> selectConversation(ConversationModel convo) async {
    selectedConversation.value = convo;
    isOtherTyping.value = false;
    await fetchMessages(convo.id);
  }

  /// === This method fixes the error you saw ===
  /// Find conversation by participant user id
  ConversationModel? findConversationWithUser(String userId) {
    final idx = conversations.indexWhere((c) => c.participant.id == userId);
    if (idx == -1) return null;
    return conversations[idx];
  }

  // ===== OPEN / CREATE CONVERSATION =====
  Future<void> openConversationWithUser(ChatUserMini user) async {
    final existing = findConversationWithUser(user.id);
    if (existing != null) {
      await selectConversation(existing);
      return;
    }
    await createConversationWithUser(user);
  }

  Future<void> createConversationWithUser(ChatUserMini user) async {
    try {
      final uri = Uri.parse("$baseUrl/api/chat/conversation");

      final body = {"receiverId": user.id, "senderId": currentUserId};

      debugPrint("createConversation body: $body");

      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final convJson = Map<String, dynamic>.from(data['data'] ?? {});

        final convo = ConversationModel(
          id: (convJson['_id'] ?? '').toString(),
          lastMessage: (convJson['lastMessage'] ?? '') as String,
          lastMessageAt: convJson['lastMessageAt'] != null
              ? DateTime.tryParse(convJson['lastMessageAt'].toString())
              : null,
          participant: user,
        );

        final existingIndex = conversations.indexWhere((c) => c.id == convo.id);

        if (existingIndex == -1) {
          conversations.insert(0, convo);
        } else {
          conversations[existingIndex] = convo;
        }

        await selectConversation(convo);
      } else {
        debugPrint(
          'createConversationWithUser error: ${res.statusCode} ${res.body}',
        );
      }
    } catch (e) {
      debugPrint("createConversation ERROR: $e");
    }
  }

  // ===== FETCH MESSAGES =====
  Future<void> fetchMessages(String conversationId) async {
    try {
      isLoadingMessages.value = true;

      final uri = Uri.parse(
        "$baseUrl/api/chat/$conversationId/messages?page=1&limit=50",
      );

      final res = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final List list = body['data'] ?? [];
        final parsed = list
            .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        messages.assignAll(parsed);
      } else {
        debugPrint('fetchMessages error: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint("fetchMessages ERROR: $e");
    } finally {
      isLoadingMessages.value = false;
    }
  }

  // ===== TYPING HANDLER =====
  void handleInputChange(String value) {
    final convo = selectedConversation.value;
    if (convo == null) return;

    final toId = convo.participant.id;

    if (value.isEmpty) {
      socket.emit('stopTyping', {
        'conversationId': convo.id,
        'to': toId,
        'from': currentUserId,
      });
      _typingTimer?.cancel();
      return;
    }

    // typing event
    socket.emit('typing', {
      'conversationId': convo.id,
      'to': toId,
      'from': currentUserId,
    });

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      socket.emit('stopTyping', {
        'conversationId': convo.id,
        'to': toId,
        'from': currentUserId,
      });
    });
  }

  // ===== SEND MESSAGE =====
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    final convo = selectedConversation.value;

    if (text.isEmpty || convo == null) return;

    try {
      sending.value = true;

      final body = {
        'conversationId': convo.id,
        'receiverId': convo.participant.id,
        'text': text,
        'senderId': currentUserId,
      };

      messageController.clear();

      final uri = Uri.parse('$baseUrl/api/chat/message');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final msg = MessageModel.fromJson(
          Map<String, dynamic>.from(data['data']),
        );

        _handleIncomingMessage(msg);

        final toId = convo.participant.id;
        socket.emit('stopTyping', {
          'conversationId': convo.id,
          'to': toId,
          'from': currentUserId,
        });
        _typingTimer?.cancel();
      } else {
        debugPrint('sendMessage error: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('sendMessage exception: $e');
    } finally {
      sending.value = false;
    }
  }

  // ===== HANDLE INCOMING MESSAGE =====
  void _handleIncomingMessage(MessageModel msg) {
    final currentConvoId = selectedConversation.value?.id;

    if (currentConvoId == msg.conversationId) {
      final alreadyIndex = messages.indexWhere((m) => m.id == msg.id);

      if (alreadyIndex == -1) {
        messages.add(msg);
      } else {
        messages[alreadyIndex] = msg;
      }
    }

    final idx = conversations.indexWhere((c) => c.id == msg.conversationId);
    if (idx != -1) {
      final updated = conversations[idx].copyWith(
        lastMessage: msg.text,
        lastMessageAt: msg.createdAt,
      );
      conversations[idx] = updated;
      conversations.refresh();
    } else {
      fetchConversations();
    }
  }
}
