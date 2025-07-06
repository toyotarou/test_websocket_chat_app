const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

console.log('🚀 WebSocketサーバー起動: ws://localhost:8080');

wss.on('connection', (ws) => {
  console.log('✅ クライアント接続');

  ws.on('message', (message) => {
    console.log('📨 受信:', message.toString());

    // 他の全クライアントに送信（送信者以外）
    wss.clients.forEach((client) => {
      if (client !== ws && client.readyState === WebSocket.OPEN) {
        client.send(message.toString());
      }
    });
  });

  ws.on('close', () => {
    console.log('🔌 クライアント切断');
  });
});
