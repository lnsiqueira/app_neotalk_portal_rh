import 'package:app_neotalk_portal_rh/services/chatbot_service.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class ChatbotScreen extends StatefulWidget {
  final User user;

  const ChatbotScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Mensagem inicial de boas-vindas
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              'Olá ${widget.user.name}! 👋\n\nSou seu assistente virtual inteligente. Posso ajudá-lo ?',

          //    'Olá ${widget.user.name}! 👋\n\nSou seu assistente virtual inteligente. Posso ajudá-lo com:\n\n📅 Informações sobre férias\n💰 Dissídio e reajustes\n🏥 Migração de plano de saúde\n📚 Cursos e treinamentos\n\nComo posso ajudá-lo hoje?',
          isUser: false,
        ),
      );
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    // Adicionar mensagem do usuário
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    // Gerar resposta do chatbot
    final response = await ChatbotService.generateResponse(
      userMessage,
      widget.user,
    );

    setState(() {
      _messages.add(response);
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente Virtual'),
        backgroundColor: AppTheme.primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Área de mensagens
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildMessageBubble(_messages[index], isMobile);
                } else {
                  return _buildTypingIndicator();
                }
              },
            ),
          ),
          // Divisor
          Divider(height: 1, color: Colors.grey.shade300),
          // Input de mensagem
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua pergunta...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppTheme.dividerColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppTheme.dividerColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryRed,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  backgroundColor: AppTheme.primaryRed,
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMobile) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: isUser ? 32 : 0,
        right: isUser ? 0 : 32,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? AppTheme.primaryRed : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width * (isMobile ? 0.8 : 0.5),
          ),
          child: SelectableText(
            message.text,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 0, right: 32),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(0),
              const SizedBox(width: 4),
              _buildDot(1),
              const SizedBox(width: 4),
              _buildDot(2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -8 * (value.abs() - 0.5).abs()),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        setState(() {});
      },
    );
  }
}
