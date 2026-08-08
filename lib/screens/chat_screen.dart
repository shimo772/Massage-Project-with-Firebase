import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ لإضافة تنسيق الوقت

class ChatScreen extends StatefulWidget {
  static const String screenRoute = 'chat_screen';

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isSending = false;

  User? get currentUser => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    // ✅ تأكيد أن المستخدم مسجل دخول
    if (currentUser == null) {
      _navigateToLogin();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ دالة لإرسال الرسالة
  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();

    if (messageText.isEmpty || currentUser == null || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await _firestore.collection('messages').add({
        'text': messageText,
        'sender': currentUser!.email,
        'senderName': currentUser!.displayName ?? currentUser!.email,
        'time': FieldValue.serverTimestamp(),
      });

      _messageController.clear();

      // ✅ التمرير إلى أسفل بعد الإرسال
      _scrollToBottom();
    } catch (e) {
      _showSnackBar('Failed to send message: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // ✅ دالة للتمرير إلى أسفل
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ✅ دالة للتنقل إلى شاشة تسجيل الدخول
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, 'sign_screen');
  }

  // ✅ دالة عرض SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ✅ دالة تسجيل الخروج
  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signOut();
      if (mounted) {
        _navigateToLogin();
      }
    } catch (e) {
      _showSnackBar('Error signing out: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[900],
        elevation: 2,
        title: Row(
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: Image.asset('images/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'MessageMe',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          // ✅ عرض حالة الاتصال
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('messages').limit(1).snapshots(),
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  snapshot.connectionState == ConnectionState.active
                      ? Icons.wifi
                      : Icons.wifi_off,
                  color: Colors.white,
                  size: 20,
                ),
              );
            },
          ),
          IconButton(
            onPressed: _isLoading ? null : _signOut,
            icon: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط حالة المستخدم
          _buildUserStatus(),

          // ✅ قائمة الرسائل
          Expanded(
            child: MessageStreamBuilder(scrollController: _scrollController),
          ),

          // ✅ حقل إدخال الرسالة
          _buildMessageInput(),
        ],
      ),
    );
  }

  // ✅ بناء شريط حالة المستخدم
  Widget _buildUserStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            currentUser?.email ?? 'Not logged in',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  // ✅ بناء حقل إدخال الرسالة
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ زر إرفاق (اختياري)
          IconButton(
            onPressed: () {
              // إضافة وظيفة إرفاق ملفات أو صور
            },
            icon: const Icon(Icons.attach_file, color: Colors.grey),
          ),

          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                suffixIcon: _messageController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _messageController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {}); // تحديث حالة الزر
              },
              onSubmitted: (value) {
                _sendMessage();
              },
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),

          // ✅ زر إرسال مع حالة التحميل
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 8),
            child: _isSending
                ? const CircularProgressIndicator(
                    color: Colors.blue,
                    strokeWidth: 2,
                  )
                : IconButton(
                    onPressed: _messageController.text.isNotEmpty
                        ? _sendMessage
                        : null,
                    icon: Icon(
                      Icons.send,
                      color: _messageController.text.isNotEmpty
                          ? Colors.blue[800]
                          : Colors.grey.shade400,
                    ),
                    tooltip: 'Send',
                  ),
          ),
        ],
      ),
    );
  }
}

// ✅ MessageStreamBuilder المحسّن
class MessageStreamBuilder extends StatelessWidget {
  const MessageStreamBuilder({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .orderBy('time', descending: true) // ✅ الأحدث أولاً مع reverse
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                TextButton(
                  onPressed: () {
                    // إعادة المحاولة
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading messages...'),
              ],
            ),
          );
        }

        final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
        if (currentUserEmail == null) {
          return const Center(child: Text('Please sign in again.'));
        }

        // ✅ التحقق من وجود بيانات
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No messages yet', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8),
                Text(
                  'Send the first message!',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageDoc = messages[index];
            final messageData = messageDoc.data() as Map<String, dynamic>;

            final messageText = messageData['text'] as String? ?? '';
            final messageSender = messageData['sender'] as String? ?? 'Unknown';
            final messageSenderName =
                messageData['senderName'] as String? ?? messageSender;
            final timestamp = messageData['time'] as Timestamp?;

            final isMe = currentUserEmail == messageSender;

            return MessageLine(
              text: messageText,
              sender: messageSenderName,
              isMe: isMe,
              timestamp: timestamp,
            );
          },
        );
      },
    );
  }
}

// ✅ MessageLine المحسّن
class MessageLine extends StatelessWidget {
  const MessageLine({
    super.key,
    required this.text,
    required this.sender,
    required this.isMe,
    this.timestamp,
  });

  final String text;
  final String sender;
  final bool isMe;
  final Timestamp? timestamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // ✅ عرض الصورة الرمزية للمرسل
            _buildAvatar(),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // ✅ اسم المرسل مع الوقت
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isMe ? 'You' : sender,
                      style: TextStyle(
                        fontSize: 12,
                        color: isMe ? Colors.blue[700] : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (timestamp != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(timestamp!),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                // ✅ فقاعة الرسالة
                Material(
                  elevation: 1,
                  borderRadius: _getBubbleBorderRadius(isMe),
                  color: isMe ? Colors.blue[700] : Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe ? Colors.white : Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),

                // ✅ حالة "مقروء" (اختياري)
                if (isMe && timestamp != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.done_all,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (isMe) ...[const SizedBox(width: 8), _buildAvatar()],
        ],
      ),
    );
  }

  // ✅ بناء الصورة الرمزية
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isMe ? Colors.blue[100] : Colors.grey[300],
      child: Text(
        sender.isNotEmpty ? sender[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 14,
          color: isMe ? Colors.blue[700] : Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ✅ تنسيق الوقت
  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return DateFormat('hh:mm a').format(date);
    } else {
      return DateFormat('dd MMM hh:mm a').format(date);
    }
  }

  // ✅ زوايا فقاعة الرسالة
  BorderRadius _getBubbleBorderRadius(bool isMe) {
    if (isMe) {
      return const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(4),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(20),
      );
    }
  }
}

// ✅ إضافة Extension لتسهيل التعامل مع البيانات
extension MessageData on DocumentSnapshot {
  String get messageText => (this['text'] as String?) ?? '';
  String get messageSender => (this['sender'] as String?) ?? 'Unknown';
  String get messageSenderName =>
      (this['senderName'] as String?) ?? messageSender;
  Timestamp? get messageTime => this['time'] as Timestamp?;
  bool isMine(String email) => messageSender == email;
}
