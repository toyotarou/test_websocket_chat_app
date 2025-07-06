import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ChatPage());
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  WebSocket? _socket;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // 自動スクロール用
  final List<String> _messages = [];
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() async {
    try {
      final socket = await WebSocket.connect('ws://10.0.2.2:8080');
      setState(() {
        _socket = socket;
        _isConnected = true;
      });

      _socket!.listen((data) {
        _addMessage('📩 $data');
      });

      print('✅ WebSocket接続成功');
    } catch (e) {
      debugPrint('❌ 接続エラー: $e');
    }
  }

  void _addMessage(String msg) {
    setState(() {
      _messages.add(msg);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_isConnected && _controller.text.isNotEmpty) {
      final message = _controller.text;
      _addMessage('🧑‍💬 (自分) $message'); // 自分の発言を表示
      _socket!.add(message); // サーバーへ送信
      _controller.clear();
      print('📤 送信: $message');
    }
  }

  @override
  void dispose() {
    _socket?.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('リアルタイムチャット')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final msg = _messages[index];
                final isSelf = msg.startsWith('🧑‍💬');
                return Align(
                  alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelf ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg, style: const TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'メッセージを入力',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
            ],
          ),
        ],
      ),
    );
  }
}
