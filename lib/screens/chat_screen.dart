// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lyno_cms/controller/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width > 900;

    final ChatController c = Get.find<ChatController>();
    debugPrint('ChatScreen current user: ${c.currentUserId}');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F6F7),
        foregroundColor: Colors.black,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Messages',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: SafeArea(
        child: isWide
            ? const Row(
                children: [
                  SizedBox(width: 16),
                  SizedBox(width: 320, child: _ChatUsersPanel()),
                  SizedBox(width: 16),
                  Expanded(child: _ConversationPanel()),
                  SizedBox(width: 16),
                ],
              )
            : const _MobileLayout(),
      ),
    );
  }
}

/// ---------------- LEFT PANEL ----------------

class _ChatUsersPanel extends StatelessWidget {
  const _ChatUsersPanel();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChatController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search, size: 20),
                hintText: 'Search',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _FilterChip(label: 'All', selected: true),
              const SizedBox(width: 8),
              const _FilterChip(label: 'Unread'),
              const SizedBox(width: 8),
              const _FilterChip(label: 'Archived'),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Obx(() {
              if (c.isLoadingConversations.value || c.isLoadingUsers.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (c.users.isEmpty) {
                return const Center(
                  child: Text(
                    'No users / conversations',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                );
              }

              final currentParticipantId =
                  c.selectedConversation.value?.participant.id;

              return ListView.separated(
                itemCount: c.users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = c.users[index];

                  // is user ke saath koi conversation hai?
                  final convo = c.findConversationWithUser(user.id);
                  final hasConvo = convo != null;

                  // 🔥 active row: jis user ka conversation open hai
                  final bool isActive =
                      currentParticipantId != null &&
                      currentParticipantId == user.id;

                  final lastText = hasConvo && convo!.lastMessage.isNotEmpty
                      ? convo.lastMessage
                      : 'Start conversation';

                  final timeText = hasConvo
                      ? _formatTime(convo!.lastMessageAt)
                      : '';

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => c.openConversationWithUser(user),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFE5EDFF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lastText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            timeText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime? dt) {
  if (dt == null) return '';
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${dt.day}/${dt.month}/${dt.year}';
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1D4ED8) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: selected ? Colors.white : const Color(0xFF4B5563),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// ---------------- RIGHT PANEL ----------------

class _ConversationPanel extends StatelessWidget {
  const _ConversationPanel();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChatController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const _ChatHeader(),
          const Divider(height: 24),
          Expanded(
            child: Obx(() {
              if (c.selectedConversation.value == null) {
                return const Center(
                  child: Text(
                    'Select a conversation',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                );
              }

              if (c.isLoadingMessages.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (c.messages.isEmpty) {
                return const Center(
                  child: Text(
                    'No messages yet. Say hi 👋',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: c.messages.length,
                itemBuilder: (context, index) {
                  final m = c.messages[index];
                  final isMe = m.sender.id == c.currentUserId;

                  final bubble = Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomLeft: Radius.circular(isMe ? 16 : 2),
                        bottomRight: Radius.circular(isMe ? 2 : 16),
                      ),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: isMe ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe) const SizedBox(width: 32),
                        Flexible(child: bubble),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(m.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        if (isMe) const SizedBox(width: 32),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 8),
          const _MessageInput(),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChatController>();

    return Obx(() {
      final convo = c.selectedConversation.value;
      if (convo == null) return const SizedBox.shrink();

      final other = convo.participant;

      return Row(
        children: [
          CircleAvatar(
            radius: 22,
            child: Text(
              other.name.isNotEmpty ? other.name[0].toUpperCase() : '?',
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                other.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                other.email,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ],
      );
    });
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChatController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.insert_emoticon_outlined, size: 22),
          ),
          Expanded(
            child: TextField(
              controller: c.messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => c.sendMessage(),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.attach_file, size: 20),
          ),
          const SizedBox(width: 4),
          Obx(() {
            return InkWell(
              onTap: c.sending.value ? null : c.sendMessage,
              child: Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: c.sending.value
                      ? const Color(0xFF93C5FD)
                      : const Color(0xFF1D4ED8),
                  shape: BoxShape.circle,
                ),
                child: c.sending.value
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// ---------------- MOBILE LAYOUT ----------------

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        Padding(padding: EdgeInsets.all(16), child: _ChatUsersPanel()),
        Padding(padding: EdgeInsets.all(16), child: _ConversationPanel()),
      ],
    );
  }
}
