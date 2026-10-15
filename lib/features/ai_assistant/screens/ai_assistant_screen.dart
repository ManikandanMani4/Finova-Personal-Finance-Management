
import 'package:flutter/material.dart';
import '../services/ai_assistant_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  static const String routeName = '/ai-assistant';

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late final AiAssistantService _aiService;

  bool _isLoading = false;

  // Replace with your deployed backend URL.
  static const String _baseUrl = 'YOUR_BACKEND_URL';

  @override
  void initState() {
    super.initState();
    _aiService = AiAssistantService(baseUrl: _baseUrl);

    _messages.add({
      'role': 'assistant',
      'text':
      'Hi! I am your Finova AI Assistant. Ask me about budgeting, saving, or understanding your spending.',
    });
  }

  Future<void> _sendMessage([String? suggestedQuestion]) async {
    final question = (suggestedQuestion ?? _controller.text).trim();

    if (question.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'text': question});
      _controller.clear();
      _isLoading = true;
    });

    try {
      final answer = await _aiService.askQuestion(question);

      if (!mounted) return;
      setState(() {
        _messages.add({'role': 'assistant', 'text': answer});
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'I could not get a response. Please check your connection '
              'and try again.',
        });
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _aiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF123B35);
    const green = Color(0xFF16866A);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Finova AI'),
            Text(
              'Your personal finance assistant',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_messages.length == 1) ...[
                  const Text(
                    'How can I help you today?',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _suggestion(
                    'How can I save more money?',
                    Icons.savings_outlined,
                        () => _sendMessage('How can I save more money?'),
                  ),
                  _suggestion(
                    'How do I create a monthly budget?',
                    Icons.account_balance_wallet_outlined,
                        () => _sendMessage(
                      'How do I create a monthly budget?',
                    ),
                  ),
                  _suggestion(
                    'Explain emergency funds',
                    Icons.shield_outlined,
                        () => _sendMessage('Explain emergency funds'),
                  ),
                  const SizedBox(height: 20),
                ],
                ..._messages.map((message) {
                  final isUser = message['role'] == 'user';

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.82,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser ? green : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isUser
                            ? null
                            : Border.all(color: const Color(0xFFE2EAE5)),
                      ),
                      child: Text(
                        message['text'] ?? '',
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          height: 1.45,
                        ),
                      ),
                    ),
                  );
                }),
                if (_isLoading)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('Finova is thinking...'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE2EAE5)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask about your finances...',
                        filled: true,
                        fillColor: const Color(0xFFF5F8F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isLoading ? null : () => _sendMessage(),
                    style: IconButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestion(String text, IconData icon, VoidCallback onTap) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2EAE5)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF16866A)),
        title: Text(text, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: _isLoading ? null : onTap,
      ),
    );
  }
}
