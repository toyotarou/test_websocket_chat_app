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
  final List<String> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() async {
    try {
      final socket = await WebSocket.connect('ws://10.0.2.2:8080'); // ← 重要！
      setState(() {
        _socket = socket;
        _isConnected = true;
      });

      _socket!.listen((data) {
        setState(() {
          _messages.add('📩 $data');
        });
      });

      print('✅ WebSocket 接続成功');
    } catch (e) {
      print('❌ WebSocket 接続エラー: $e');
    }
  }

  void _sendMessage() {
    if (_isConnected && _controller.text.isNotEmpty) {
      final message = _controller.text;
      _socket!.add(message);
      _controller.clear();
      print('📤 送信: $message');
    }
  }

  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('チャット')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => ListTile(title: Text(_messages[index])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller)),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
