import 'dart:async';
import 'dart:convert';

import 'package:lextari/core/config/app_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket client for FastAPI streaming endpoint.
///
/// Auth via first message (not query param) — same pattern as
/// ThingsBoard's own WS auth. No token leakage in server logs.
class WsClient {
  /// Creates a [WsClient] with an optional custom [url].
  /// Defaults to [AppConfig.wsUrl].
  WsClient({String? url}) : url = url ?? AppConfig.wsUrl;

  /// The WebSocket server URL.
  final String url;
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _disposed = false;
  String? _token;
  bool _authenticated = false;
  static const _maxAttempts = 10;

  /// Connects to the WebSocket using [token] for authentication.
  /// Returns a broadcast stream of decoded JSON messages.
  Stream<Map<String, dynamic>> connect(String token) {
    _token = token;
    _authenticated = false;
    _controller = StreamController<Map<String, dynamic>>.broadcast();
    _doConnect();
    return _controller!.stream;
  }

  void _doConnect() {
    if (_disposed || _token == null) return;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _reconnectAttempts = 0;
      _authenticated = false;

      // Send auth as first message
      _channel!.sink.add(
        jsonEncode({
          'type': 'auth',
          'token': _token,
        }),
      );

      _channel!.stream.listen(
        (raw) {
          try {
            final data = jsonDecode(raw as String) as Map<String, dynamic>;

            // First message should be auth acknowledgement
            if (!_authenticated) {
              if (data['type'] == 'auth_ok') {
                _authenticated = true;
              }
              return;
            }

            _controller?.add(data);
            // Silently skip malformed JSON messages.
            // ignore: avoid_catches_without_on_clauses
          } catch (_) {}
        },
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
      );
      // WebSocket.connect() can throw on invalid URLs or DNS errors.
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectAttempts >= _maxAttempts) return;
    _reconnectAttempts++;
    final delay = Duration(
      seconds: [1, 2, 4, 8, 15, 30][_reconnectAttempts.clamp(0, 5)],
    );
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      // sink.close() is fire-and-forget inside a timer callback.
      // ignore: discarded_futures
      _channel?.sink.close();
      // _doConnect() returns void; no await needed here.
      _doConnect();
    });
  }

  /// Sends a JSON message over the WebSocket connection.
  void send(Map<String, dynamic> msg) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(msg));
    }
  }

  /// Closes the WebSocket and releases all resources.
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    // Fire-and-forget: sink.close() called inside dispose(), not awaited.
    // ignore: discarded_futures
    _channel?.sink.close();
    // StreamController.close() returns a Future; fire-and-forget in dispose().
    // ignore: discarded_futures
    _controller?.close();
  }
}
